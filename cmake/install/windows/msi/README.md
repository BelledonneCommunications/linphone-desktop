# Windows MSI installer

The Windows package is a per-machine MSI built by CPack with the WiX .NET tool (v5, `CPACK_WIX_VERSION 4`).
`-DENABLE_WINDOWS_MSI=OFF` restores the legacy NSIS installer.

## Build prerequisites

- CMake 3.30 or newer
- .NET SDK, then:

```
dotnet tool install --global wix --version 5.0.2
wix extension add --global WixToolset.UI.wixext/5.0.2
```

WiX 6 and later need the paid Open Source Maintenance Fee EULA, so the version stays pinned to 5.x
(`LINPHONE_WIX_VERSION`). With `-DENABLE_WINDOWS_TOOLS_CHECK=ON` CMake installs the tool by itself.

The UpgradeCode is derived from `APPLICATION_VENDOR` and `APPLICATION_NAME`, so every derived application automatically gets
its own stable product identity. It is printed at configure time and can be forced
with `-DLINPHONE_WIX_UPGRADE_GUID=...`. Never change it after a release, or upgrades stop replacing the old version.

## Branding

The installer dialogs use two 24-bit BMP files, overridable at configure time:

| Option | Size | Where |
|---|---|---|
| `LINPHONE_MSI_UI_DIALOG` | 493x312 | Welcome and completion dialogs; only the left 164 pixels are not covered by text |
| `LINPHONE_MSI_UI_BANNER` | 493x58 | Top of every other dialog; the right side is not covered by text |

The Add/Remove Programs icon comes from `Linphone/data/icon.ico`. Windows always shows the `.msi` file and the
installer window with the stock Windows Installer icon: a custom icon there would need an `.exe` bootstrapper.

## Languages

A single MSI holds every language. CPack builds it in English (`en-US.wxl`); a post-build step
(`languages.cmake.in`) then rebuilds the same sources once per culture of `LINPHONE_MSI_EXTRA_CULTURES` (default
`fr-FR`), turns each one into a language transform with `wix msi transform -t language` and embeds it in the English
MSI (`EmbedLanguageTransform.ps1`), named after its language identifier and listed in the package languages. Windows
Installer then applies the transform matching the Windows display language by itself; any other language gets English.

The WiX dialogs come translated with `WixToolset.UI.wixext`. The strings specific to this package (purge question,
downgrade message, launch checkbox) live in `<culture>.wxl`. To add a language, copy `en-US.wxl` to the new culture,
translate it, set `LinphoneLanguage` to its language identifier and append the culture to
`LINPHONE_MSI_EXTRA_CULTURES`.

Sign the MSI after packaging: embedding a transform rewrites the file.

## Command line

| Need | NSIS-style switch | MSI command line |
|---|---|---|
| Silent install | `/S` | `msiexec /i Linphone.msi /qn` |
| Silent uninstall | `/S` | `msiexec /x Linphone.msi /qn` or `msiexec /x {ProductCode} /qn` |
| Install folder | `/D=<path>` | `INSTALLDIR="<path>"` |
| Force closing the running app (default) | `/FORCECLOSE` | `FORCECLOSE=1` |
| Never kill the running app | `/NOFORCECLOSE` | `NOFORCECLOSE=1` (or `FORCECLOSE=0`) |
| Graceful close timeout in seconds (default 30, max 600) | | `CLOSETIMEOUT=<seconds>` |
| Relaunch the app after update (default) | `/RESTARTAPP` | `RESTARTAPP=1`, disable with `RESTARTAPP=0` |
| Remove user data on uninstall | `/PURGE` | `msiexec /x ... /qn PURGE=1` |
| Log file | `/LOG=<file>` | `/l*v "<file>"` (or `/log "<file>"`) |
| Installer language (default: Windows display language) | | `ProductLanguage=1033` (English) or `ProductLanguage=1036` (French) |
| Repair | | `msiexec /famus Linphone.msi /qn` (files and registry), or simply run the same MSI again |

Without any switch, Windows Installer still writes a verbose log `MSI*.LOG` in `%TEMP%` (`C:\Windows\Temp` when run
as SYSTEM) because the package sets `MsiLogging`.

Example of an unattended update from a deployment tool:

```
msiexec /i Linphone-6.2.0-win64.msi /qn /norestart /l*v C:\Logs\linphone-update.log
```

## Exit codes

These are the standard Windows Installer codes, they are stable across versions.

| Code | Meaning |
|---|---|
| 0 | Success |
| 3010 | Success, a reboot is required to finish (files were in use, typically with `NOFORCECLOSE=1`) |
| 1641 | Success, the installer started a reboot (only without `/norestart`) |
| 1602 | Cancelled by the user (interactive installs only) |
| 1603 | Fatal error, see the log. Also returned when a newer version is already installed (downgrade refused) |
| 1605 | Uninstall requested for a product that is not installed |
| 1618 | Another installation is already in progress, retry later |
| 1619 / 1620 | The package cannot be opened / is not a valid package |
| 1625 | Installation forbidden by system policy |
| 1638 | Another version of this exact package is installed (rebuild with a new ProductCode) |
| 1639 | Invalid command line |

## Behaviour

**Running application.** Before any file is touched, the installer asks every running instance (all users and
sessions) to quit: it signals the per-process event `Global\<exe>-installer-quit-<pid>` created by the application,
or for older versions sends `WM_QUERYENDSESSION`/`WM_ENDSESSION` to its windows. When the installer runs in another
session than the application (remote or SYSTEM deployment), the elevated part of the installer sends these messages
through a short-lived `rundll32` helper started in the application's session. After `CLOSETIMEOUT` seconds, any
instance still running is terminated unless `NOFORCECLOSE=1`; in that case the locked files are replaced at the next
reboot and the exit code is 3010. In the interactive UI, an instance that refuses to quit is reported by the standard
"files in use" dialog.

**Restart.** Every instance closed by the installer is relaunched at the end of a successful install, upgrade or
repair, in its original user's session and with that user's non-elevated token. It reopens hidden in the tray if it was
hidden when it was closed. If the installation fails and rolls back, the previous version is relaunched instead.
Instances closed during an uninstall are not relaunched.

**Upgrade.** Installing a newer or identical version replaces the previous one in a single transaction and keeps its
install folder. User data (`%LOCALAPPDATA%\<exe>`: configuration, `linphone.db`, `lime.db`, logs, ...) is never touched
by an install, upgrade, repair or normal uninstall. Installing an older version than the one installed is refused.

**Migration from NSIS.** When an NSIS installation of the same application is found, it is closed, then uninstalled
silently before the MSI files are copied, and the MSI reuses its folder (except the default `Program Files (x86)`
location, which moves to `Program Files`). If its uninstaller is missing or fails, the old files, uninstall entry and
shortcuts are cleaned up and the MSI overwrites the folder. Note that an NSIS installation cannot be restored if the MSI
installation later fails.

**Repair.** Running the same MSI again repairs the installation (`REINSTALL=ALL`), and every install forces all files
to be rewritten (`REINSTALLMODE=amus`), so missing or corrupted files and registry entries are restored, including
when the previous registration is missing.

**Protocols.** The installer registers the same `sip`, `sips`, `tel`, `callto`, `sip-<exe>`, `<exe>-sip`,
`sips-<exe>`, `<exe>-sips` and `<exe>-config` handlers, `RegisteredApplications` capabilities and IM provider as the
NSIS installer. The generic `sip`, `sips`, `tel` and `callto` declarations are shared with other applications and stay
in place after an uninstall, as they did with NSIS.

**Purge.** `PURGE=1` on uninstall also deletes, for every user profile of the machine, `%LOCALAPPDATA%\<exe>`,
`%APPDATA%\<exe>`, the autostart entry, the notification registration and the per-user settings key.
When `PURGE` is not given, an uninstall with a user interface (Windows Settings, Add/Remove Programs, `msiexec /x`
without `/qn`) asks whether to delete the data; answering Yes removes the same items for the user running the
uninstall only. `PURGE=0` keeps the data without asking. Silent uninstalls never ask and keep the data.

## CI

The MSI and the legacy NSIS installer are built by two separate jobs, `win64-ninja-vs2022-package-msi-windows` and
`win64-ninja-vs2022-package-windows`. Setting `SKIP_WINDOWS_MSI` or `SKIP_WINDOWS_NSIS` skips one of them; signing
and upload handle whichever packages were built. When both are built, `WINDOWS_UPDATE_PACKAGE` (`nsis` by default, or
`msi`) chooses the package offered by the update check (the `RELEASE` file).

## Switching users from NSIS to MSI

The update check only shows a download link, so users install the `.msi` like they installed the `.exe`, and the MSI
migrates their NSIS installation by itself. Recommended steps:

1. Publish a release with both packages while `WINDOWS_UPDATE_PACKAGE` stays `nsis`, and check the MSI on real
   machines, including the update of an existing NSIS installation.
2. Set `WINDOWS_UPDATE_PACKAGE=msi` for the next release.
3. Never offer the NSIS installer again once users are on the MSI: running it over an MSI installation leaves two
   entries in Installed apps. Stop publishing it (`SKIP_WINDOWS_NSIS`) or at least stop linking to it.

Things to keep in mind afterwards:

- The MSI version is `major.minor.patch` only. Builds sharing it replace each other, and a lower version is refused,
  so every published release must raise one of these three numbers.
- The MSI must be signed (the `win64-codesigning` job does it), otherwise SmartScreen blocks it.
- Never change the UpgradeCode (see Build prerequisites), or an update installs side by side with the old version.
- Customers deploying with GPO, Intune or SCCM can now use the `msiexec` command lines above instead of the NSIS
  switches.

## Automated tests

`tests/Test-MsiInstaller.ps1` installs and uninstalls the package for real and checks the result. It must run elevated
on a disposable machine where the application is not installed (`-UninstallExisting` removes it first). The user data
of the account running the tests is moved aside at the start and put back at the end.

```
powershell -ExecutionPolicy Bypass -File cmake\install\windows\msi\tests\Test-MsiInstaller.ps1 -Msi <package.msi> [-Suite Basic|Full] [-NsisInstaller <reference NSIS .exe>] [-JUnit report.xml] [-Only <name pattern>]
```

The upgrade, rebuild and downgrade packages are copies of the tested MSI with another version and ProductCode, so a
single build is enough. Every `msiexec` call writes its verbose log in `<WorkDir>\logs`.

| Test | Suite | Checks |
|---|---|---|
| `Install.Silent` | Basic | `/i /qn` returns 0, success in the `/l*v` log, every payload file, `sip:` handler, uninstall entry, Start menu shortcut |
| `Uninstall.Silent.KeepsUserData` | Basic | `/x /qn` returns 0, files, registry and shortcuts removed, user data kept |
| `Switch.InstallDir` | Full | `INSTALLDIR=` with spaces, nothing created in the default folder |
| `Switch.Log` | Full | `/log <file>`, and the default `MSI*.LOG` written without any switch |
| `Upgrade.KeepsDataAndFolder` | Full | upgrade to a newer version keeps the custom folder, `linphone.db`, `lime.db`, logs, settings |
| `Upgrade.SameVersionRebuild` | Full | a rebuild with the same version replaces the installed one |
| `Upgrade.AcrossLanguages` | Full | a product installed in another language is still upgraded |
| `Downgrade.Refused` | Full | an older version returns 1603 and leaves the installed one untouched |
| `Repair` | Full | `/famus` and a second `/i` restore a deleted executable and registry key |
| `Purge` | Full | `PURGE=0` keeps the user data, `PURGE=1` removes it |
| `App.GracefulCloseAndRestart` | Full | the running application quits through its IPC event and is relaunched in its session |
| `App.GracefulCloseAndRestart.AsSystem` | Full | same with `msiexec` run as SYSTEM, as deployment tools do |
| `Switch.RestartApp.Disabled` | Full | `RESTARTAPP=0` does not relaunch it |
| `Uninstall.ClosesRunningApp` | Full | an uninstall closes the application and does not relaunch it |
| `Nsis.Migration` | Full | an NSIS installation is uninstalled and replaced, user data kept |
| `Nsis.Migration.RunningApp` | Full | the running NSIS version quits gracefully and the new one is relaunched |
| `Nsis.Migration.RunningApp.AsSystem` | Full | same with `msiexec` run as SYSTEM, the NSIS version quits from its own session |
| `Nsis.Migration.CustomDir` | Full | the MSI reuses the NSIS custom folder |
| `Nsis.InstalledOverMsi.Repaired` | Full | running the MSI again cleans up an NSIS installer run over it |
| `ExitCode.RebootRequired` | Full | a locked file with `NOFORCECLOSE=1` returns 3010 |
| `ExitCode.RebootInitiated` | Full | always skipped: 1641 means the installer restarts the machine |

The `App.*`, `Uninstall.ClosesRunningApp` and `Nsis.Migration.RunningApp*` tests need an interactive desktop session
and are skipped in session 0.
The `Nsis.*` tests need `-NsisInstaller` and are skipped without it.

In CI, the `win64-msi-tests` job runs the full suite on the package of `win64-ninja-vs2022-package-msi-windows` once
`ENABLE_WINDOWS_MSI_TESTS` is set. It needs an elevated, resettable Windows runner tagged
`windows-powershell-msi-tests-interactive`, started in a logged-on desktop session rather than as a service.
`NSIS_REFERENCE_INSTALLER_URL` points to the NSIS installer used by the migration tests. The JUnit report and the logs
are kept as job artifacts.
