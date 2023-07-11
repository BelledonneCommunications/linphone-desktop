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
if( APPLE )
	if( NOT CMAKE_OSX_DEPLOYMENT_TARGET)
		set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9" CACHE STRING "Minimum OS X deployment version")
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
endif()

project(linphoneqt)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)

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

option(ENABLE_APP_LICENSE "Enable the license in packages." ON)
option(ENABLE_APP_OAUTH2 "Build with OAuth2 support for remote provisioning." OFF) # Experimental.
option(ENABLE_APP_PACKAGING "Enable packaging" OFF)
option(ENABLE_APP_PACKAGE_ROOTCA "Embed the rootca file into the package" ON)
option(ENABLE_APP_PDF_VIEWER "Enable Pdf viewer" ON)
option(ENABLE_APP_WEBVIEW "Enable webviews." OFF) # Webview is not fully supported because of deployments. Used for subscription.
option(ENABLE_BUILD_APP_PLUGINS "Enable the build of plugins" ON)
option(ENABLE_BUILD_EXAMPLES "Enable the build of examples" OFF)
option(ENABLE_BUILD_VERBOSE "Enable the build generation to be more verbose" OFF)
option(ENABLE_QT_KEYCHAIN "Build QtKeychain to manage VFS from System key stores." ON)
option(ENABLE_UPDATE_CHECK "Enable update check." ON)
option(LINPHONE_SDK_MAKE_RELEASE_FILE_URL "Make a RELEASE file that work along check_version and use this URL" "")

option(ENABLE_RELATIVE_PREFIX "Set Internal packages relative to the binary" ON)

# QtKeychain
option(LIBSECRET_SUPPORT "Build with libsecret support" OFF) # Need libsecret-devel

# Set some SDK variables to configure the APP build as we want it
set(ENABLE_CONSOLE_UI OFF)
set(ENABLE_CXX_WRAPPER ON CACHE BOOL "Build the C++ wrapper for Liblinphone." FORCE)
set(ENABLE_DAEMON OFF)
set(ENABLE_FFMPEG OFF)
set(ENABLE_LDAP ON)
set(ENABLE_NON_FREE_FEATURES ON)
set(ENABLE_OPENH264 ON)
set(ENABLE_QRCODE OFF) # Experimental
set(ENABLE_SANITIZER OFF)
set(ENABLE_STRICT OFF)
set(ENABLE_TESTS_COMPONENT OFF)
set(ENABLE_THEORA OFF)
set(ENABLE_TOOLS OFF)
set(ENABLE_VIDEO ON)
if(WIN32)
	set(ENABLE_OPENSSL_EXPORT ON)
elseif(APPLE)
	set(ENABLE_OPENSSL_EXPORT OFF)
else()
	set(ENABLE_V4L ON)
	set(ENABLE_OPENSSL_EXPORT OFF)
endif()


find_package(Qt5 5.10 COMPONENTS Core REQUIRED)

if(NOT Qt5_FOUND)
	message(FATAL_ERROR "Minimum supported Qt5 version is 5.10!")
endif()

if(NOT LINPHONE_QT_ONLY)

	function(add_linphone_sdk)
		set(CMAKE_POLICY_DEFAULT_CMP0077 NEW) # Prevent project from overriding the options we just set here
		add_subdirectory("linphone-sdk")
	endfunction()
	add_linphone_sdk()

	if(ENABLE_QT_KEYCHAIN)
		set(QTKEYCHAIN_TARGET_NAME "EQt5Keychain")
		add_subdirectory("external/qtkeychain")
	endif()
endif()

function(add_linphone_app)
	if(APPLE)
		add_compile_definitions("ENABLE_FAT_BINARY=ON") # Disable XCFrameworks as it is not supported.
	elseif(UNIX)
		set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/lib64:$ORIGIN/../lib64:$ORIGIN/lib:$ORIGIN/../lib")
	endif()

	add_subdirectory("linphone-app")
endfunction()
add_linphone_app()


if(ENABLE_BUILD_APP_PLUGINS)
	add_subdirectory("plugins" "plugins-app")
endif()
