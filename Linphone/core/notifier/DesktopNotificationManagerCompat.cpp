// ******************************************************************
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THE CODE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
// THE CODE OR THE USE OR OTHER DEALINGS IN THE CODE.
// ******************************************************************
#include <shlobj.h>

#include "DesktopNotificationManagerCompat.hpp"
#include "NotificationActivator.hpp"
#include <NotificationActivationCallback.h>
#include <windows.ui.notifications.h>

#include <appmodel.h>
#include <wrl\wrappers\corewrappers.h>

#include <propkey.h>
#include <propvarutil.h>

#include "core/App.hpp"

#pragma comment(lib, "propsys.lib")

using namespace ABI::Windows::Data::Xml::Dom;
using namespace ABI::Windows::UI::Notifications;
using namespace Microsoft::WRL;

#define RETURN_IF_FAILED(hr)                                                                                           \
	do {                                                                                                               \
		HRESULT _hrTemp = hr;                                                                                          \
		if (FAILED(_hrTemp)) {                                                                                         \
			return _hrTemp;                                                                                            \
		}                                                                                                              \
	} while (false)

using namespace ABI::Windows::Data::Xml::Dom;
using namespace Microsoft::WRL::Wrappers;

namespace DesktopNotificationManagerCompat {
HRESULT RegisterComServer(GUID clsid, const wchar_t exePath[]);
HRESULT RegisterAumidInRegistry(const wchar_t *aumid, const wchar_t *iconPath = nullptr);
HRESULT EnsureRegistered();
bool IsRunningAsUwp();

bool s_registeredAumidAndComServer = false;
std::wstring s_aumid;
bool s_registeredActivator = false;
bool s_hasCheckedIsRunningAsUwp = false;
bool s_isRunningAsUwp = false;

DWORD g_comCookie = 0;

HRESULT CreateStartMenuShortcut(const wchar_t *aumid, GUID clsid) {
	// Chemin de destination du raccourci
	wchar_t shortcutPath[MAX_PATH];
	SHGetFolderPathW(nullptr, CSIDL_PROGRAMS, nullptr, 0, shortcutPath);
	wcsncat_s(shortcutPath, L"\\" APPLICATION_NAME L".lnk", MAX_PATH);

	// Créer le IShellLink
	ComPtr<IShellLinkW> shellLink;
	HRESULT hr = CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&shellLink));
	if (FAILED(hr)) return hr;

	// Pointer vers l'exe courant
	wchar_t exePath[MAX_PATH];
	GetModuleFileNameW(nullptr, exePath, MAX_PATH);
	qDebug() << "EXE path for shortcut:" << QString::fromWCharArray(exePath);
	shellLink->SetPath(exePath);
	shellLink->SetArguments(L"");

	// Définir les propriétés AUMID + ToastActivatorCLSID
	ComPtr<IPropertyStore> propStore;
	hr = shellLink.As(&propStore);
	if (FAILED(hr)) return hr;

	PROPVARIANT pv;

	// AUMID
	InitPropVariantFromString(aumid, &pv);
	propStore->SetValue(PKEY_AppUserModel_ID, pv);
	PropVariantClear(&pv);

	// Toast Activator CLSID
	InitPropVariantFromCLSID(clsid, &pv);
	propStore->SetValue(PKEY_AppUserModel_ToastActivatorCLSID, pv);
	PropVariantClear(&pv);

	propStore->Commit();

	// Sauvegarder le fichier .lnk
	ComPtr<IPersistFile> persistFile;
	hr = shellLink.As(&persistFile);
	if (FAILED(hr)) return hr;

	return persistFile->Save(shortcutPath, TRUE);
}

HRESULT RegisterAumidInRegistry(const wchar_t *aumid, const wchar_t *iconPath) {
	std::wstring keyPath = std::wstring(L"Software\\Classes\\AppUserModelId\\") + aumid;

	HKEY key;
	LONG res = ::RegCreateKeyExW(HKEY_CURRENT_USER, keyPath.c_str(), 0, nullptr, REG_OPTION_NON_VOLATILE, KEY_WRITE,
	                             nullptr, &key, nullptr);

	if (res != ERROR_SUCCESS) return HRESULT_FROM_WIN32(res);

	// DisplayName obligatoire pour que Windows affiche la notification
	const wchar_t *displayName = aumid;
	res = ::RegSetValueExW(key, L"DisplayName", 0, REG_SZ, reinterpret_cast<const BYTE *>(displayName),
	                       static_cast<DWORD>((wcslen(displayName) + 1) * sizeof(wchar_t)));

	if (iconPath != nullptr) {
		res = ::RegSetValueExW(key, L"IconUri", 0, REG_SZ, reinterpret_cast<const BYTE *>(iconPath),
		                       static_cast<DWORD>((wcslen(iconPath) + 1) * sizeof(wchar_t)));
	}

	::RegCloseKey(key);
	return HRESULT_FROM_WIN32(res);
}

HRESULT RegisterAumidAndComServer(const wchar_t *aumid, GUID clsid, const wchar_t *iconPath) {
	// If running as Desktop Bridge
	qDebug() << QString("CLSID : {%1-%2-%3-%4%5-%6%7%8%9%10%11}")
	                .arg(clsid.Data1, 8, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data2, 4, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data3, 4, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[0], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[1], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[2], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[3], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[4], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[5], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[6], 2, 16, QChar('0'))
	                .toUpper()
	                .arg(clsid.Data4[7], 2, 16, QChar('0'))
	                .toUpper();
	if (IsRunningAsUwp()) {
		// Clear the AUMID since Desktop Bridge doesn't use it, and then we're done.
		// Desktop Bridge apps are registered with platform through their manifest.
		// Their LocalServer32 key is also registered through their manifest.
		qInfo() << "clear AUMID as it is not needed";

		s_aumid = L"";
		s_registeredAumidAndComServer = true;
		return S_OK;
	}

	// Copy the aumid
	s_aumid = std::wstring(aumid);
	qDebug() << "S_AUMID:" << s_aumid;

	// Get the EXE path
	wchar_t exePath[MAX_PATH];
	DWORD charWritten = ::GetModuleFileName(nullptr, exePath, ARRAYSIZE(exePath));
	RETURN_IF_FAILED(charWritten > 0 ? S_OK : HRESULT_FROM_WIN32(::GetLastError()));

	// Register the COM server
	qInfo() << "Register com server and aumid";
	RETURN_IF_FAILED(RegisterComServer(clsid, exePath));

	qInfo() << "Register aumid in registry";
	RETURN_IF_FAILED(RegisterAumidInRegistry(aumid, iconPath));

	s_registeredAumidAndComServer = true;
	return S_OK;
}

HRESULT RegisterActivator() {
	// Module<OutOfProc> needs a callback registered before it can be used.
	// Since we don't care about when it shuts down, we'll pass an empty lambda here.
	Module<OutOfProc>::Create([] {});

	// If a local server process only hosts the COM object then COM expects
	// the COM server host to shutdown when the references drop to zero.
	// Since the user might still be using the program after activating the notification,
	// we don't want to shutdown immediately.  Incrementing the object count tells COM that
	// we aren't done yet.
	Module<OutOfProc>::GetModule().IncrementObjectCount();

	// HRESULT hr = CoRegisterClassObject(__uuidof(NotificationActivator), factory, CLSCTX_LOCAL_SERVER,
	//                                    REGCLS_MULTIPLEUSE, &g_comCookie);

	// qInfo() << "CoRegisterClassObject result:" << Qt::hex << hr << "Cookie:" << g_comCookie;

	// factory->Release();

	auto hr = Module<OutOfProc>::GetModule().RegisterObjects();
	qInfo() << "RegisterObjects result:" << Qt::hex << hr;

	if (FAILED(hr)) {
		qWarning() << "CoRegisterClassObject ÉCHOUÉ ? Activate() jamais appelé !";
		return hr;
	}

	s_registeredActivator = true;
	return S_OK;
}

HRESULT RegisterComServer(GUID clsid, const wchar_t exePath[]) {
	// Turn the GUID into a string
	OLECHAR *clsidOlechar;
	StringFromCLSID(clsid, &clsidOlechar);
	std::wstring clsidStr(clsidOlechar);
	::CoTaskMemFree(clsidOlechar);

	// Create the subkey
	// Something like SOFTWARE\Classes\CLSID\{23A5B06E-20BB-4E7E-A0AC-6982ED6A6041}\LocalServer32
	std::wstring subKey = LR"(SOFTWARE\Classes\CLSID\)" + clsidStr + LR"(\LocalServer32)";

	// Include -ToastActivated launch args on the exe
	std::wstring exePathStr(exePath);
	exePathStr = L"\"" + exePathStr + L"\" " + TOAST_ACTIVATED_LAUNCH_ARG;

	// We don't need to worry about overflow here as ::GetModuleFileName won't
	// return anything bigger than the max file system path (much fewer than max of DWORD).
	DWORD dataSize = static_cast<DWORD>((exePathStr.length() + 1) * sizeof(WCHAR));

	// Register the EXE for the COM server
	return HRESULT_FROM_WIN32(::RegSetKeyValue(HKEY_CURRENT_USER, subKey.c_str(), nullptr, REG_SZ,
	                                           reinterpret_cast<const BYTE *>(exePathStr.c_str()), dataSize));
}

HRESULT CreateToastNotifier(IToastNotifier **notifier) {
	RETURN_IF_FAILED(EnsureRegistered());

	ComPtr<IToastNotificationManagerStatics> toastStatics;
	RETURN_IF_FAILED(Windows::Foundation::GetActivationFactory(
	    HStringReference(RuntimeClass_Windows_UI_Notifications_ToastNotificationManager).Get(), &toastStatics));

	if (s_aumid.empty()) {
		return toastStatics->CreateToastNotifier(notifier);
	} else {
		return toastStatics->CreateToastNotifierWithId(HStringReference(s_aumid.c_str()).Get(), notifier);
	}
}

HRESULT CreateXmlDocumentFromString(const wchar_t *xmlString, IXmlDocument **doc) {
	ComPtr<IXmlDocument> answer;
	RETURN_IF_FAILED(Windows::Foundation::ActivateInstance(
	    HStringReference(RuntimeClass_Windows_Data_Xml_Dom_XmlDocument).Get(), &answer));

	ComPtr<IXmlDocumentIO> docIO;
	RETURN_IF_FAILED(answer.As(&docIO));

	// Load the XML string
	RETURN_IF_FAILED(docIO->LoadXml(HStringReference(xmlString).Get()));

	return answer.CopyTo(doc);
}

HRESULT CreateToastNotification(IXmlDocument *content, IToastNotification **notification) {
	ComPtr<IToastNotificationFactory> factory;
	RETURN_IF_FAILED(Windows::Foundation::GetActivationFactory(
	    HStringReference(RuntimeClass_Windows_UI_Notifications_ToastNotification).Get(), &factory));

	return factory->CreateToastNotification(content, notification);
}

HRESULT get_History(std::unique_ptr<DesktopNotificationHistoryCompat> *history) {
	RETURN_IF_FAILED(EnsureRegistered());

	ComPtr<IToastNotificationManagerStatics> toastStatics;
	RETURN_IF_FAILED(Windows::Foundation::GetActivationFactory(
	    HStringReference(RuntimeClass_Windows_UI_Notifications_ToastNotificationManager).Get(), &toastStatics));

	ComPtr<IToastNotificationManagerStatics2> toastStatics2;
	RETURN_IF_FAILED(toastStatics.As(&toastStatics2));

	ComPtr<IToastNotificationHistory> nativeHistory;
	RETURN_IF_FAILED(toastStatics2->get_History(&nativeHistory));

	*history = std::unique_ptr<DesktopNotificationHistoryCompat>(
	    new DesktopNotificationHistoryCompat(s_aumid.c_str(), nativeHistory));
	return S_OK;
}

bool CanUseHttpImages() {
	return IsRunningAsUwp();
}

HRESULT EnsureRegistered() {
	// If not registered AUMID yet
	if (!s_registeredAumidAndComServer) {
		// Check if Desktop Bridge
		if (IsRunningAsUwp()) {
			// Implicitly registered, all good!
			s_registeredAumidAndComServer = true;
		} else {
			// Otherwise, incorrect usage, must call RegisterAumidAndComServer first
			return E_ILLEGAL_METHOD_CALL;
		}
	}

	// If not registered activator yet
	if (!s_registeredActivator) {
		// Incorrect usage, must call RegisterActivator first
		return E_ILLEGAL_METHOD_CALL;
	}

	return S_OK;
}

bool IsRunningAsUwp() {
	if (!s_hasCheckedIsRunningAsUwp) {
		// https://stackoverflow.com/questions/39609643/determine-if-c-application-is-running-as-a-uwp-app-in-desktop-bridge-project
		UINT32 length;
		wchar_t packageFamilyName[PACKAGE_FAMILY_NAME_MAX_LENGTH + 1];
		LONG result = GetPackageFamilyName(GetCurrentProcess(), &length, packageFamilyName);
		s_isRunningAsUwp = result == ERROR_SUCCESS;
		s_hasCheckedIsRunningAsUwp = true;
	}

	return s_isRunningAsUwp;
}
} // namespace DesktopNotificationManagerCompat

DesktopNotificationHistoryCompat::DesktopNotificationHistoryCompat(const wchar_t *aumid,
                                                                   ComPtr<IToastNotificationHistory> history) {
	m_aumid = std::wstring(aumid);
	m_history = history;
}

HRESULT DesktopNotificationHistoryCompat::Clear() {
	if (m_aumid.empty()) {
		return m_history->Clear();
	} else {
		return m_history->ClearWithId(HStringReference(m_aumid.c_str()).Get());
	}
}

HRESULT DesktopNotificationHistoryCompat::GetHistory(
    ABI::Windows::Foundation::Collections::IVectorView<ToastNotification *> **toasts) {
	ComPtr<IToastNotificationHistory2> history2;
	RETURN_IF_FAILED(m_history.As(&history2));

	if (m_aumid.empty()) {
		return history2->GetHistory(toasts);
	} else {
		return history2->GetHistoryWithId(HStringReference(m_aumid.c_str()).Get(), toasts);
	}
}

HRESULT DesktopNotificationHistoryCompat::Remove(const wchar_t *tag) {
	if (m_aumid.empty()) {
		return m_history->Remove(HStringReference(tag).Get());
	} else {
		return m_history->RemoveGroupedTagWithId(HStringReference(tag).Get(), HStringReference(L"").Get(),
		                                         HStringReference(m_aumid.c_str()).Get());
	}
}

HRESULT DesktopNotificationHistoryCompat::RemoveGroupedTag(const wchar_t *tag, const wchar_t *group) {
	if (m_aumid.empty()) {
		return m_history->RemoveGroupedTag(HStringReference(tag).Get(), HStringReference(group).Get());
	} else {
		return m_history->RemoveGroupedTagWithId(HStringReference(tag).Get(), HStringReference(group).Get(),
		                                         HStringReference(m_aumid.c_str()).Get());
	}
}

HRESULT DesktopNotificationHistoryCompat::RemoveGroup(const wchar_t *group) {
	if (m_aumid.empty()) {
		return m_history->RemoveGroup(HStringReference(group).Get());
	} else {
		return m_history->RemoveGroupWithId(HStringReference(group).Get(), HStringReference(m_aumid.c_str()).Get());
	}
}
