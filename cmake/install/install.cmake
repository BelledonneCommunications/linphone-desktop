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

cmake_minimum_required(VERSION 3.1)

set(TARGET_NAME Linphone)

if (GIT_EXECUTABLE AND NOT(LINPHONEAPP_VERSION))
	execute_process(
		COMMAND ${GIT_EXECUTABLE} describe --always
		OUTPUT_VARIABLE LINPHONEAPP_VERSION
		OUTPUT_STRIP_TRAILING_WHITESPACE
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	)
endif()

if (NOT(LINPHONEAPP_VERSION))
  set(LINPHONEAPP_VERSION "0.0.0")
endif ()

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

if(ENABLE_APP_PACKAGE_ROOTCA)
	install(FILES "${LINPHONE_OUTPUT_DIR}/share/linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}")
endif()
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
	set(MSVC_VERSION ${MSVC_TOOLSET_VERSION})
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

#Windeployqt hack for CPack. WindeployQt cannot be used only with a simple 'install(CODE "execute_process' or CPack will not have all required files.
#Call it from target folder
function(deployqt_hack target)
	if(WIN32)
		find_program(DEPLOYQT_PROGRAM windeployqt HINTS "${_qt_bin_dir}")
		if (NOT DEPLOYQT_PROGRAM)
			message(FATAL_ERROR "Could not find the windeployqt program. Make sure it is in the PATH.")
		endif ()
		add_custom_command(TARGET ${target} POST_BUILD
							COMMAND "${CMAKE_COMMAND}" -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/winqt/"
							COMMAND "${CMAKE_COMMAND}" -E
								env PATH="${_qt_bin_dir}" "${DEPLOYQT_PROGRAM}"
								--qmldir "${LINPHONE_QML_DIR}"
								--plugindir "${CMAKE_CURRENT_BINARY_DIR}/winqt/plugins"
								--verbose 0
								--no-compiler-runtime
								--dir "${CMAKE_CURRENT_BINARY_DIR}/winqt/"
								"$<TARGET_FILE:${target}>"
							COMMENT "Deploying Qt..."
							WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}/.."
		)
		install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/winqt/" DESTINATION bin)
		set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)
		include(InstallRequiredSystemLibraries)
	endif()
endfunction()

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
	elseif(WIN32)
##############################################
#	WINDOWS
##############################################
		set(CPACK_GENERATOR "NSIS")
		set(DO_GENERATOR YES)
		set(PACKAGE_EXT "exe")
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-${BIN_ARCH}")
		find_program(NSIS_PROGRAM makensis)
		if(NOT NSIS_PROGRAM)
			
			message(STATUS "Installing windows tools for nsis")
			execute_process(
				COMMAND "${MSYS2_PROGRAM}" "-${MINGW_TYPE}" "-here" "-full-path" "-defterm" "-shell" "sh" "-l" "-c" "pacman -Sy ${MINGW_PACKAGE_PREFIX}nsis --noconfirm  --needed"
			)
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
			# Sign the installer.
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
		
	else()
##############################################
#	LINUX
##############################################
		set(DO_APPIMAGE YES)
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}")
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
##############################################
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/packaging.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake")
	if(LINPHONE_SDK_MAKE_RELEASE_FILE_URL)
		bc_make_release_file("${LINPHONEAPP_VERSION}" "${LINPHONE_SDK_MAKE_RELEASE_FILE_URL}/${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_EXT}")
		file(COPY "${CMAKE_INSTALL_PREFIX}/RELEASE" DESTINATION "${CMAKE_INSTALL_PREFIX}/Packages/")
	endif()
	include(CPack)
endif()

