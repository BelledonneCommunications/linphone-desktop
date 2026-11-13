################################################################################
#
#  Copyright (c) 2017-2024 Belledonne Communications SARL.
# 
#  This file is part of linphone-desktop
#  (see https://www.linphone.org).
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

cmake_minimum_required(VERSION 3.5)

set(TARGET_NAME Linphone)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")


if (GIT_EXECUTABLE AND NOT(LINPHONEAPP_VERSION))
	execute_process(
		COMMAND ${GIT_EXECUTABLE} describe --always
		OUTPUT_VARIABLE LINPHONEAPP_VERSION
		OUTPUT_STRIP_TRAILING_WHITESPACE
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	)
endif()

if(NOT LINPHONEAPP_VERSION)
	bc_compute_full_version(LINPHONEAPP_VERSION)
endif()

if (NOT(LINPHONEAPP_VERSION))
  message(WARNING "Failed to compute Linphone app version from Git!")
  set(LINPHONEAPP_VERSION "6.2.1")
endif ()

include(${CMAKE_SOURCE_DIR}/Linphone/application_info.cmake)

set(LINPHONE_MAJOR_VERSION)
set(LINPHONE_MINOR_VERSION)
set(LINPHONE_MICRO_VERSION)
set(LINPHONE_BRANCH_VERSION)
bc_parse_full_version(${LINPHONEAPP_VERSION} LINPHONE_MAJOR_VERSION LINPHONE_MINOR_VERSION LINPHONE_MICRO_VERSION LINPHONE_BRANCH_VERSION)

set(LINPHONE_VERSION ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION})
set(PACKAGE_VERSION "${LINPHONEAPP_VERSION}")

install(TARGETS ${TARGET_NAME}
    BUNDLE DESTINATION .
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES "${CMAKE_SOURCE_DIR}/Linphone/data/config/linphonerc-factory" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}")

set(LINPHONE_QML_DIR "${CMAKE_SOURCE_DIR}/Linphone/view")
set(QT_PATH "${Qt6Core_DIR}/../../..")

if(APPLE)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/entitlements.xml.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/entitlements.xml" @ONLY)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/linphone.icns" "${CMAKE_BINARY_DIR}/cmake/install/macos/${EXECUTABLE_NAME}.icns" COPYONLY)
	set(APP_QT_CONF_PATH "[Paths]\nPlugins = PlugIns\nImports = Resources/qml\nQml2Imports = Resources/qml")

	#configure_file("${CMAKE_SOURCE_DIR}/Linphone/../assets/qt.conf.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/qt.conf" @ONLY)
	#install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/qt.conf" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/..")
	#install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/Info.plist" DESTINATION "${APPLICATION_NAME}.app/Contents")
	install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/${EXECUTABLE_NAME}.icns" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/..")
	foreach(LPROJ en fr)
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/${LPROJ}.lproj/InfoPlist.strings.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/${LPROJ}.lproj/InfoPlist.strings" @ONLY)
		install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/${LPROJ}.lproj/InfoPlist.strings" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/../${LPROJ}.lproj")
	endforeach()
	file(GLOB SHARED_LIBRARIES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/lib*.dylib")
	if( ENABLE_OPENH264 )# Remove openH264 lib from the installation. this codec will be download by user
		foreach(item ${SHARED_LIBRARIES})
			get_filename_component(LIBRARY_FILENAME ${item} NAME)
			if("${LIBRARY_FILENAME}" MATCHES "^libopenh264.*.dylib$")
				list(REMOVE_ITEM SHARED_LIBRARIES ${item})
			endif()
		endforeach(item)
	endif()
	install(FILES ${SHARED_LIBRARIES} DESTINATION "${CMAKE_INSTALL_LIBDIR}")
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS OPTIONAL)

	file(GLOB SHARED_LIBRARIES "${CMAKE_BINARY_DIR}/cmake/install/macos/${APPLICATION_NAME}.app/Contents/Frameworks/lib*.dylib")

	foreach (LIBRARY ${SHARED_LIBRARIES})
		get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
		message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '@executable_path/../Frameworks'")
		execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "@executable_path/../Frameworks" "${LIBRARY}")
	endforeach ()
	install(TARGETS ${APP_PLUGIN}
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
	)
	install(CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../Frameworks/\" \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}\")")
	install(CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../lib/\" \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}\")")
	get_filename_component(_qt_bin_dir "${qmake_executable}" DIRECTORY)
	find_program(DEPLOYQT_PROGRAM macdeployqt HINTS "${_qt_bin_dir}")
	if (NOT DEPLOYQT_PROGRAM)
		message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
	endif()
	#Packaging is done by CPack in the cleanCPack.cmake file. But on mac, we need Qt files in .app
	if(NOT ENABLE_APP_PACKAGING)
		install(CODE "MESSAGE(\"MacDeploy install: execute_process(COMMAND ${DEPLOYQT_PROGRAM} ${APPLICATION_OUTPUT_DIR}/${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR} -no-strip -verbose=0 -always-overwrite) \")")
		install(CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} ${APPLICATION_OUTPUT_DIR}/${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR} -no-strip -verbose=0 -always-overwrite)")
	endif()
elseif(WIN32)
	set(BIN_ARCH "win32")
	if( CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(MINGW_PACKAGE_PREFIX "mingw-w64-x86_64-")
		set(MINGW_TYPE "mingw64")
		set(BIN_ARCH "win64")
	else()
		set(MINGW_PACKAGE_PREFIX "mingw-w64-i686-")
		set(MINGW_TYPE "mingw32")
	endif()
	find_program(MSYS2_PROGRAM
		NAMES msys2_shell.cmd
		HINTS "C:/msys64/"
	)
	set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		set(CMAKE_INSTALL_DEBUG_LIBRARIES TRUE)
	endif()
	include(InstallRequiredSystemLibraries)
	find_file(UCRTBASE_LIB "ucrtbase.dll" PATHS "C:/Windows/System32")
	install(FILES ${UCRTBASE_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")

	find_program(DEPLOYQT_PROGRAM windeployqt HINTS "${_qt_bin_dir}")
	if (NOT DEPLOYQT_PROGRAM)
		message(FATAL_ERROR "Could not find the windeployqt program. Make sure it is in the PATH.")
	endif ()
endif()

################################################################
#						CRASHPAD
################################################################
if(HAVE_CRASH_HANDLER)
	get_target_property(CRASHPAD_BIN_DIR Crashpad CRASHPAD_BIN_DIR)
	get_target_property(CRASHPAD_EXECUTABLE_NAME Crashpad CRASHPAD_EXECUTABLE_NAME)
	install(FILES "${CRASHPAD_BIN_DIR}/${CRASHPAD_EXECUTABLE_NAME}" DESTINATION ${CMAKE_INSTALL_BINDIR} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
	if(ENABLE_BUGSPLAT_SYMBOLS_UPLOAD)
		if(NOT LINPHONEAPP_APPLICATION_NAME)
			message(FATAL_ERROR "Missing application details for Bugsplat. Please fill LINPHONEAPP_APPLICATION_NAME (${LINPHONEAPP_APPLICATION_NAME} - ${LINPHONEAPP_VERSION})")
		elseif(NOT BUGSPLAT_DATABASE)
			message(FATAL_ERROR "Missing database application details for Bugsplat. Please fill BUGSPLAT_DATABASE in application_info.cmake")
		elseif(NOT BUGSPLAT_CLIENT_ID OR NOT BUGSPLAT_CLIENT_SECRET)
			message(FATAL_ERROR "Missing identifications for Bugsplat. Please fill BUGSPLAT_CLIENT_ID and BUGSPLAT_CLIENT_SECRET to activate symbol uploading")
		else()
			message(STATUS "Preparing symbol uploader Bugsplat for ${LINPHONEAPP_APPLICATION_NAME} - ${LINPHONEAPP_VERSION}.")
			if(WIN32)
				set(CRASHPAD_SYMBOLS_UPLOADER "${CMAKE_BINARY_DIR}/symbol-upload-windows.exe")
				set(CRASHPAD_SYMBOLS_UPLOADER_URL "https://github.com/BugSplat-Git/symbol-upload/releases/download/v11.0.0/symbol-upload-windows.exe")
			else()
				set(CRASHPAD_SYMBOLS_UPLOADER "${CMAKE_BINARY_DIR}/symbol-upload-linux")
				set(CRASHPAD_SYMBOLS_UPLOADER_URL "https://github.com/BugSplat-Git/symbol-upload/releases/download/v11.0.0/symbol-upload-linux")
			endif()
			if(NOT EXISTS "${CRASHPAD_SYMBOLS_UPLOADER}")
				file(DOWNLOAD ${CRASHPAD_SYMBOLS_UPLOADER_URL} ${CRASHPAD_SYMBOLS_UPLOADER})
				file(CHMOD "${CRASHPAD_SYMBOLS_UPLOADER}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
			endif()
		endif()
	endif()
else()
	message(DEBUG "No Crash handler, do not configure Crashpad")
endif()

# ==============================================================================
#                               CPack.
# ==============================================================================


if(${ENABLE_APP_PACKAGING})
	set(CPACK_BINARY_STGZ OFF)
	set(CPACK_BINARY_TGZ OFF)
	set(CPACK_BINARY_TZ OFF)
	set(CPACK_PACKAGE_NAME "${APPLICATION_NAME}")
	set(CPACK_PACKAGE_VENDOR "${APPLICATION_VENDOR}")
	set(CPACK_PACKAGE_VERSION_MAJOR ${LINPHONE_MAJOR_VERSION})
	set(CPACK_PACKAGE_VERSION_MINOR ${LINPHONE_MINOR_VERSION})
	if (LINPHONE_MICRO_VERSION)
		set(CPACK_PACKAGE_VERSION_PATCH ${LINPHONE_MICRO_VERSION})
	endif ()
	set(CPACK_PACKAGE_EXECUTABLES "${EXECUTABLE_NAME};${APPLICATION_NAME}")
	set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE)
	set(CPACK_MONOLITHIC_INSTALL TRUE)# Need it since libturbo-jpeg introduce components (lib/include etc.)
	
	if(ENABLE_APP_LICENSE)
		set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")
	else()
		unset(CPACK_RESOURCE_FILE_LICENSE)
	endif()
	set(CPACK_RESOURCE_FILE_LICENSE_PROVIDED ${ENABLE_APP_LICENSE})
	set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/Linphone/data/icon.ico")
	set(PERFORM_SIGNING 0)
	
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/cleanCPack.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/cleanCPack.cmake" @ONLY)
	set(CPACK_PRE_BUILD_SCRIPTS  "${CMAKE_BINARY_DIR}/cmake/install/cleanCPack.cmake")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY ${APPLICATION_NAME})
	if(APPLE)
##############################################
#	APPLE
##############################################
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-mac")
		set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/cmake/install/macos/background_dmg.jpg")
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/linphone_dmg.scpt.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/linphone_dmg.scpt" @ONLY)
		set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/macos/linphone_dmg.scpt")
		set(CPACK_BINARY_DRAGNDROP ON)
		set(CPACK_BUNDLE_APPLE_CERT_APP ${LINPHONE_BUILDER_SIGNING_IDENTITY})
		set(PACKAGE_EXT "dmg")

		message(STATUS "Set DragNDrop CPack generator in OUTPUT/Packages")
	elseif(WIN32 AND ENABLE_WINDOWS_MSI)
		if(CMAKE_VERSION VERSION_LESS 3.30)
			message(FATAL_ERROR "MSI packaging needs CMake 3.30 or newer (found ${CMAKE_VERSION}). Use -DENABLE_WINDOWS_MSI=OFF to build the NSIS installer.")
		endif()
		set(LINPHONE_WIX_VERSION "5.0.2" CACHE STRING "Version of the WiX .NET tool and extensions used for MSI packaging.")
		find_program(WIX_PROGRAM wix HINTS "$ENV{USERPROFILE}/.dotnet/tools" "$ENV{WIX}" PATH_SUFFIXES bin)
		if(NOT WIX_PROGRAM AND ENABLE_WINDOWS_TOOLS_CHECK)
			message(STATUS "Installing WiX ${LINPHONE_WIX_VERSION}")
			execute_process(COMMAND dotnet tool install --global wix --version ${LINPHONE_WIX_VERSION})
			unset(WIX_PROGRAM CACHE)
			find_program(WIX_PROGRAM wix HINTS "$ENV{USERPROFILE}/.dotnet/tools" "$ENV{WIX}" PATH_SUFFIXES bin)
		endif()
		if(NOT WIX_PROGRAM)
			message(FATAL_ERROR "`wix` is needed for MSI packaging. Install it with `dotnet tool install --global wix --version ${LINPHONE_WIX_VERSION}` and `wix extension add --global WixToolset.UI.wixext/${LINPHONE_WIX_VERSION}`, or use -DENABLE_WINDOWS_MSI=OFF.")
		endif()
		execute_process(COMMAND "${WIX_PROGRAM}" --version OUTPUT_VARIABLE WIX_FOUND_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
		if(NOT WIX_FOUND_VERSION MATCHES "^[45]\\.")
			message(FATAL_ERROR "WiX ${WIX_FOUND_VERSION} found at ${WIX_PROGRAM}, but MSI packaging expects WiX 4.x or 5.x (${LINPHONE_WIX_VERSION} recommended).")
		endif()
		if(ENABLE_WINDOWS_TOOLS_CHECK)
			execute_process(COMMAND "${WIX_PROGRAM}" extension add --global "WixToolset.UI.wixext/${LINPHONE_WIX_VERSION}")
		endif()
		get_filename_component(CPACK_WIX_ROOT "${WIX_PROGRAM}" DIRECTORY)

		set(LINPHONE_MSI_ACTIONS_DIR "${CMAKE_BINARY_DIR}/cmake/install/windows/msi")
		cmake_policy(SET CMP0091 NEW)
		add_library(LinphoneInstallerActions SHARED
			"${CMAKE_SOURCE_DIR}/cmake/install/windows/msi/InstallerActions.cpp"
			"${CMAKE_SOURCE_DIR}/cmake/install/windows/msi/InstallerActions.def"
		)
		target_compile_definitions(LinphoneInstallerActions PRIVATE UNICODE _UNICODE)
		target_link_libraries(LinphoneInstallerActions PRIVATE msi wtsapi32 userenv advapi32 shell32 ole32 user32)
		set_target_properties(LinphoneInstallerActions PROPERTIES
			OUTPUT_NAME "InstallerActions"
			DEBUG_POSTFIX ""
			CXX_STANDARD 17
			CXX_STANDARD_REQUIRED ON
			MSVC_RUNTIME_LIBRARY "MultiThreaded"
			RUNTIME_OUTPUT_DIRECTORY "${LINPHONE_MSI_ACTIONS_DIR}/$<0:>"
		)
		set(LINPHONE_MSI_ACTIONS_DLL "${LINPHONE_MSI_ACTIONS_DIR}/InstallerActions.dll")

		set(LINPHONE_WIX_UPGRADE_GUID "" CACHE STRING "Override the MSI UpgradeCode. Never change it once a package has been released.")
		if(LINPHONE_WIX_UPGRADE_GUID)
			set(CPACK_WIX_UPGRADE_GUID "${LINPHONE_WIX_UPGRADE_GUID}")
		else()
			string(UUID CPACK_WIX_UPGRADE_GUID NAMESPACE DDC16AB9-304E-4BC8-8C2A-A5D31DF2FA39 NAME "upgrade/${APPLICATION_VENDOR}/${APPLICATION_NAME}" TYPE SHA1 UPPER)
		endif()
		string(UUID LINPHONE_MSI_REGISTRATION_GUID NAMESPACE DDC16AB9-304E-4BC8-8C2A-A5D31DF2FA39 NAME "registration/${APPLICATION_VENDOR}/${APPLICATION_NAME}" TYPE SHA1 UPPER)
		string(UUID LINPHONE_MSI_PROTOCOLS_GUID NAMESPACE DDC16AB9-304E-4BC8-8C2A-A5D31DF2FA39 NAME "shared-protocols" TYPE SHA1 UPPER)
		message(STATUS "MSI UpgradeCode for ${APPLICATION_NAME}: {${CPACK_WIX_UPGRADE_GUID}}")

		file(STRINGS "${CMAKE_SOURCE_DIR}/Linphone/core/notifier/NotificationActivator.hpp" LINPHONE_ACTIVATOR_LINE REGEX "DECLSPEC_UUID\\(\"[0-9A-Fa-f-]+\"\\)")
		string(REGEX REPLACE ".*DECLSPEC_UUID\\(\"([0-9A-Fa-f-]+)\"\\).*" "\\1" LINPHONE_NOTIFICATION_ACTIVATOR_CLSID "${LINPHONE_ACTIVATOR_LINE}")
		set(LINPHONE_MSI_QUIT_EVENT_PREFIX "${EXECUTABLE_NAME}-installer-quit-")
		set(LINPHONE_MSI_STATE_KEY "SOFTWARE\\${APPLICATION_VENDOR}\\${APPLICATION_NAME} InstallerRestart")
		if(ENABLE_APP_LICENSE)
			set(LINPHONE_MSI_SHOW_LICENSE 1)
		else()
			set(LINPHONE_MSI_SHOW_LICENSE 0)
		endif()
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/windows/msi/WIX.template.in" "${LINPHONE_MSI_ACTIONS_DIR}/WIX.template.in" @ONLY)

		set(CPACK_GENERATOR "WIX")
		set(DO_GENERATOR YES)
		set(PACKAGE_EXT "msi")
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-${BIN_ARCH}")
		set(CPACK_IGNORE_FILES ".*Qt.*\\.pdb$" ".*\\.lib$" ".*\\.cmake$")
		if(NOT CPACK_PACKAGE_VERSION_PATCH)
			set(CPACK_PACKAGE_VERSION_PATCH 0)
		endif()
		set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
		set(CPACK_WIX_VERSION 4)
		set(CPACK_WIX_INSTALL_SCOPE "perMachine")
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(CPACK_WIX_ARCHITECTURE "x64")
		else()
			set(CPACK_WIX_ARCHITECTURE "x86")
		endif()
		set(CPACK_WIX_TEMPLATE "${LINPHONE_MSI_ACTIONS_DIR}/WIX.template.in")
		set(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/Linphone/data/icon.ico")
		set(LINPHONE_MSI_UI_BANNER "${CMAKE_SOURCE_DIR}/cmake/install/windows/msi/banner.bmp" CACHE FILEPATH "493x58 bitmap shown at the top of the MSI installer dialogs.")
		set(LINPHONE_MSI_UI_DIALOG "${CMAKE_SOURCE_DIR}/cmake/install/windows/msi/dialog.bmp" CACHE FILEPATH "493x312 bitmap shown as background of the MSI welcome and completion dialogs.")
		set(CPACK_WIX_UI_BANNER "${LINPHONE_MSI_UI_BANNER}")
		set(CPACK_WIX_UI_DIALOG "${LINPHONE_MSI_UI_DIALOG}")
		set(LINPHONE_MSI_LOCALIZATION_DIR "${CMAKE_SOURCE_DIR}/cmake/install/windows/msi")
		set(LINPHONE_MSI_EXTRA_CULTURES "fr-FR" CACHE STRING "Cultures embedded in the MSI as language transforms besides en-US; each needs cmake/install/windows/msi/<culture>.wxl.")
		set(CPACK_WIX_CULTURES "en-US")
		set(CPACK_WIX_BUILD_EXTRA_FLAGS "-loc" "${LINPHONE_MSI_LOCALIZATION_DIR}/en-US.wxl")
		configure_file("${LINPHONE_MSI_LOCALIZATION_DIR}/languages.cmake.in" "${LINPHONE_MSI_ACTIONS_DIR}/languages.cmake" @ONLY)
		set(CPACK_POST_BUILD_SCRIPTS "${LINPHONE_MSI_ACTIONS_DIR}/languages.cmake")
		set(CPACK_WIX_ROOT_FEATURE_TITLE "${APPLICATION_NAME}")
		set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "${APPLICATION_URL}")
		set(CPACK_WIX_PROPERTY_ARPHELPLINK "${APPLICATION_URL}")
		if(ENABLE_APP_LICENSE)
			set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")
		endif()
		message(STATUS "Set WIX CPack generator in OUTPUT/Packages")
	elseif(WIN32)
##############################################
#	WINDOWS
##############################################
		set(CPACK_GENERATOR "NSIS")
		set(DO_GENERATOR YES)
		set(PACKAGE_EXT "exe")
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-${BIN_ARCH}")
		set(CPACK_SOURCE_IGNORE_FILES "*Qt*.pdb;*.lib;*.cmake")
		set(CPACK_IGNORE_FILES ".*Qt.*\\.pdb$" ".*\\.lib$" ".*\\.cmake$") #Not documented

		find_program(NSIS_PROGRAM makensis)
		if(NOT NSIS_PROGRAM)
			if(ENABLE_WINDOWS_TOOLS_CHECK)
				message(STATUS "Installing windows tools for nsis")
				execute_process(
					COMMAND "${MSYS2_PROGRAM}" "-${MINGW_TYPE}" "-here" "-full-path" "-defterm" "-shell" "sh" "-l" "-c" "pacman -Sy ${MINGW_PACKAGE_PREFIX}nsis --noconfirm  --needed"
				)
			else()
				message(FATAL_ERROR "`makensis` is needed for packaging. Please use pacman -Sy ${MINGW_PACKAGE_PREFIX}nsis to install it.")
			endif()
		endif()
		set(PACKAGE_EXT "exe")
		# Use magic `NSIS.template.in` template from the current source directory to force uninstallation
		# and ensure that linphone is not running before installation.
		set(CPACK_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/install/windows")
		set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\cmake\\\\install\\\\windows\\\\nsis_banner.bmp")
		set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/Linphone/data/icon.ico")
		set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/Linphone/data/icon.ico")
		set(CPACK_NSIS_DISPLAY_NAME "${APPLICATION_NAME}")	# = The display name string that appears in the Windows Add/Remove Program control panel
		set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${APPLICATION_NAME}")
		
		if (LINPHONE_MICRO_VERSION)# CPACK_NSIS_PACKAGE_NAME = Title at the top of the installer
			set(CPACK_NSIS_PACKAGE_NAME "${APPLICATION_NAME} ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION}")
		else ()
			set(CPACK_NSIS_PACKAGE_NAME "${APPLICATION_NAME} ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}")
		endif ()
		set(CPACK_NSIS_URL_INFO_ABOUT ${APPLICATION_URL})
		
		file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}" DOS_STYLE_BINARY_DIR)
		string(REPLACE "\\" "\\\\" ESCAPED_DOS_STYLE_BINARY_DIR "${DOS_STYLE_BINARY_DIR}")
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/windows/install.nsi.in" "${CMAKE_CURRENT_BINARY_DIR}/install.nsi" @ONLY)
		set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\install.nsi\\\"")
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/windows/uninstall.nsi.in" "${CMAKE_CURRENT_BINARY_DIR}/uninstall.nsi" @ONLY)
		set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\uninstall.nsi\\\"")
		set(CPACK_NSIS_EXECUTABLES_DIRECTORY "bin")
		set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${EXECUTABLE_NAME}.exe")
		set(CPACK_NSIS_INSTALLED_ICON_NAME "${CPACK_NSIS_EXECUTABLES_DIRECTORY}/${CPACK_NSIS_MUI_FINISHPAGE_RUN}")
		message(STATUS "Set NSIS CPack generator in OUTPUT/Packages")
	else()
##############################################
#	LINUX
##############################################
		set(DO_APPIMAGE YES)
		message("Packaging AppImage as ${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
		set(PACKAGE_EXT "AppImage")
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/linux/linphone.desktop.cmake" "${CMAKE_BINARY_DIR}/cmake/install/linux/${EXECUTABLE_NAME}.desktop" @ONLY)
		install(FILES "${CMAKE_BINARY_DIR}/cmake/install/linux/${EXECUTABLE_NAME}.desktop" DESTINATION "${CMAKE_INSTALL_DATADIR}/applications" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
		install(FILES "${CMAKE_SOURCE_DIR}/Linphone/data/image/logo.svg" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/apps/" RENAME "${EXECUTABLE_NAME}.svg")
		set(ICON_DIRS 16x16 22x22 24x24 32x32 64x64 128x128 256x256)
		foreach (DIR ${ICON_DIRS})
			install(FILES "${CMAKE_SOURCE_DIR}/Linphone/data/icon/hicolor/${DIR}/apps/icon.png" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/${DIR}/apps/" RENAME "${EXECUTABLE_NAME}.png")
		endforeach ()
		message(STATUS "Set AppImage CPack generator in OUTPUT/Packages")
	endif()
	if(WIN32)
		if(LINPHONE_WINDOWS_SIGN_TOOL AND LINPHONE_WINDOWS_SIGN_TIMESTAMP_URL)
			find_program(SIGNTOOL ${LINPHONE_WINDOWS_SIGN_TOOL})
			set(TIMESTAMP_URL ${LINPHONE_WINDOWS_SIGN_TIMESTAMP_URL})
			set(SIGN_HASH ${LINPHONE_WINDOWS_SIGN_HASH})
			if (SIGNTOOL)
				set(SIGNTOOL_COMMAND ${SIGNTOOL})
				message("Found requested signtool")
				set(PERFORM_SIGNING 1)
			else ()
				message(STATUS "Could not find requested signtool! Code signing disabled (${LINPHONE_WINDOWS_SIGN_TOOL})")
			endif ()
		elseif(LINPHONE_WINDOWS_SIGNING_DIR)
			set(TIMESTAMP_URL "http://timestamp.digicert.com")
			set(PFX_FILE "${LINPHONE_WINDOWS_SIGNING_DIR}/linphone.pfx")
			set(PASSPHRASE_FILE "${LINPHONE_WINDOWS_SIGNING_DIR}/passphrase.txt")
			get_filename_component(WINSDK_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH CACHE)
			find_program(SIGNTOOL signtool PATHS ${WINSDK_DIR}/${CMAKE_INSTALL_BINDIR})
			if (EXISTS ${PFX_FILE})
				if (SIGNTOOL)
					set(SIGNTOOL_COMMAND ${SIGNTOOL})
					message("Found signtool and certificate ${PFX_FILE}")
					set(PERFORM_SIGNING 1)
				else ()
					message(STATUS "Could not find signtool! Code signing disabled (${SIGNTOOL})")
				endif ()
			else ()
				message(STATUS "No signtool certificate found; assuming development machine (${PFX_FILE})")
			endif ()
		endif ()
	endif()
##############################################
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/packaging.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake")
	if(LINPHONE_SDK_MAKE_RELEASE_FILE_URL)
		bc_make_release_file("${LINPHONEAPP_VERSION}" "${LINPHONE_SDK_MAKE_RELEASE_FILE_URL}/${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_EXT}")
		file(COPY "${CMAKE_INSTALL_PREFIX}/RELEASE" DESTINATION "${CMAKE_INSTALL_PREFIX}/Packages/")
	endif()
	include(CPack)
endif()
