############################################################################
# CMakeLists.txt
# Copyright (C) 2017  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
############################################################################

cmake_minimum_required(VERSION 3.0)
project(LINPHONE_PACKAGE) # Dummy project

find_package(Linphone REQUIRED)
find_package(Git)

set(LINPHONE_QML_DIR "${LINPHONE_DESKTOP_DIR}/ui")

if(GIT_EXECUTABLE)
	execute_process(
		COMMAND ${GIT_EXECUTABLE} describe --always
		OUTPUT_VARIABLE LINPHONE_GIT_REVISION
		OUTPUT_STRIP_TRAILING_WHITESPACE
		WORKING_DIRECTORY ${LINPHONE_DESKTOP_DIR}
	)
else()
	set(LINPHONE_GIT_REVISION "0.0.0")
endif()
string(REGEX REPLACE "([0-9.]+)-?.*" "\\1" LINPHONE_VERSION "${LINPHONE_GIT_REVISION}")
string(REPLACE "." ";" SPLITTED_LINPHONE_VERSION "${LINPHONE_VERSION}")
list(LENGTH SPLITTED_LINPHONE_VERSION SPLITTED_LINPHONE_VERSION_LENGTH)
list(GET SPLITTED_LINPHONE_VERSION 0 LINPHONE_MAJOR_VERSION)
list(GET SPLITTED_LINPHONE_VERSION 1 LINPHONE_MINOR_VERSION)
if(SPLITTED_LINPHONE_VERSION_LENGTH GREATER 2)
	list(GET SPLITTED_LINPHONE_VERSION 2 LINPHONE_MICRO_VERSION)
endif()
set(PACKAGE_VERSION "${LINPHONE_VERSION}")

# Preparing the Linphone SDK bundle
set(LINPHONE_SDK_TMP "${CMAKE_CURRENT_BINARY_DIR}/linphone-sdk-tmp")
file(REMOVE_RECURSE "${LINPHONE_SDK_TMP}")
file(COPY "${LINPHONE_OUTPUT_DIR}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/desktop" "${LINPHONE_SDK_TMP}")

# Generates a zip archive containing the development files of liblinphone
macro(add_list_file NAME)
	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/sdk_content/${NAME}.list.in" "${LINPHONE_SDK_TMP}/${NAME}.list" @ONLY)
	list(APPEND LIST_FILES "${LINPHONE_SDK_TMP}/${NAME}.list")
endmacro()
if(WIN32)
	set(LIBDIR "bin")
	set(LIBPREFIX "")
	set(LIBEXT "dll")
	set(PLUGINEXT "dll")
elseif(APPLE)
	set(LIBDIR "lib")
	set(LIBPREFIX "lib")
	set(LIBEXT "dylib")
	set(PLUGINEXT "so")
endif()
set(LIST_FILES )
add_list_file(bctoolbox)
add_list_file(antlr3c)
add_list_file(bellesip)
add_list_file(ortp)
add_list_file(ms2)
add_list_file(ms2plugins)
add_list_file(linphone)
if(WIN32)
	add_list_file(sqlite3)
	add_list_file(xml2)
	add_list_file(zlib)
endif()
if(ENABLE_UNIT_TESTS)
	add_list_file(bcunit)
endif()
if(ENABLE_VCARD)
	add_list_file(vcard)
endif()
if(ENABLE_BV16)
	add_list_file(bv16)
endif()
if(ENABLE_GSM)
	add_list_file(gsm)
endif()
if(ENABLE_OPUS)
	add_list_file(opus)
endif()
if(ENABLE_SPEEX)
	add_list_file(speex)
endif()
if(ENABLE_MBEDTLS)
	add_list_file(mbedtls)
endif()
if(ENABLE_POLARSSL)
	add_list_file(polarssl)
endif()
if(ENABLE_SRTP)
	add_list_file(srtp)
endif()
if(ENABLE_ZRTP)
	add_list_file(bzrtp)
endif()
if(ENABLE_FFMPEG)
	add_list_file(ffmpeg)
endif()
if(ENABLE_OPENH264)
	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/README.openh264.txt.in" "${LINPHONE_SDK_TMP}/README.openh264.txt" @ONLY)
	add_list_file(openh264)
endif()
file(WRITE "${LINPHONE_SDK_TMP}/linphone-sdk.list" "")
foreach(_file ${LIST_FILES})
	file(READ "${_file}" _content)
	file(APPEND "${LINPHONE_SDK_TMP}/linphone-sdk.list" "${_content}\n")
endforeach()
if(WIN32)
	find_program(7Z_PROGRAM 7z.exe)
	if(7Z_PROGRAM)
		execute_process(
			COMMAND ${7Z_PROGRAM} a -tzip ${CMAKE_BINARY_DIR}/linphone-sdk-${LINPHONE_GIT_REVISION}-win32.zip @linphone-sdk.list
			WORKING_DIRECTORY ${LINPHONE_SDK_TMP}
		)
	else()
		message(WARNING "7z has not been found, cannot generate the SDK!")
	endif()
elseif(APPLE)
	execute_process(
		COMMAND rm -rf "${CMAKE_BINARY_DIR}/linphone-sdk-${LINPHONE_GIT_REVISION}-mac.zip"
		COMMAND zip -ry "${CMAKE_BINARY_DIR}/linphone-sdk-${LINPHONE_GIT_REVISION}-mac.zip" . -i "@linphone-sdk.list"
		WORKING_DIRECTORY ${LINPHONE_SDK_TMP}
	)
endif()

if(WIN32)
	execute_process(
		COMMAND windeployqt "${LINPHONE_OUTPUT_DIR}/bin/linphone.exe" "--qmldir" "${LINPHONE_QML_DIR}"
	)

	file(GLOB SHARE_CONTENT RELATIVE "${LINPHONE_OUTPUT_DIR}" "${LINPHONE_OUTPUT_DIR}/share/*")
	list(REMOVE_ITEM SHARE_CONTENT "share/images" "share/linphone" "share/Linphone" "share/sounds")
	foreach(item IN LISTS SHARE_CONTENT)
		list(APPEND SHARE_CONTENT_EXCLUDE PATTERN "${item}" EXCLUDE)
	endforeach()

	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/"
		DESTINATION "."
		COMPONENT "linphone_base"
		PATTERN "bin/belcard*.exe" EXCLUDE
		PATTERN "bin/*_tester.exe" EXCLUDE
		PATTERN "bin/openh264.dll" EXCLUDE
		PATTERN "include" EXCLUDE
		PATTERN "lib/mediastreamer/plugins/*openh264.*" EXCLUDE
		PATTERN "lib/pkgconfig" EXCLUDE
		PATTERN "lib/*.a" EXCLUDE
		PATTERN "lib/*.def" EXCLUDE
		PATTERN "lib/*.exp" EXCLUDE
		PATTERN "lib/*.la" EXCLUDE
		PATTERN "lib/*.lib" EXCLUDE
		PATTERN "lib/Win32" EXCLUDE
		PATTERN "linphone.lnk" EXCLUDE
		PATTERN "share/Linphone/cmake" EXCLUDE
		${SHARE_CONTENT_EXCLUDE}
	)


	if(ENABLE_OPENH264)
		# Include bunzip2.exe and bzip2.dll to be able to extract the openh264 file downloaded from Cisco
		install(DIRECTORY "${TOOLS_DIR}/"
			DESTINATION "bin"
			COMPONENT "msopenh264"
			FILES_MATCHING PATTERN "b*zip2.*"
		)
		install(FILES "${LINPHONE_OUTPUT_DIR}/lib/mediastreamer/plugins/libmsopenh264.dll"
			DESTINATION "lib/mediastreamer/plugins"
			COMPONENT "msopenh264"
		)
	endif()

elseif(APPLE)
	configure_file("Info.plist.in" "Linphone.app/Contents/Info.plist" @ONLY)
	configure_file("linphone.icns" "Linphone.app/Contents/Resources/linphone.icns" COPYONLY)
	file(COPY "${LINPHONE_OUTPUT_DIR}/bin/linphone" DESTINATION "Linphone.app/Contents/MacOS")
	file(GLOB SHARED_LIBRARIES "${LINPHONE_OUTPUT_DIR}/lib/lib*.dylib")
	foreach(_library ${SHARED_LIBRARIES})
		file(COPY "${_library}" DESTINATION "Linphone.app/Contents/Frameworks")
	endforeach()

	find_program(DEPLOYQT_PROGRAM macdeployqt)
	if(NOT DEPLOYQT_PROGRAM)
		message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
	endif()
	execute_process(
		COMMAND "${DEPLOYQT_PROGRAM}" "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app" "-qmldir=${LINPHONE_QML_DIR}" "-verbose=2"
	)

	if(EXISTS "${LINPHONE_OUTPUT_DIR}/lib/mediastreamer")
		file(COPY "${LINPHONE_OUTPUT_DIR}/lib/mediastreamer" DESTINATION "Linphone.app/Contents/Resources/lib" USE_SOURCE_PERMISSIONS)
	endif()
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/images" DESTINATION "Linphone.app/Contents/Resources/share" USE_SOURCE_PERMISSIONS)
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/sounds" DESTINATION "Linphone.app/Contents/Resources/share" USE_SOURCE_PERMISSIONS)
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/Linphone/rootca.pem" DESTINATION "Linphone.app/Contents/Resources/share/linphone")
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/Linphone/linphonerc-factory" DESTINATION "Linphone.app/Contents/Resources/share/linphone")

	file(COPY "${LINPHONE_OUTPUT_DIR}/share/Linphone/assistant/use-other-sip-account.rc" DESTINATION "Linphone.app/Contents/Resources/share/linphone/assistant")
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/Linphone/assistant/create-linphone-sip-account.rc" DESTINATION "Linphone.app/Contents/Resources/share/linphone/assistant")
	file(COPY "${LINPHONE_OUTPUT_DIR}/share/Linphone/assistant/use-linphone-sip-account.rc" DESTINATION "Linphone.app/Contents/Resources/share/linphone/assistant")

	file(GLOB SHARED_LIBRARIES "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app/Contents/Frameworks/lib*.dylib")
	foreach(_library ${SHARED_LIBRARIES})
		get_filename_component(_library_filename ${_library} NAME)
		message("Changing RPATH of ${_library_filename} from '${LINPHONE_OUTPUT_DIR}/lib' to '@executable_path/../Frameworks'")
		execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/lib" "@executable_path/../Frameworks" "${_library}")
	endforeach()

	if(LINPHONE_BUILDER_SIGNING_IDENTITY)
		file(GLOB FRAMEWORKS_NAMES "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app/Contents/Frameworks/*")
		foreach(_framework ${FRAMEWORKS_NAMES})
			execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${_framework}")
		endforeach()
		file(GLOB PLUGINS_NAMES "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app/Contents/PlugIns/*")
		foreach(_plugin ${PLUGINS_NAMES})
			file(GLOB PLUGINS_FILES "${_plugin}/*")
			foreach(_pluginfile ${PLUGINS_FILES})
				execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${_pluginfile}")
			endforeach()
		endforeach()
		execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app")
	endif()

	install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Linphone.app" DESTINATION "." USE_SOURCE_PERMISSIONS)

	configure_file("MacPackaging.cmake.in" "MacPackaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/MacPackaging.cmake")
endif()

if(MSVC)
	string(REGEX REPLACE "Visual Studio ([0-9]+).*" "\\1" MSVC_VERSION "${CMAKE_GENERATOR}")
	find_file(MSVCP_LIB "msvcp${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
	find_file(UCRTBASE_LIB "ucrtbase.dll" PATHS "C:/Windows/System32")
	# Starting with Visual Studio 2015 (MSVC_VERSION==14) the msvcr dll has been renamed to vcruntime
	find_file(VCRUNTIME_LIB "vcruntime${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
	if(NOT VCRUNTIME_LIB)
		find_file(VCRUNTIME_LIB "msvcr${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
	endif()
	install(FILES ${MSVCP_LIB} ${UCRTBASE_LIB} ${VCRUNTIME_LIB} DESTINATION "bin")
	if(CMAKE_BUILD_TYPE STREQUAL "Debug")
		find_file(MSVCPD_LIB "msvcp${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
		find_file(UCRTBASED_LIB "ucrtbased.dll" PATHS "C:/Windows/System32")
		find_file(VCRUNTIMED_LIB "vcruntime${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
		if(NOT VCRUNTIMED_LIB)
			find_file(VCRUNTIMED_LIB "msvcr${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
		endif()
		install(FILES ${MSVCPD_LIB} ${UCRTBASED_LIB} ${VCRUNTIMED_LIB} DESTINATION "bin")
	endif()
endif()

set(CPACK_PACKAGE_NAME "Linphone")
set(CPACK_PACKAGE_VENDOR "Belledonne communications")
set(CPACK_PACKAGE_VERSION_MAJOR ${LINPHONE_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${LINPHONE_MINOR_VERSION})
if(LINPHONE_MICRO_VERSION)
	set(CPACK_PACKAGE_VERSION_PATCH ${LINPHONE_MICRO_VERSION})
endif()
set(CPACK_PACKAGE_EXECUTABLES "linphone;Linphone")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Linphone")
set(CPACK_RESOURCE_FILE_LICENSE "${LINPHONE_SOURCE_DIR}/COPYING")

if(APPLE)
	set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${LINPHONE_GIT_REVISION}-mac")
endif()

if(WIN32)
	set(CPACK_COMPONENT_LINPHONE_BASE_DISPLAY_NAME "Linphone")
	set(CPACK_COMPONENT_LINPHONE_BASE_DESCRIPTION "Minimal installation of Linphone")
	set(CPACK_COMPONENT_LINPHONE_BASE_REQUIRED True)
	if(ENABLE_OPENH264)
		set(CPACK_COMPONENT_MSOPENH264_DISPLAY_NAME "Cisco's OpenH264 codec")
		set(CPACK_COMPONENT_MSOPENH264_DESCRIPTION "Download OpenH264 Video Codec provided by Cisco Systems, Inc.")
		set(CPACK_COMPONENT_MSOPENH264_DISABLED True)
	endif()

	# Use template from the current source directory to force uninstallation and ensure that linphone is not running before installation
	set(CPACK_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
	set(CPACK_GENERATOR "NSIS")
	set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\linphone-banner.bmp")
	set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${LINPHONE_GIT_REVISION}-win32")
	set(CPACK_NSIS_MUI_ICON "${LINPHONE_DESKTOP_DIR}/assets/linphone.ico")
	set(CPACK_NSIS_MUI_UNIICON "${LINPHONE_DESKTOP_DIR}/assets/linphone.ico")
	set(CPACK_NSIS_DISPLAY_NAME "Linphone")
	if(LINPHONE_MICRO_VERSION)
		set(CPACK_NSIS_PACKAGE_NAME "Linphone ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION}")
	else()
		set(CPACK_NSIS_PACKAGE_NAME "Linphone ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}")
	endif()
	set(CPACK_NSIS_URL_INFO_ABOUT "http://www.linphone.org/")

	file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" DOS_STYLE_SOURCE_DIR)
	string(REPLACE "\\" "\\\\" ESCAPED_DOS_STYLE_SOURCE_DIR "${DOS_STYLE_SOURCE_DIR}")
	file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}" DOS_STYLE_BINARY_DIR)
	string(REPLACE "\\" "\\\\" ESCAPED_DOS_STYLE_BINARY_DIR "${DOS_STYLE_BINARY_DIR}")

	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/uninstall.nsi" "${CMAKE_CURRENT_BINARY_DIR}/uninstall.nsi" COPYONLY)
	set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\uninstall.nsi\\\"")
	if(ENABLE_OPENH264)
		# Add NSI instructions to download the openh264 codec from Cisco's servers whether msopenh264 has been installed
		configure_file("${CMAKE_CURRENT_SOURCE_DIR}/openh264-install.nsi.in" "${CMAKE_CURRENT_BINARY_DIR}/openh264-install.nsi" @ONLY)
		set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\openh264-install.nsi\\\"")

		# Add NSI instructions to delete the openh264 codecs while uninstalling Linphone
		set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "${CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS}\n!include \\\"${ESCAPED_DOS_STYLE_SOURCE_DIR}\\\\openh264-uninstall.nsi\\\"")
	endif()

	# Sign the installer
	set(TIMESTAMP_URL "http://timestamp.verisign.com/scripts/timestamp.dll")
	set(PFX_FILE "${CMAKE_CURRENT_SOURCE_DIR}/sign/linphone.pfx")
	set(PASSPHRASE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt")
	get_filename_component(WINSDK_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH CACHE)
	find_package(PythonInterp)
	find_program(SIGNTOOL signtool PATHS ${WINSDK_DIR}/bin)
	set(SIGNTOOL_COMMAND "${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/signtool.py")
	set(PERFORM_SIGNING 0)
	if(EXISTS ${PFX_FILE})
		if(SIGNTOOL)
			set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} signtool sign /f ${PFX_FILE}")
			set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} /p ${PASSPHRASE_FILE}")
			set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} /t ${TIMESTAMP_URL}")
			message("Found signtool and certificate ${PFX_FILE}")
			set(PERFORM_SIGNING 1)
		else()
			message(STATUS "Could not find signtool! Code signing disabled (${SIGNTOOL})")
		endif()
	else()
		message(STATUS "No signtool certificate found; assuming development machine (${PFX_FILE})")
	endif()
	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/WindowsPackaging.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/WindowsPackaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/WindowsPackaging.cmake")
endif()
include(CPack)
