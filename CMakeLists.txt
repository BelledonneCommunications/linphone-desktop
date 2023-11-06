################################################################################
#
#  Copyright (c) 2010-2023 Belledonne Communications SARL.
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

cmake_minimum_required(VERSION 3.22)


get_cmake_property(vars CACHE_VARIABLES)
foreach(var ${vars})
	get_property(currentHelpString CACHE "${var}" PROPERTY HELPSTRING)
	if("${currentHelpString}" MATCHES "No help, variable specified on the command line." OR "${currentHelpString}" STREQUAL "")
		#message("${var} = [${${var}}]  --  ${currentHelpString}") # uncomment to see the variables being processed
		list(APPEND USER_ARGS "-D${var}=${${var}}")
		if( "${var}" STREQUAL "CMAKE_PREFIX_PATH")
			set(PREFIX_PATH ";${${var}}")
		endif()
	elseif("${var}" STREQUAL "CMAKE_GENERATOR_PLATFORM" AND NOT("${${var}}" STREQUAL ""))
		message(STATUS "User-Setting Platform to ${${var}}")
	endif()
endforeach()
if(ENABLE_BUILD_VERBOSE)
	message("User Args : ${USER_ARGS}")
endif()

project(linphoneqt)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)
include(linphone-app/application_info.cmake)

set(CMAKE_CXX_STANDARD 17)
if(LINPHONEAPP_INSTALL_PREFIX)
	set(APPLICATION_OUTPUT_DIR "${LINPHONEAPP_INSTALL_PREFIX}")
else()
	set(APPLICATION_OUTPUT_DIR "${CMAKE_BINARY_DIR}/OUTPUT")
endif()


set(CMAKE_INSTALL_PREFIX "${APPLICATION_OUTPUT_DIR}")

if( APPLE )
	set(LINPHONESDK_BUILD_TYPE "Default")#Using Mac will remove all SDK targets.
	set(ENABLE_FAT_BINARY "ON") # Disable XCFrameworks as it is not supported.

	set(CMAKE_INSTALL_BINDIR "${APPLICATION_NAME}.app/Contents/MacOS")
	set(CMAKE_INSTALL_LIBDIR "${APPLICATION_NAME}.app/Contents/Frameworks")
	set(CMAKE_INSTALL_INCLUDEDIR "${APPLICATION_NAME}.app/Contents/Resources/include")
	set(CMAKE_INSTALL_DATAROOTDIR "${APPLICATION_NAME}.app/Contents/Resources/share")

	if( NOT CMAKE_OSX_DEPLOYMENT_TARGET)
		set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")#Qt: 'path' is unavailable: introduced in macOS 10.15
	endif()
	if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64")# TODO: add universal build
		set(LINPHONESDK_MACOS_ARCHS "x86_64" CACHE STRING "MacOS architectures to build for: comma-separated list of values in [x86_64]")
	else()
		set(LINPHONESDK_MACOS_ARCHS "x86_64" CACHE STRING "MacOS architectures to build for: comma-separated list of values in [x86_64]")
	endif()
	set(CMAKE_OSX_ARCHITECTURES ${LINPHONESDK_MACOS_ARCHS} CACHE STRING "")
	set(CMAKE_SYSTEM_PROCESSOR "x86_64")
elseif(WIN32)
    set(LINPHONESDK_BUILD_TYPE "Default")
else()
endif()


if(NOT LINPHONE_OUTPUT_DIR)# set this variable only if you don't build the module
	set(LINPHONE_OUTPUT_DIR "${CMAKE_INSTALL_PREFIX}")# Cannot be different from the current CMAKE_INSTALL_PREFIX
endif()

if( NOT QTKEYCHAIN_OUTPUT_DIR) # set this variable only if you don't build the module
	set(QTKEYCHAIN_OUTPUT_DIR "${CMAKE_INSTALL_PREFIX}")# Cannot be different from the current CMAKE_INSTALL_PREFIX
endif()

if(NOT ISPELL_OUTPUT_DIR) # set this variable only if you don't build the module
	set(ISPELL_OUTPUT_DIR "${CMAKE_INSTALL_PREFIX}")# Cannot be different from the current CMAKE_INSTALL_PREFIX
endif()


# Avoid cmake warning if CMP0071 is not set.
if (POLICY CMP0071)
    cmake_policy(SET CMP0071 NEW)
endif ()
#set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#------------------------------------------------------------------------------
# Prepare gobal CMAKE configuration specific to the current project

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/OUTPUT" CACHE PATH "Default linphone-app installation prefix" FORCE)
	set(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE)
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified")
	set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo" FORCE)
	# Set the available build type values for cmake-gui
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo")
endif()

# ------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#				SET OPTIONS
#-------------------------------------------------------------------------------
set(OPTION_LIST "")
#function doesn't work with strings value
function(add_option _OPTION_LIST OPTION DESC VALUE)
	option(${OPTION} ${DESC} ${VALUE})
	list(APPEND _OPTION_LIST ${${_OPTION_LIST}} "-D${OPTION}=${${OPTION}}")
	set(${${_OPTION_LIST}} ${_OPTION_LIST} PARENT_SCOPE)
endfunction()

function(add_cache _OPTION_LIST OPTION DESC VALUE)
	set(${OPTION} ${VALUE} CACHE STRING ${DESC})
	list(APPEND _OPTION_LIST ${${_OPTION_LIST}} "-D${OPTION}=${${OPTION}}")
	set(${${_OPTION_LIST}} ${_OPTION_LIST} PARENT_SCOPE)
endfunction()

add_option(OPTION_LIST ENABLE_APP_LICENSE "Enable the license in packages." ON)
add_option(OPTION_LIST ENABLE_APP_OAUTH2 "Build with OAuth2 support for remote provisioning." OFF) # Experimental.
add_option(OPTION_LIST ENABLE_APP_PACKAGING "Enable packaging" OFF)
add_option(OPTION_LIST ENABLE_APP_PACKAGE_ROOTCA "Embed the rootca file into the package" ON)
add_option(OPTION_LIST ENABLE_APP_PDF_VIEWER "Enable Pdf viewer. Only enable if the version of Qt have the module. Cannot be activated because of Qt find_package() make an error on unbound pdf." OFF)
add_option(OPTION_LIST ENABLE_APP_WEBVIEW "Enable webviews. Webview is not fully supported because of deployments. Used for subscription." OFF)
add_option(OPTION_LIST ENABLE_BUILD_APP_PLUGINS "Enable the build of plugins" ON)
add_option(OPTION_LIST ENABLE_BUILD_EXAMPLES "Enable the build of examples" OFF)
add_option(OPTION_LIST ENABLE_BUILD_VERBOSE "Enable the build generation to be more verbose" OFF)
add_option(OPTION_LIST ENABLE_CONSOLE_UI "Turn on or off compilation of console interface." OFF)
add_option(OPTION_LIST ENABLE_DAEMON "Enable the linphone daemon interface." OFF)
add_option(OPTION_LIST ENABLE_DOC "Enable API documentation generation." OFF)
add_option(OPTION_LIST ENABLE_FFMPEG "Build mediastreamer2 with ffmpeg video support. No more needed." OFF)
add_option(OPTION_LIST ENABLE_LDAP "Enable LDAP support." YES)
add_option(OPTION_LIST ENABLE_NON_FREE_CODECS "Enable the use of non free codecs" YES)
add_option(OPTION_LIST ENABLE_NON_FREE_FEATURES "Enable the use of non free codecs" ${ENABLE_NON_FREE_CODECS})
add_option(OPTION_LIST ENABLE_QT_KEYCHAIN "Build QtKeychain to manage VFS from System key stores." ON)
add_option(OPTION_LIST ENABLE_QRCODE "Enable QRCode support" OFF)#Experimental
add_option(OPTION_LIST ENABLE_RELATIVE_PREFIX "Set Internal packages relative to the binary" ON)
add_option(OPTION_LIST ENABLE_SANITIZER "Enable sanitizer." OFF)
add_option(OPTION_LIST ENABLE_STRICT "Build with strict compilator flags e.g. -Wall -Werror" OFF)
add_option(OPTION_LIST ENABLE_TESTS "Build with testing binaries of SDK" OFF)
add_option(OPTION_LIST ENABLE_TESTS_COMPONENTS "Build libbctoolbox-tester" OFF)
add_option(OPTION_LIST ENABLE_TOOLS "Enable tools of SDK" OFF)
add_option(OPTION_LIST ENABLE_UNIT_TESTS "Enable unit test of SDK." OFF)
add_option(OPTION_LIST ENABLE_UPDATE_CHECK "Enable update check." ON)
add_option(OPTION_LIST ENABLE_VIDEO "Enable Video support." YES)
add_option(OPTION_LIST ENABLE_WINDOWS_TOOLS_CHECK "Enable tools checks on Windows for auto install." OFF)
add_option(OPTION_LIST ENABLE_OPENH264 "Enable the use of OpenH264 codec" ${ENABLE_VIDEO})

add_option(OPTION_LIST LINPHONE_SDK_MAKE_RELEASE_FILE_URL "Make a RELEASE file that work along check_version and use this URL" "")

# QtKeychain
add_option(OPTION_LIST LIBSECRET_SUPPORT "Build with libsecret support" OFF) # Need libsecret-devel
if(WIN32)
	add_cache(OPTION_LIST QTKEYCHAIN_TARGET_NAME "Override Qt5Keychain library name for a workaround with windeployqt" "EQt5Keychain")
else()
	add_cache(OPTION_LIST QTKEYCHAIN_TARGET_NAME "Override Qt5Keychain library name" "Qt5Keychain")
endif()
if(WIN32)
	add_option(OPTION_LIST ENABLE_OPENSSL_EXPORT "Enable OpenSSL deployment" YES)
elseif(APPLE)
	add_option(OPTION_LIST ENABLE_OPENSSL_EXPORT "Enable OpenSSL deployment" OFF)
else()
	add_option(OPTION_LIST ENABLE_V4L "Ability to capture and display video using libv4l2 or libv4l." YES)
	add_option(OPTION_LIST ENABLE_OPENSSL_EXPORT "Enable OpenSSL deployment" OFF)
endif()

# Set some SDK variables to configure the APP build as we want it
set(ENABLE_CXX_WRAPPER ON CACHE BOOL "Build the C++ wrapper for Liblinphone." FORCE)
set(ENABLE_THEORA OFF)
set(ENABLE_QT_GL ${ENABLE_VIDEO})

# Qt5.13 because of Spitview
find_package(Qt5 5.13 COMPONENTS Core REQUIRED)

if(NOT Qt5_FOUND)
	message(FATAL_ERROR "Minimum supported Qt5 version is 5.13!")
endif()

set(LINPHONEAPP_BUILD_TYPE "Default" CACHE STRING "Type of build")
set_property(CACHE LINPHONEAPP_BUILD_TYPE PROPERTY STRINGS "Default" "Macos" "Normal")

if(LINPHONEAPP_BUILD_TYPE STREQUAL "Default")
    if(APPLE)
        set(LINPHONEAPP_BUILD_TYPE "Macos")
    else()
        set(LINPHONEAPP_BUILD_TYPE "Normal")
    endif()

endif()

if(NOT APPLE OR MONO_ARCH)
	add_custom_target(linphone-deps)
	if(NOT LINPHONE_QT_ONLY)
			function(add_linphone_sdk)
					set(CMAKE_POLICY_DEFAULT_CMP0077 NEW) # Prevent project from overriding the options we just set here
					add_subdirectory("linphone-sdk")
			endfunction()
			add_linphone_sdk()

			if(ENABLE_QT_KEYCHAIN)
					function(add_linphone_keychain)
						add_subdirectory("external/qtkeychain")
					endfunction()
					add_linphone_keychain()
			endif()
			if(NOT APPLE AND NOT WIN32)
				function(add_linphone_ispell)
					add_subdirectory("external/ispell")
				endfunction()
				add_linphone_ispell()
				SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
			endif()
	endif()
	function(add_linphone_app)
			set(CMAKE_POLICY_DEFAULT_CMP0077 NEW) # Prevent project from overriding the options we just set here
			if(APPLE)
				set(CMAKE_INSTALL_RPATH "@executable_path/../Frameworks")
			elseif(UNIX)
				set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/lib64:$ORIGIN/../lib64:$ORIGIN/lib:$ORIGIN/../lib")
			endif()
			add_subdirectory("linphone-app")
	endfunction()
	add_linphone_app()
	if(ENABLE_BUILD_APP_PLUGINS)
			add_subdirectory("plugins" "plugins-app")
	endif()

	if(NOT LINPHONE_QT_ONLY)
# Move root folders to app
		if(APPLE)
			file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
			file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")
			file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
			file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}")
			install(CODE "execute_process(COMMAND rsync -a --force \"${CMAKE_INSTALL_PREFIX}/Frameworks\"  \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}\" )") #Use rsync to bypass symlinks override issues of frameworks. copy_directory will fail without explicit error...
			install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory \"${CMAKE_INSTALL_PREFIX}/include/\" \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/\")")
			install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory \"${CMAKE_INSTALL_PREFIX}/share/\" \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/\")")
			install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory \"${CMAKE_INSTALL_PREFIX}/mkspecs/\" \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/\")")
		endif()
	endif()

else()
    include(cmake/TasksMacos.cmake)
endif()

