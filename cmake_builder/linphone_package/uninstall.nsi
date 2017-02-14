FindWindow $0 "gdkWindowToplevel" "Linphone"
StrCmp $0 0 notRunningInUninstall
MessageBox MB_OK|MB_ICONEXCLAMATION "Linphone is running. Please close it first and restart the uninstall program." /SD IDOK
Abort

notRunningInUninstall:

