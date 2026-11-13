#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>

#include <knownfolders.h>
#include <msi.h>
#include <msiquery.h>
#include <objbase.h>
#include <sddl.h>
#include <shellapi.h>
#include <shlobj.h>
#include <tlhelp32.h>
#include <userenv.h>
#include <wtsapi32.h>

#include <cwchar>
#include <cwctype>
#include <map>
#include <set>
#include <string>
#include <vector>

using Data = std::map<std::wstring, std::wstring>;

const DWORD NsisUninstallTimeoutMs = 5 * 60 * 1000;
const DWORD TerminateWaitMs = 10 * 1000;
const DWORD MaxCloseTimeoutSeconds = 600;
const DWORD DefaultCloseTimeoutSeconds = 30;
const wchar_t *const UninstallRoot = L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall";
const wchar_t *const ProfileListKey = L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList";
const wchar_t *const ShellFoldersKey = L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders";
const wchar_t *const RunKey = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";

struct Target {
	std::wstring sid;
	DWORD session = 0;

	bool operator<(const Target &other) const {
		if (session != other.session) return session < other.session;
		return _wcsicmp(sid.c_str(), other.sid.c_str()) < 0;
	}
};

struct RunningProcess {
	DWORD pid = 0;
	DWORD session = 0;
	std::wstring sid;
};

struct NsisInstall {
	std::wstring uninstaller;
	std::wstring directory;
	std::wstring startMenu;
	bool desktop = false;
	REGSAM view = 0;
};

static void logMessage(MSIHANDLE install, const std::wstring &message) {
	PMSIHANDLE record = MsiCreateRecord(1);
	const std::wstring text = L"LinphoneInstaller: " + message;
	MsiRecordSetStringW(record, 0, L"[1]");
	MsiRecordSetStringW(record, 1, text.c_str());
	MsiProcessMessage(install, INSTALLMESSAGE_INFO, record);
}

static bool iequals(const std::wstring &a, const std::wstring &b) {
	return _wcsicmp(a.c_str(), b.c_str()) == 0;
}

static bool istartsWith(const std::wstring &value, const std::wstring &prefix) {
	return value.size() >= prefix.size() && _wcsnicmp(value.c_str(), prefix.c_str(), prefix.size()) == 0;
}

static bool iendsWith(const std::wstring &value, const std::wstring &suffix) {
	return value.size() >= suffix.size() && _wcsicmp(value.c_str() + value.size() - suffix.size(), suffix.c_str()) == 0;
}

static bool icontains(const std::wstring &value, const std::wstring &needle) {
	if (needle.empty() || value.size() < needle.size()) return false;
	for (size_t i = 0; i + needle.size() <= value.size(); ++i)
		if (_wcsnicmp(value.c_str() + i, needle.c_str(), needle.size()) == 0) return true;
	return false;
}

static std::wstring trim(const std::wstring &value) {
	size_t begin = 0;
	size_t end = value.size();
	while (begin < end && iswspace(value[begin]))
		++begin;
	while (end > begin && iswspace(value[end - 1]))
		--end;
	return value.substr(begin, end - begin);
}

static std::wstring withTrailingSeparator(const std::wstring &path) {
	if (path.empty() || path.back() == L'\\') return path;
	return path + L'\\';
}

static std::wstring withoutTrailingSeparator(std::wstring path) {
	while (path.size() > 3 && path.back() == L'\\')
		path.pop_back();
	return path;
}

static std::wstring parentDirectory(const std::wstring &path) {
	const size_t separator = withoutTrailingSeparator(path).find_last_of(L'\\');
	if (separator == std::wstring::npos) return std::wstring();
	return path.substr(0, separator);
}

static std::wstring fullPath(const std::wstring &path) {
	if (path.empty()) return path;
	DWORD size = GetFullPathNameW(path.c_str(), 0, nullptr, nullptr);
	if (size == 0) return path;
	std::wstring result(size, L'\0');
	size = GetFullPathNameW(path.c_str(), size, &result[0], nullptr);
	if (size == 0 || size >= result.size()) return path;
	result.resize(size);
	return result;
}

static std::wstring longPath(const std::wstring &path) {
	if (istartsWith(path, L"\\\\?\\")) return path;
	if (istartsWith(path, L"\\\\")) return L"\\\\?\\UNC\\" + path.substr(2);
	if (path.size() >= 2 && path[1] == L':') return L"\\\\?\\" + path;
	return path;
}

static DWORD attributesOf(const std::wstring &path) {
	return GetFileAttributesW(longPath(path).c_str());
}

static bool fileExists(const std::wstring &path) {
	const DWORD attributes = attributesOf(path);
	return attributes != INVALID_FILE_ATTRIBUTES && !(attributes & FILE_ATTRIBUTE_DIRECTORY);
}

static bool directoryExists(const std::wstring &path) {
	const DWORD attributes = attributesOf(path);
	return attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_DIRECTORY);
}

static std::wstring getProperty(MSIHANDLE install, const wchar_t *name) {
	wchar_t empty[1] = L"";
	DWORD size = 0;
	const UINT result = MsiGetPropertyW(install, name, empty, &size);
	if (result != ERROR_MORE_DATA || size == 0) return std::wstring();
	std::wstring value(size + 1, L'\0');
	size = static_cast<DWORD>(value.size());
	if (MsiGetPropertyW(install, name, &value[0], &size) != ERROR_SUCCESS) return std::wstring();
	value.resize(size);
	return value;
}

static Data parseData(const std::wstring &raw) {
	Data data;
	size_t start = 0;
	while (start <= raw.size()) {
		size_t end = raw.find(L'|', start);
		if (end == std::wstring::npos) end = raw.size();
		const std::wstring item = raw.substr(start, end - start);
		const size_t equal = item.find(L'=');
		if (equal != std::wstring::npos) data[item.substr(0, equal)] = item.substr(equal + 1);
		start = end + 1;
	}
	return data;
}

static std::wstring valueOf(const Data &data, const wchar_t *key) {
	const auto it = data.find(key);
	return it == data.end() ? std::wstring() : it->second;
}

static Data customActionData(MSIHANDLE install) {
	return parseData(getProperty(install, L"CustomActionData"));
}

static bool isFlagSet(const std::wstring &value) {
	const std::wstring flag = trim(value);
	return !flag.empty() && flag != L"0";
}

static bool isForceClose(const std::wstring &force, const std::wstring &noForce) {
	if (isFlagSet(noForce)) return false;
	return trim(force) != L"0";
}

static DWORD closeTimeoutMs(const std::wstring &value) {
	const std::wstring text = trim(value);
	if (text.empty()) return DefaultCloseTimeoutSeconds * 1000;
	wchar_t *end = nullptr;
	unsigned long seconds = wcstoul(text.c_str(), &end, 10);
	if (end == text.c_str()) seconds = DefaultCloseTimeoutSeconds;
	if (seconds > MaxCloseTimeoutSeconds) seconds = MaxCloseTimeoutSeconds;
	return static_cast<DWORD>(seconds) * 1000;
}

static std::wstring serializeTargets(const std::set<Target> &targets) {
	std::wstring result;
	for (const auto &target : targets) {
		if (!result.empty()) result += L';';
		result += target.sid + L',' + std::to_wstring(target.session);
	}
	return result;
}

static std::set<Target> parseTargets(const std::wstring &raw) {
	std::set<Target> targets;
	size_t start = 0;
	while (start < raw.size()) {
		size_t end = raw.find(L';', start);
		if (end == std::wstring::npos) end = raw.size();
		const std::wstring item = raw.substr(start, end - start);
		const size_t comma = item.find(L',');
		if (comma != std::wstring::npos) {
			Target target;
			target.sid = trim(item.substr(0, comma));
			target.session = static_cast<DWORD>(wcstoul(item.c_str() + comma + 1, nullptr, 10));
			if (!target.sid.empty() && target.session != 0) targets.insert(target);
		}
		start = end + 1;
	}
	return targets;
}

static void enablePrivilege(const wchar_t *name) {
	HANDLE token = nullptr;
	if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &token)) return;
	TOKEN_PRIVILEGES privileges{};
	privileges.PrivilegeCount = 1;
	privileges.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
	if (LookupPrivilegeValueW(nullptr, name, &privileges.Privileges[0].Luid))
		AdjustTokenPrivileges(token, FALSE, &privileges, 0, nullptr, nullptr);
	CloseHandle(token);
}

static std::wstring tokenUserSid(HANDLE token) {
	DWORD size = 0;
	GetTokenInformation(token, TokenUser, nullptr, 0, &size);
	if (size == 0) return std::wstring();
	std::vector<BYTE> buffer(size);
	if (!GetTokenInformation(token, TokenUser, buffer.data(), size, &size)) return std::wstring();
	LPWSTR sidString = nullptr;
	if (!ConvertSidToStringSidW(reinterpret_cast<TOKEN_USER *>(buffer.data())->User.Sid, &sidString))
		return std::wstring();
	const std::wstring result = sidString;
	LocalFree(sidString);
	return result;
}

static std::wstring processOwnerSid(DWORD pid) {
	HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
	if (!process) return std::wstring();
	std::wstring result;
	HANDLE token = nullptr;
	if (OpenProcessToken(process, TOKEN_QUERY, &token)) {
		result = tokenUserSid(token);
		CloseHandle(token);
	}
	CloseHandle(process);
	return result;
}

static std::vector<RunningProcess> findProcesses(const std::wstring &exeName) {
	std::vector<RunningProcess> result;
	if (exeName.empty()) return result;
	HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (snapshot == INVALID_HANDLE_VALUE) return result;
	PROCESSENTRY32W entry{};
	entry.dwSize = sizeof(entry);
	const DWORD self = GetCurrentProcessId();
	for (BOOL found = Process32FirstW(snapshot, &entry); found; found = Process32NextW(snapshot, &entry)) {
		if (entry.th32ProcessID == self || _wcsicmp(entry.szExeFile, exeName.c_str()) != 0) continue;
		RunningProcess process;
		process.pid = entry.th32ProcessID;
		if (!ProcessIdToSessionId(process.pid, &process.session)) process.session = 0;
		process.sid = processOwnerSid(process.pid);
		result.push_back(process);
	}
	CloseHandle(snapshot);
	return result;
}

static bool signalQuitEvent(DWORD pid, const std::wstring &eventPrefix) {
	if (eventPrefix.empty()) return false;
	const std::wstring name = eventPrefix + std::to_wstring(pid);
	for (const wchar_t *scope : {L"Global\\", L"Local\\"}) {
		HANDLE event = OpenEventW(EVENT_MODIFY_STATE, FALSE, (std::wstring(scope) + name).c_str());
		if (!event) continue;
		const BOOL signaled = SetEvent(event);
		CloseHandle(event);
		if (signaled) return true;
	}
	return false;
}

struct WindowSearch {
	DWORD pid = 0;
	std::vector<HWND> windows;
};

static BOOL CALLBACK collectProcessWindows(HWND window, LPARAM parameter) {
	auto *search = reinterpret_cast<WindowSearch *>(parameter);
	DWORD pid = 0;
	GetWindowThreadProcessId(window, &pid);
	if (pid == search->pid) search->windows.push_back(window);
	return TRUE;
}

static bool sendEndSession(DWORD pid) {
	WindowSearch search;
	search.pid = pid;
	EnumWindows(collectProcessWindows, reinterpret_cast<LPARAM>(&search));
	if (search.windows.empty()) return false;
	DWORD_PTR result = 0;
	for (HWND window : search.windows)
		SendMessageTimeoutW(window, WM_QUERYENDSESSION, 0, ENDSESSION_CLOSEAPP, SMTO_ABORTIFHUNG, 5000, &result);
	for (HWND window : search.windows)
		SendMessageTimeoutW(window, WM_ENDSESSION, TRUE, ENDSESSION_CLOSEAPP, SMTO_ABORTIFHUNG, 5000, &result);
	return true;
}

static std::wstring currentModulePath() {
	HMODULE module = nullptr;
	if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
	                        reinterpret_cast<LPCWSTR>(&currentModulePath), &module))
		return std::wstring();
	std::wstring path(MAX_PATH, L'\0');
	for (;;) {
		const DWORD length = GetModuleFileNameW(module, &path[0], static_cast<DWORD>(path.size()));
		if (length == 0) return std::wstring();
		if (length < path.size()) {
			path.resize(length);
			return path;
		}
		if (path.size() >= 32768) return std::wstring();
		path.resize(path.size() * 2);
	}
}

static bool sendEndSessionFromSession(DWORD pid, DWORD session) {
	DWORD ownSession = 0;
	if (session == 0 || !ProcessIdToSessionId(GetCurrentProcessId(), &ownSession) || ownSession == session)
		return false;
	const std::wstring modulePath = currentModulePath();
	wchar_t systemDirectory[MAX_PATH] = {};
	const UINT systemLength = GetSystemDirectoryW(systemDirectory, MAX_PATH);
	if (modulePath.empty() || systemLength == 0 || systemLength >= MAX_PATH) return false;
	enablePrivilege(L"SeTcbPrivilege");
	enablePrivilege(L"SeAssignPrimaryTokenPrivilege");
	enablePrivilege(L"SeIncreaseQuotaPrivilege");
	HANDLE processToken = nullptr;
	if (!OpenProcessToken(GetCurrentProcess(), TOKEN_DUPLICATE | TOKEN_QUERY, &processToken)) return false;
	HANDLE token = nullptr;
	const BOOL duplicated =
	    DuplicateTokenEx(processToken, MAXIMUM_ALLOWED, nullptr, SecurityImpersonation, TokenPrimary, &token);
	CloseHandle(processToken);
	if (!duplicated) return false;
	if (!SetTokenInformation(token, TokenSessionId, &session, sizeof(session))) {
		CloseHandle(token);
		return false;
	}
	const std::wstring rundll = std::wstring(systemDirectory) + L"\\rundll32.exe";
	std::wstring commandLine = L"\"" + rundll + L"\" \"" + modulePath + L"\",EndSessionHelper " + std::to_wstring(pid);
	wchar_t desktop[] = L"winsta0\\default";
	STARTUPINFOW startup{};
	startup.cb = sizeof(startup);
	startup.lpDesktop = desktop;
	PROCESS_INFORMATION info{};
	const BOOL started = CreateProcessAsUserW(token, rundll.c_str(), &commandLine[0], nullptr, nullptr, FALSE,
	                                          CREATE_NO_WINDOW, nullptr, systemDirectory, &startup, &info);
	CloseHandle(token);
	if (!started) return false;
	CloseHandle(info.hThread);
	DWORD exitCode = 1;
	if (WaitForSingleObject(info.hProcess, TerminateWaitMs * 3) == WAIT_OBJECT_0)
		GetExitCodeProcess(info.hProcess, &exitCode);
	else TerminateProcess(info.hProcess, ERROR_TIMEOUT);
	CloseHandle(info.hProcess);
	return exitCode == 0;
}

static std::set<Target> closeApplications(MSIHANDLE install,
                                          const std::wstring &exeName,
                                          const std::wstring &eventPrefix,
                                          bool force,
                                          DWORD timeoutMs,
                                          bool deferUnreachable) {
	struct Tracked {
		RunningProcess process;
		HANDLE handle = nullptr;
		bool requested = false;
	};

	std::set<Target> closed;
	std::vector<Tracked> tracked;
	for (const auto &process : findProcesses(exeName)) {
		HANDLE handle =
		    OpenProcess(SYNCHRONIZE | PROCESS_TERMINATE | PROCESS_QUERY_LIMITED_INFORMATION, FALSE, process.pid);
		if (!handle) handle = OpenProcess(SYNCHRONIZE, FALSE, process.pid);
		if (!handle) {
			logMessage(install, L"Cannot open process " + std::to_wstring(process.pid) + L" (error " +
			                        std::to_wstring(GetLastError()) + L"), leaving it to the elevated pass.");
			continue;
		}
		Tracked entry;
		entry.process = process;
		entry.handle = handle;
		entry.requested = signalQuitEvent(process.pid, eventPrefix);
		if (entry.requested) {
			logMessage(install,
			           L"Requested graceful quit of process " + std::to_wstring(process.pid) + L" via IPC event.");
		} else if (sendEndSession(process.pid)) {
			entry.requested = true;
			logMessage(install,
			           L"Requested graceful quit of process " + std::to_wstring(process.pid) + L" via end session.");
		} else if (sendEndSessionFromSession(process.pid, process.session)) {
			entry.requested = true;
			logMessage(install, L"Requested graceful quit of process " + std::to_wstring(process.pid) +
			                        L" via end session from session " + std::to_wstring(process.session) + L".");
		} else if (deferUnreachable) {
			logMessage(install, L"No graceful channel reachable for process " + std::to_wstring(process.pid) +
			                        L", leaving it to the elevated pass.");
			CloseHandle(handle);
			continue;
		} else {
			logMessage(install, L"No graceful channel reachable for process " + std::to_wstring(process.pid) + L".");
		}
		tracked.push_back(entry);
	}

	const ULONGLONG deadline = GetTickCount64() + timeoutMs;
	for (auto &entry : tracked) {
		DWORD state = WAIT_TIMEOUT;
		if (entry.requested) {
			const ULONGLONG now = GetTickCount64();
			state = WaitForSingleObject(entry.handle, now < deadline ? static_cast<DWORD>(deadline - now) : 0);
		} else {
			state = WaitForSingleObject(entry.handle, 0);
		}
		if (state != WAIT_OBJECT_0 && force) {
			if (TerminateProcess(entry.handle, ERROR_PROCESS_ABORTED)) {
				logMessage(install, L"Forced termination of process " + std::to_wstring(entry.process.pid) + L".");
				state = WaitForSingleObject(entry.handle, TerminateWaitMs);
			} else {
				logMessage(install, L"Cannot terminate process " + std::to_wstring(entry.process.pid) + L" (error " +
				                        std::to_wstring(GetLastError()) + L").");
			}
		}
		if (state == WAIT_OBJECT_0) {
			logMessage(install, L"Process " + std::to_wstring(entry.process.pid) + L" has exited.");
			if (!entry.process.sid.empty() && entry.process.session != 0) {
				Target target;
				target.sid = entry.process.sid;
				target.session = entry.process.session;
				closed.insert(target);
			}
		} else {
			logMessage(install, L"Process " + std::to_wstring(entry.process.pid) + L" is still running.");
		}
		CloseHandle(entry.handle);
	}
	return closed;
}

static std::wstring readRegistryString(HKEY root, const std::wstring &subKey, const wchar_t *name, bool expand = true) {
	const DWORD flags = expand ? RRF_RT_REG_SZ : (RRF_RT_REG_SZ | RRF_RT_REG_EXPAND_SZ | RRF_NOEXPAND);
	DWORD size = 0;
	if (RegGetValueW(root, subKey.empty() ? nullptr : subKey.c_str(), name, flags, nullptr, nullptr, &size) !=
	        ERROR_SUCCESS ||
	    size < sizeof(wchar_t))
		return std::wstring();
	std::wstring value(size / sizeof(wchar_t) + 1, L'\0');
	size = static_cast<DWORD>(value.size() * sizeof(wchar_t));
	if (RegGetValueW(root, subKey.empty() ? nullptr : subKey.c_str(), name, flags, nullptr, &value[0], &size) !=
	    ERROR_SUCCESS)
		return std::wstring();
	value.resize(wcslen(value.c_str()));
	return value;
}

static std::set<Target> loadStoredTargets(const std::wstring &stateKey) {
	if (stateKey.empty()) return std::set<Target>();
	HKEY key = nullptr;
	if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, stateKey.c_str(), 0, KEY_QUERY_VALUE | KEY_WOW64_64KEY, &key) !=
	    ERROR_SUCCESS)
		return std::set<Target>();
	const std::set<Target> targets = parseTargets(readRegistryString(key, std::wstring(), L"Targets"));
	RegCloseKey(key);
	return targets;
}

static void storeTargets(MSIHANDLE install, const std::wstring &stateKey, const std::set<Target> &targets) {
	if (stateKey.empty() || targets.empty()) return;
	std::set<Target> all = loadStoredTargets(stateKey);
	all.insert(targets.begin(), targets.end());
	HKEY parent = nullptr;
	const std::wstring parentPath = parentDirectory(stateKey);
	if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, parentPath.c_str(), 0, nullptr, REG_OPTION_NON_VOLATILE,
	                    KEY_CREATE_SUB_KEY | KEY_WOW64_64KEY, nullptr, &parent, nullptr) != ERROR_SUCCESS) {
		logMessage(install, L"Cannot create registry key " + parentPath + L".");
		return;
	}
	RegCloseKey(parent);
	HKEY key = nullptr;
	if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, stateKey.c_str(), 0, nullptr, REG_OPTION_VOLATILE,
	                    KEY_SET_VALUE | KEY_WOW64_64KEY, nullptr, &key, nullptr) != ERROR_SUCCESS) {
		logMessage(install, L"Cannot create registry key " + stateKey + L".");
		return;
	}
	const std::wstring value = serializeTargets(all);
	RegSetValueExW(key, L"Targets", 0, REG_SZ, reinterpret_cast<const BYTE *>(value.c_str()),
	               static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t)));
	RegCloseKey(key);
}

static void deleteStoredTargets(const std::wstring &stateKey) {
	if (stateKey.empty()) return;
	RegDeleteKeyExW(HKEY_LOCAL_MACHINE, stateKey.c_str(), KEY_WOW64_64KEY, 0);
}

static HANDLE limitedPrimaryToken(HANDLE userToken) {
	TOKEN_ELEVATION_TYPE elevation = TokenElevationTypeDefault;
	DWORD size = 0;
	if (!GetTokenInformation(userToken, TokenElevationType, &elevation, sizeof(elevation), &size) ||
	    elevation != TokenElevationTypeFull)
		return nullptr;
	TOKEN_LINKED_TOKEN linked{};
	if (!GetTokenInformation(userToken, TokenLinkedToken, &linked, sizeof(linked), &size)) return nullptr;
	HANDLE primary = nullptr;
	if (!DuplicateTokenEx(linked.LinkedToken, MAXIMUM_ALLOWED, nullptr, SecurityIdentification, TokenPrimary, &primary))
		primary = nullptr;
	CloseHandle(linked.LinkedToken);
	return primary;
}

static bool launchInSession(MSIHANDLE install, const Target &target, const std::wstring &path) {
	HANDLE userToken = nullptr;
	if (!WTSQueryUserToken(target.session, &userToken)) {
		logMessage(install, L"No user token for session " + std::to_wstring(target.session) + L" (error " +
		                        std::to_wstring(GetLastError()) + L"), not relaunching.");
		return false;
	}
	if (!iequals(tokenUserSid(userToken), target.sid)) {
		logMessage(install,
		           L"Session " + std::to_wstring(target.session) + L" now belongs to another user, not relaunching.");
		CloseHandle(userToken);
		return false;
	}
	HANDLE limited = limitedPrimaryToken(userToken);
	HANDLE launchToken = limited ? limited : userToken;
	void *environment = nullptr;
	if (!CreateEnvironmentBlock(&environment, launchToken, FALSE)) environment = nullptr;
	wchar_t desktop[] = L"winsta0\\default";
	STARTUPINFOW startup{};
	startup.cb = sizeof(startup);
	startup.lpDesktop = desktop;
	PROCESS_INFORMATION info{};
	std::wstring commandLine = L"\"" + path + L"\"";
	const std::wstring directory = parentDirectory(path);
	const BOOL started = CreateProcessAsUserW(launchToken, path.c_str(), &commandLine[0], nullptr, nullptr, FALSE,
	                                          CREATE_UNICODE_ENVIRONMENT | NORMAL_PRIORITY_CLASS, environment,
	                                          directory.c_str(), &startup, &info);
	const DWORD error = GetLastError();
	if (environment) DestroyEnvironmentBlock(environment);
	if (limited) CloseHandle(limited);
	CloseHandle(userToken);
	if (!started) {
		logMessage(install, L"Cannot relaunch in session " + std::to_wstring(target.session) + L" (error " +
		                        std::to_wstring(error) + L").");
		return false;
	}
	CloseHandle(info.hThread);
	CloseHandle(info.hProcess);
	logMessage(install, L"Relaunched application in session " + std::to_wstring(target.session) + L".");
	return true;
}

static std::wstring knownFolder(REFKNOWNFOLDERID id) {
	PWSTR path = nullptr;
	if (FAILED(SHGetKnownFolderPath(id, KF_FLAG_DONT_VERIFY, nullptr, &path))) return std::wstring();
	const std::wstring result = path;
	CoTaskMemFree(path);
	return result;
}

static bool isSafeName(const std::wstring &name) {
	if (trim(name).empty() || name == L"." || name == L"..") return false;
	return name.find_first_of(L"\\/:*?\"<>|") == std::wstring::npos;
}

static bool isProtectedDirectory(const std::wstring &path) {
	const std::wstring candidate = withoutTrailingSeparator(fullPath(path));
	if (candidate.size() <= 3) return true;
	const KNOWNFOLDERID folders[] = {FOLDERID_Windows,
	                                 FOLDERID_System,
	                                 FOLDERID_SystemX86,
	                                 FOLDERID_ProgramFiles,
	                                 FOLDERID_ProgramFilesX86,
	                                 FOLDERID_ProgramFilesCommon,
	                                 FOLDERID_ProgramFilesCommonX86,
	                                 FOLDERID_ProgramData,
	                                 FOLDERID_UserProfiles,
	                                 FOLDERID_Public,
	                                 FOLDERID_PublicDesktop,
	                                 FOLDERID_CommonPrograms,
	                                 FOLDERID_CommonStartMenu};
	for (const auto &folder : folders) {
		const std::wstring known = withoutTrailingSeparator(knownFolder(folder));
		if (!known.empty() && iequals(known, candidate)) return true;
	}
	return false;
}

static void scheduleDeleteOnReboot(const std::wstring &path) {
	MoveFileExW(longPath(path).c_str(), nullptr, MOVEFILE_DELAY_UNTIL_REBOOT);
}

static void removeTree(const std::wstring &path) {
	const DWORD attributes = attributesOf(path);
	if (attributes == INVALID_FILE_ATTRIBUTES) return;
	if (!(attributes & FILE_ATTRIBUTE_DIRECTORY)) {
		SetFileAttributesW(longPath(path).c_str(), FILE_ATTRIBUTE_NORMAL);
		if (!DeleteFileW(longPath(path).c_str())) scheduleDeleteOnReboot(path);
		return;
	}
	if (attributes & FILE_ATTRIBUTE_REPARSE_POINT) {
		RemoveDirectoryW(longPath(path).c_str());
		return;
	}
	WIN32_FIND_DATAW entry{};
	HANDLE find = FindFirstFileExW(longPath(withTrailingSeparator(path) + L"*").c_str(), FindExInfoBasic, &entry,
	                               FindExSearchNameMatch, nullptr, 0);
	if (find != INVALID_HANDLE_VALUE) {
		do {
			const std::wstring name = entry.cFileName;
			if (name == L"." || name == L"..") continue;
			const std::wstring child = withTrailingSeparator(path) + name;
			if ((entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) &&
			    (entry.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)) {
				RemoveDirectoryW(longPath(child).c_str());
			} else {
				removeTree(child);
			}
		} while (FindNextFileW(find, &entry));
		FindClose(find);
	}
	SetFileAttributesW(longPath(path).c_str(), FILE_ATTRIBUTE_NORMAL);
	if (!RemoveDirectoryW(longPath(path).c_str())) scheduleDeleteOnReboot(path);
}

static std::wstring unquoteCommand(const std::wstring &command) {
	const std::wstring value = trim(command);
	if (!value.empty() && value.front() == L'"') {
		const size_t end = value.find(L'"', 1);
		return end == std::wstring::npos ? value.substr(1) : value.substr(1, end - 1);
	}
	return value;
}

static std::vector<NsisInstall> findNsisInstalls(const std::wstring &appName) {
	std::vector<NsisInstall> installs;
	if (!isSafeName(appName)) return installs;
	const std::wstring path = std::wstring(UninstallRoot) + L"\\" + appName;
	for (REGSAM view : {static_cast<REGSAM>(KEY_WOW64_64KEY), static_cast<REGSAM>(KEY_WOW64_32KEY)}) {
		HKEY key = nullptr;
		if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, path.c_str(), 0, KEY_READ | view, &key) != ERROR_SUCCESS) continue;
		NsisInstall install;
		install.view = view;
		install.uninstaller = unquoteCommand(readRegistryString(key, std::wstring(), L"UninstallString"));
		install.startMenu = readRegistryString(key, std::wstring(), L"StartMenu");
		install.desktop = trim(readRegistryString(key, std::wstring(), L"InstallToDesktop")) == L"1";
		RegCloseKey(key);
		if (!install.uninstaller.empty() && !iendsWith(install.uninstaller, L"\\Uninstall.exe")) continue;
		if (!install.uninstaller.empty())
			install.directory = withTrailingSeparator(parentDirectory(install.uninstaller));
		bool duplicate = false;
		for (const auto &existing : installs)
			duplicate =
			    duplicate || (!install.uninstaller.empty() && iequals(existing.uninstaller, install.uninstaller));
		if (!duplicate) installs.push_back(install);
	}
	return installs;
}

static bool runAndWait(MSIHANDLE install, const std::wstring &application, std::wstring commandLine, DWORD &exitCode) {
	STARTUPINFOW startup{};
	startup.cb = sizeof(startup);
	startup.dwFlags = STARTF_USESHOWWINDOW;
	startup.wShowWindow = SW_HIDE;
	PROCESS_INFORMATION info{};
	if (!CreateProcessW(application.c_str(), &commandLine[0], nullptr, nullptr, FALSE, CREATE_NO_WINDOW, nullptr,
	                    nullptr, &startup, &info)) {
		logMessage(install, L"Cannot start " + application + L" (error " + std::to_wstring(GetLastError()) + L").");
		return false;
	}
	CloseHandle(info.hThread);
	if (WaitForSingleObject(info.hProcess, NsisUninstallTimeoutMs) != WAIT_OBJECT_0) {
		logMessage(install, application + L" did not finish in time, terminating it.");
		TerminateProcess(info.hProcess, ERROR_TIMEOUT);
		WaitForSingleObject(info.hProcess, TerminateWaitMs);
		CloseHandle(info.hProcess);
		return false;
	}
	exitCode = 1;
	GetExitCodeProcess(info.hProcess, &exitCode);
	CloseHandle(info.hProcess);
	return true;
}

static void removeNsisShortcuts(const NsisInstall &nsis, const std::wstring &appName) {
	const std::wstring shortcutName = appName + L".lnk";
	if (isSafeName(nsis.startMenu)) {
		const std::wstring folder = withTrailingSeparator(knownFolder(FOLDERID_CommonPrograms)) + nsis.startMenu;
		DeleteFileW(longPath(withTrailingSeparator(folder) + L"Uninstall.lnk").c_str());
		DeleteFileW(longPath(withTrailingSeparator(folder) + shortcutName).c_str());
		RemoveDirectoryW(longPath(folder).c_str());
	}
	if (nsis.desktop)
		DeleteFileW(longPath(withTrailingSeparator(knownFolder(FOLDERID_PublicDesktop)) + shortcutName).c_str());
}

static void removeNsisRegistration(const std::wstring &appName, REGSAM view) {
	HKEY root = nullptr;
	if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, UninstallRoot, 0, KEY_ALL_ACCESS | view, &root) != ERROR_SUCCESS) return;
	RegDeleteTreeW(root, appName.c_str());
	RegCloseKey(root);
}

static void migrateNsisInstall(MSIHANDLE install,
                               const NsisInstall &nsis,
                               const std::wstring &appName,
                               const std::wstring &exeName,
                               bool msiUpgrade) {
	bool uninstalled = false;
	if (!nsis.uninstaller.empty() && fileExists(nsis.uninstaller)) {
		logMessage(install, L"Removing previous NSIS installation in " + nsis.directory + L".");
		std::wstring commandLine = L"\"" + nsis.uninstaller + L"\" /S _?=" + withoutTrailingSeparator(nsis.directory);
		DWORD exitCode = 1;
		if (runAndWait(install, nsis.uninstaller, commandLine, exitCode)) {
			logMessage(install, L"NSIS uninstaller exit code: " + std::to_wstring(exitCode) + L".");
			uninstalled = exitCode == 0;
		}
	}
	if (!nsis.directory.empty()) {
		if (!uninstalled && !msiUpgrade && fileExists(nsis.directory + L"bin\\" + exeName) &&
		    !isProtectedDirectory(nsis.directory)) {
			logMessage(install,
			           L"NSIS uninstall did not complete, removing " + nsis.directory + L" before overwrite install.");
			removeTree(nsis.directory);
		} else {
			if (fileExists(nsis.uninstaller)) {
				SetFileAttributesW(longPath(nsis.uninstaller).c_str(), FILE_ATTRIBUTE_NORMAL);
				if (!DeleteFileW(longPath(nsis.uninstaller).c_str())) scheduleDeleteOnReboot(nsis.uninstaller);
			}
			DeleteFileW(longPath(nsis.directory + L"AddRemove.exe").c_str());
			RemoveDirectoryW(longPath(nsis.directory).c_str());
		}
	}
	removeNsisShortcuts(nsis, appName);
	if (nsis.view) removeNsisRegistration(appName, nsis.view);
}

struct Hive {
	HKEY key = nullptr;
	std::wstring mountName;

	~Hive() {
		if (key) RegCloseKey(key);
		if (!mountName.empty()) RegUnLoadKeyW(HKEY_USERS, mountName.c_str());
	}
};

static void openHive(Hive &hive, const std::wstring &name, const std::wstring &file) {
	if (RegOpenKeyExW(HKEY_USERS, name.c_str(), 0, KEY_ALL_ACCESS, &hive.key) == ERROR_SUCCESS) return;
	hive.key = nullptr;
	if (!fileExists(file)) return;
	const std::wstring mountName = L"LinphonePurge-" + name;
	if (RegLoadKeyW(HKEY_USERS, mountName.c_str(), file.c_str()) != ERROR_SUCCESS) return;
	hive.mountName = mountName;
	if (RegOpenKeyExW(HKEY_USERS, mountName.c_str(), 0, KEY_ALL_ACCESS, &hive.key) != ERROR_SUCCESS) hive.key = nullptr;
}

static std::wstring
userShellFolder(HKEY userHive, const wchar_t *name, const std::wstring &profile, const std::wstring &fallback) {
	const std::wstring defaultPath = withTrailingSeparator(profile) + fallback;
	if (!userHive) return defaultPath;
	std::wstring value = readRegistryString(userHive, ShellFoldersKey, name, false);
	if (value.empty()) return defaultPath;
	const std::wstring token = L"%USERPROFILE%";
	if (istartsWith(value, token)) value = withoutTrailingSeparator(profile) + value.substr(token.size());
	if (value.find(L'%') != std::wstring::npos) return defaultPath;
	return value;
}

static bool pointsToRemovedApplication(const std::wstring &command, const std::wstring &installDir) {
	std::wstring target = unquoteCommand(command);
	for (size_t i = 0; i + 4 <= target.size(); ++i) {
		if (_wcsnicmp(target.c_str() + i, L".exe", 4) == 0) {
			target.resize(i + 4);
			break;
		}
	}
	if (target.empty()) return false;
	if (!installDir.empty() && istartsWith(target, withTrailingSeparator(installDir))) return true;
	return !fileExists(target);
}

static void purgeClassesRegistrations(HKEY classesRoot,
                                      const std::wstring &appName,
                                      const std::wstring &clsid,
                                      const std::wstring &installDir) {
	if (!classesRoot) return;
	if (isSafeName(appName)) RegDeleteTreeW(classesRoot, (L"AppUserModelId\\" + appName).c_str());
	if (clsid.empty()) return;
	const std::wstring clsidKey = L"CLSID\\{" + clsid + L"}";
	const std::wstring server = readRegistryString(classesRoot, clsidKey + L"\\LocalServer32", nullptr);
	if (pointsToRemovedApplication(server, installDir)) RegDeleteTreeW(classesRoot, clsidKey.c_str());
}

static void purgeUserRegistry(HKEY userHive,
                              const std::wstring &appName,
                              const std::wstring &exeName,
                              const std::wstring &vendor,
                              const std::wstring &clsid,
                              const std::wstring &installDir) {
	if (!userHive) return;
	HKEY classes = nullptr;
	if (RegOpenKeyExW(userHive, L"Software\\Classes", 0, KEY_ALL_ACCESS, &classes) == ERROR_SUCCESS) {
		purgeClassesRegistrations(classes, appName, clsid, installDir);
		RegCloseKey(classes);
	}
	HKEY run = nullptr;
	if (RegOpenKeyExW(userHive, RunKey, 0, KEY_QUERY_VALUE | KEY_SET_VALUE, &run) == ERROR_SUCCESS) {
		const std::wstring command = readRegistryString(run, std::wstring(), exeName.c_str());
		if (icontains(command, L"\\" + exeName + L".exe")) RegDeleteValueW(run, exeName.c_str());
		RegCloseKey(run);
	}
	if (isSafeName(vendor) && isSafeName(appName))
		RegDeleteTreeW(userHive, (L"Software\\" + vendor + L"\\" + appName).c_str());
}

static std::vector<std::pair<std::wstring, std::wstring>> userProfiles() {
	std::vector<std::pair<std::wstring, std::wstring>> profiles;
	HKEY list = nullptr;
	if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, ProfileListKey, 0, KEY_READ | KEY_WOW64_64KEY, &list) != ERROR_SUCCESS)
		return profiles;
	for (DWORD index = 0;; ++index) {
		wchar_t name[256];
		DWORD length = static_cast<DWORD>(sizeof(name) / sizeof(name[0]));
		if (RegEnumKeyExW(list, index, name, &length, nullptr, nullptr, nullptr, nullptr) != ERROR_SUCCESS) break;
		const std::wstring sid = name;
		if (!istartsWith(sid, L"S-1-5-21-") && !istartsWith(sid, L"S-1-12-1-")) continue;
		if (iendsWith(sid, L".bak")) continue;
		const std::wstring profile = readRegistryString(list, sid, L"ProfileImagePath");
		if (!profile.empty() && directoryExists(profile)) profiles.emplace_back(sid, profile);
	}
	RegCloseKey(list);
	return profiles;
}

extern "C" UINT __stdcall DetectNsisInstall(MSIHANDLE install) {
	const std::wstring appName = getProperty(install, L"LINPHONE_APP_NAME");
	const std::wstring defaultX86 =
	    withTrailingSeparator(getProperty(install, L"ProgramFilesFolder")) + appName + L"\\";
	for (const auto &nsis : findNsisInstalls(appName)) {
		if (nsis.directory.empty() || !directoryExists(nsis.directory)) continue;
		logMessage(install, L"Found NSIS installation in " + nsis.directory + L".");
		if (iequals(nsis.directory, defaultX86)) continue;
		MsiSetPropertyW(install, L"LINPHONE_NSIS_INSTALL_DIR", nsis.directory.c_str());
		break;
	}
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall CloseApplicationsImmediate(MSIHANDLE install) {
	const std::set<Target> closed = closeApplications(
	    install, getProperty(install, L"LINPHONE_EXE_NAME"), getProperty(install, L"LINPHONE_QUIT_EVENT"),
	    isForceClose(getProperty(install, L"FORCECLOSE"), getProperty(install, L"NOFORCECLOSE")),
	    closeTimeoutMs(getProperty(install, L"CLOSETIMEOUT")), _wtoi(getProperty(install, L"UILevel").c_str()) < 5);
	std::set<Target> targets = parseTargets(getProperty(install, L"LINPHONE_RESTART_TARGETS"));
	targets.insert(closed.begin(), closed.end());
	MsiSetPropertyW(install, L"LINPHONE_RESTART_TARGETS", serializeTargets(targets).c_str());
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall CloseApplicationsDeferred(MSIHANDLE install) {
	const Data data = customActionData(install);
	const std::set<Target> closed = closeApplications(install, valueOf(data, L"exe"), valueOf(data, L"event"),
	                                                  isForceClose(valueOf(data, L"force"), valueOf(data, L"noforce")),
	                                                  closeTimeoutMs(valueOf(data, L"timeout")), false);
	if (!iequals(trim(valueOf(data, L"remove")), L"ALL")) storeTargets(install, valueOf(data, L"state"), closed);
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall MigrateNsisInstall(MSIHANDLE install) {
	const Data data = customActionData(install);
	const std::wstring appName = valueOf(data, L"app");
	const std::wstring exeName = valueOf(data, L"exe");
	const std::wstring installDir = withTrailingSeparator(valueOf(data, L"installdir"));
	const bool msiUpgrade = !trim(valueOf(data, L"upgrade")).empty();
	bool installDirHandled = false;
	for (const auto &nsis : findNsisInstalls(appName)) {
		migrateNsisInstall(install, nsis, appName, exeName, msiUpgrade);
		installDirHandled = installDirHandled || (!nsis.directory.empty() && iequals(nsis.directory, installDir));
	}
	if (!installDirHandled && !installDir.empty() && fileExists(installDir + L"Uninstall.exe") &&
	    fileExists(installDir + L"bin\\" + exeName)) {
		logMessage(install, L"Found unregistered NSIS files in " + installDir + L".");
		NsisInstall orphan;
		orphan.uninstaller = installDir + L"Uninstall.exe";
		orphan.directory = installDir;
		migrateNsisInstall(install, orphan, appName, exeName, msiUpgrade);
	}
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall RestartApplications(MSIHANDLE install) {
	const Data data = customActionData(install);
	const std::wstring stateKey = valueOf(data, L"state");
	std::set<Target> targets = parseTargets(valueOf(data, L"targets"));
	const std::set<Target> stored = loadStoredTargets(stateKey);
	targets.insert(stored.begin(), stored.end());
	deleteStoredTargets(stateKey);
	if (targets.empty()) return ERROR_SUCCESS;
	const std::wstring path = valueOf(data, L"path");
	if (!fileExists(path)) {
		logMessage(install, L"Cannot relaunch, " + path + L" does not exist.");
		return ERROR_SUCCESS;
	}
	enablePrivilege(L"SeTcbPrivilege");
	enablePrivilege(L"SeAssignPrimaryTokenPrivilege");
	enablePrivilege(L"SeIncreaseQuotaPrivilege");
	const std::vector<RunningProcess> running = findProcesses(valueOf(data, L"exe"));
	for (const auto &target : targets) {
		bool alreadyRunning = false;
		for (const auto &process : running)
			alreadyRunning = alreadyRunning || (process.session == target.session && iequals(process.sid, target.sid));
		if (alreadyRunning) {
			logMessage(install, L"Application already running in session " + std::to_wstring(target.session) + L".");
			continue;
		}
		launchInSession(install, target, path);
	}
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall AskPurgeUserData(MSIHANDLE install) {
	const std::wstring sid = trim(getProperty(install, L"UserSID"));
	const std::wstring question = getProperty(install, L"LINPHONE_PURGE_QUESTION");
	if (sid.empty() || question.empty()) return ERROR_SUCCESS;
	PMSIHANDLE record = MsiCreateRecord(0);
	MsiRecordSetStringW(record, 0, question.c_str());
	wchar_t empty[1] = L"";
	DWORD size = 0;
	if (MsiFormatRecordW(install, record, empty, &size) == ERROR_MORE_DATA) {
		std::wstring text(size + 1, L'\0');
		size = static_cast<DWORD>(text.size());
		if (MsiFormatRecordW(install, record, &text[0], &size) == ERROR_SUCCESS) {
			text.resize(size);
			MsiRecordSetStringW(record, 0, text.c_str());
		}
	}
	const int answer = MsiProcessMessage(
	    install, static_cast<INSTALLMESSAGE>(INSTALLMESSAGE_USER | MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2), record);
	if (answer != IDYES) return ERROR_SUCCESS;
	logMessage(install, L"User data of " + sid + L" will be removed.");
	MsiSetPropertyW(install, L"LINPHONE_PURGE_USER", sid.c_str());
	MsiSetPropertyW(install, L"PURGE", L"1");
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall PurgeUserData(MSIHANDLE install) {
	const Data data = customActionData(install);
	const std::wstring appName = valueOf(data, L"app");
	const std::wstring exeName = valueOf(data, L"exe");
	const std::wstring vendor = valueOf(data, L"vendor");
	const std::wstring clsid = valueOf(data, L"clsid");
	const std::wstring installDir = withTrailingSeparator(valueOf(data, L"installdir"));
	const std::wstring onlyUser = trim(valueOf(data, L"user"));
	if (!isSafeName(exeName)) {
		logMessage(install, L"Invalid executable name, skipping purge.");
		return ERROR_SUCCESS;
	}
	enablePrivilege(L"SeBackupPrivilege");
	enablePrivilege(L"SeRestorePrivilege");
	for (const auto &profile : userProfiles()) {
		const std::wstring &sid = profile.first;
		const std::wstring &profilePath = profile.second;
		if (!onlyUser.empty() && !iequals(sid, onlyUser)) continue;
		{
			Hive user;
			openHive(user, sid, withTrailingSeparator(profilePath) + L"NTUSER.DAT");
			const std::wstring local = userShellFolder(user.key, L"Local AppData", profilePath, L"AppData\\Local");
			const std::wstring roaming = userShellFolder(user.key, L"AppData", profilePath, L"AppData\\Roaming");
			for (const auto &base : {local, roaming}) {
				const std::wstring target = withTrailingSeparator(base) + exeName;
				if (!directoryExists(target)) continue;
				logMessage(install, L"Removing user data " + target + L".");
				removeTree(target);
			}
			purgeUserRegistry(user.key, appName, exeName, vendor, clsid, installDir);
			Hive classes;
			openHive(classes, sid + L"_Classes", withTrailingSeparator(local) + L"Microsoft\\Windows\\UsrClass.dat");
			purgeClassesRegistrations(classes.key, appName, clsid, installDir);
		}
	}
	return ERROR_SUCCESS;
}

extern "C" UINT __stdcall LaunchApplication(MSIHANDLE install) {
	const std::wstring path =
	    withTrailingSeparator(getProperty(install, L"INSTALL_ROOT")) + getProperty(install, L"LINPHONE_EXE_RELATIVE");
	if (!fileExists(path)) {
		logMessage(install, L"Cannot launch, " + path + L" does not exist.");
		return ERROR_SUCCESS;
	}
	const HRESULT com = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
	const std::wstring directory = parentDirectory(path);
	ShellExecuteW(nullptr, L"open", path.c_str(), nullptr, directory.c_str(), SW_SHOWNORMAL);
	if (SUCCEEDED(com)) CoUninitialize();
	return ERROR_SUCCESS;
}

extern "C" void CALLBACK EndSessionHelperW(HWND, HINSTANCE, LPWSTR commandLine, int) {
	const DWORD pid = commandLine ? wcstoul(commandLine, nullptr, 10) : 0;
	ExitProcess(pid != 0 && sendEndSession(pid) ? 0 : 1);
}
