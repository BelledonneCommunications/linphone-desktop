list(APPEND _LINPHONEAPP_SOURCES
	tool/Constants.cpp
	tool/EnumsToString.cpp
	tool/Utils.cpp

	tool/LinphoneEnums.cpp
	tool/thread/SafeSharedPointer.hpp
	tool/thread/SafeConnection.hpp
	tool/thread/Thread.cpp
	tool/providers/AvatarProvider.cpp
	tool/providers/ImageProvider.cpp
	tool/providers/ScreenProvider.cpp
	
	tool/native/DesktopTools.hpp

	tool/request/RequestDialog.cpp
	tool/request/CallbackHelper.cpp

	tool/file/FileDownloader.cpp
	tool/file/FileExtractor.cpp

)

if (APPLE)
	list(APPEND _LINPHONEAPP_SOURCES
		tool/native/DesktopToolsMacOs.cpp
		tool/native/DesktopToolsMacOsNative.mm
		tool/native/screen-saver/ScreenSaverMacOs.m
		tool/native/state-process/StateProcessMacOs.mm
		)
elseif (WIN32)
	list(APPEND _LINPHONEAPP_SOURCES
		tool/native/DesktopToolsWindows.cpp
		)
else ()
	list(APPEND _LINPHONEAPP_SOURCES
		tool/native/DesktopToolsLinux.cpp
		tool/native/screen-saver/ScreenSaverDBus.cpp
		tool/native/screen-saver/ScreenSaverXdg.cpp
		)
endif ()

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)


