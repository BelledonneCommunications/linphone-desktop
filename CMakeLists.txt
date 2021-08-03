################################################################################
#
#  Copyright (c) 2010-2020 Belledonne Communications SARL.
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
if(WIN32)
	if(NOT ${CMAKE_GENERATOR} MATCHES "Ninja")
		if(NOT CMAKE_GENERATOR_PLATFORM)
			set(CMAKE_GENERATOR_PLATFORM "Win32")
			message(STATUS "Setting Platform to ${CMAKE_GENERATOR_PLATFORM}")
		endif()
	endif()
endif()

project(linphoneqt)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)

# Prepare gobal CMAKE configuration specific to the current project
set(SDK_BUILD_DIR "${CMAKE_BINARY_DIR}/WORK")       # SDK build in WORK. Keep all in it.
set(LINPHONE_OUTPUT_DIR "${CMAKE_BINARY_DIR}/linphone-sdk/desktop")

set(APPLICATION_OUTPUT_DIR "${CMAKE_BINARY_DIR}/OUTPUT")

set(CMAKE_PREFIX_PATH "${LINPHONE_OUTPUT_DIR};${APPLICATION_OUTPUT_DIR};${APPLICATION_OUTPUT_DIR}/include${PREFIX_PATH}")
if(WIN32)
	set( CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${APPLICATION_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}")
elseif(APPLE)
	set( CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${APPLICATION_NAME}.app/Contents/Frameworks")
else()
	set( CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${APPLICATION_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}")
endif()
string(REPLACE ";" "|" PREFIX_PATH "${CMAKE_PREFIX_PATH}")
#set(PREFIX_PATH "${LINPHONE_OUTPUT_DIR}|${APPLICATION_OUTPUT_DIR}${PREFIX_PATH}")

# Avoid cmake warning if CMP0071 is not set.
if (POLICY CMP0071)
    cmake_policy(SET CMP0071 NEW)
endif ()
#set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#------------------------------------------------------------------------------

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

option(ENABLE_APP_PACKAGING "Enable packaging" NO)
option(ENABLE_UPDATE_CHECK "Enable update check." YES)
option(ENABLE_UNIT_TESTS "Enable unit test of SDK." NO  )
option(ENABLE_TESTS "Build with testing binaries of SDK" NO  )
option(ENABLE_TESTS_COMPONENTS "Build libbctoolbox-tester" NO  )
option(ENABLE_TOOLS "Enable tools of SDK" NO)
option(ENABLE_STRICT "Build with strict compilator flags e.g. -Wall -Werror" NO)
option(ENABLE_FFMPEG "Build mediastreamer2 with ffmpeg video support." YES)
option(ENABLE_BUILD_VERBOSE "Enable the build generation to be more verbose" NO)
option(ENABLE_OPENH264 "Enable the use of OpenH264 codec" YES)
option(ENABLE_NON_FREE_CODECS "Enable the use of non free codecs" YES)
option(ENABLE_BUILD_APP_PLUGINS "Enable the build of plugins" YES)
option(ENABLE_BUILD_EXAMPLES "Enable the build of examples" NO)
option(ENABLE_VIDEO "Enable Video support." YES)

option(ENABLE_DAEMON "Enable the linphone daemon interface." NO)
option(ENABLE_CONSOLE_UI "Turn on or off compilation of console interface." NO)




if(WIN32 OR APPLE)
else()
	option(ENABLE_V4L "Ability to capture and display video using libv4l2 or libv4l." YES)
endif()

option(ENABLE_RELATIVE_PREFIX "Set Internal packages relative to the binary" YES)

set(APP_OPTIONS "-DENABLE_UPDATE_CHECK=${ENABLE_UPDATE_CHECK}")
list(APPEND APP_OPTIONS "-DENABLE_APP_PACKAGING=${ENABLE_APP_PACKAGING}")
list(APPEND APP_OPTIONS "-DENABLE_UNIT_TESTS=${ENABLE_UNIT_TESTS}")
list(APPEND APP_OPTIONS "-DENABLE_TESTS=${ENABLE_TESTS}")
list(APPEND APP_OPTIONS "-DENABLE_TESTS_COMPONENTS=${ENABLE_TESTS_COMPONENTS}")
list(APPEND APP_OPTIONS "-DENABLE_TOOLS=${ENABLE_TOOLS}")
list(APPEND APP_OPTIONS "-DENABLE_STRICT=${ENABLE_STRICT}")
list(APPEND APP_OPTIONS "-DENABLE_FFMPEG=${ENABLE_FFMPEG}")
list(APPEND APP_OPTIONS "-DENABLE_BUILD_VERBOSE=${ENABLE_BUILD_VERBOSE}")
list(APPEND APP_OPTIONS "-DENABLE_OPENH264=${ENABLE_OPENH264}")
list(APPEND APP_OPTIONS "-DENABLE_NON_FREE_CODECS=${ENABLE_NON_FREE_CODECS}")
list(APPEND APP_OPTIONS "-DENABLE_BUILD_EXAMPLES=${ENABLE_BUILD_EXAMPLES}")
list(APPEND APP_OPTIONS "-DENABLE_DAEMON=${ENABLE_DAEMON}")
list(APPEND APP_OPTIONS "-DENABLE_CONSOLE_UI=${ENABLE_CONSOLE_UI}")
list(APPEND APP_OPTIONS "-DENABLE_VIDEO=${ENABLE_VIDEO}")

	
if(ENABLE_V4L)
    list(APPEND APP_OPTIONS "-DENABLE_V4L=${ENABLE_V4L}")
endif()
list(APPEND APP_OPTIONS "-DENABLE_RELATIVE_PREFIX=${ENABLE_RELATIVE_PREFIX}")

list(APPEND APP_OPTIONS "-DLINPHONE_OUTPUT_DIR=${LINPHONE_OUTPUT_DIR}")
list(APPEND APP_OPTIONS "-DENABLE_QT_GL=${ENABLE_VIDEO}")#Activate on video

include(ExternalProject)
set(PROJECT_BUILD_COMMAND "")
if(CMAKE_BUILD_PARALLEL_LEVEL)
	list(APPEND APP_OPTIONS "-DCMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL}")
	if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12.0") #CMAKE_BUILD_PARALLEL_LEVEL will not always work for External projects
		list(APPEND PROJECT_BUILD_COMMAND "--parallel" "${CMAKE_BUILD_PARALLEL_LEVEL}")
	endif()
endif()
if(CMAKE_VERBOSE_MAKEFILE)
	list(APPEND APP_OPTIONS "-DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}")
	if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.14.0")
		list(APPEND PROJECT_BUILD_COMMAND "--verbose")
	endif()
endif()
if(UNIX AND NOT APPLE)
	set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/lib64:$ORIGIN/../lib64:$ORIGIN/lib:$ORIGIN/../lib:${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}")
	list(APPEND APP_OPTIONS "-DCMAKE_INSTALL_RPATH=${CMAKE_INSTALL_RPATH}")
endif()



if(ENABLE_BUILD_APP_PLUGINS)
	file(GLOB children "plugins/*")
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child} AND (ENABLE_BUILD_EXAMPLES OR NOT ${child} MATCHES "example"))
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(LENGTH dirlist count)
	if(NOT count)
		set(ENABLE_BUILD_APP_PLUGINS OFF)
		message(STATUS "No plugins found for the application to build")
	endif()
endif()


if(NOT LINPHONE_QT_ONLY)
ExternalProject_Add(sdk PREFIX "${CMAKE_BINARY_DIR}/sdk"
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/linphone-sdk"
    INSTALL_DIR "${LINPHONE_OUTPUT_DIR}"
    STAMP_DIR "${SDK_BUILD_DIR}/stamp"
    BINARY_DIR "${SDK_BUILD_DIR}"
    STEP_TARGETS build
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
    LIST_SEPARATOR | # Use the alternate list separator
    CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
    BUILD_ALWAYS NO #${DO_BUILD}
)
ExternalProject_Add_Step(sdk force_build
	COMMENT "Forcing build for 'desktop'"
	DEPENDEES configure
	DEPENDERS build
	ALWAYS 1
)
endif()
include(FindPkgConfig)

set(APP_DEPENDS sdk)
find_package(Qt5 5.9 COMPONENTS Core REQUIRED)

if ( NOT Qt5_FOUND )
	message(FATAL_ERROR "Minimum supported Qt5 version is 5.9!")
endif()

find_package(LinphoneCxx CONFIG QUIET)
find_package(Linphone CONFIG QUIET)
find_package(bctoolbox CONFIG QUIET)
find_package(belcard CONFIG QUIET)
find_package(Mediastreamer2 CONFIG QUIET)
find_package(ortp CONFIG QUIET)

if(NOT (LinphoneCxx_FOUND) OR NOT (Linphone_FOUND) OR NOT (bctoolbox_FOUND) OR NOT (belcard_FOUND) OR NOT (Mediastreamer2_FOUND) OR NOT (ortp_FOUND) OR FORCE_APP_EXTERNAL_PROJECTS)
	message("Projects are set as External projects. You can start building them by using for example : cmake --build . --target install")
	ExternalProject_Add(linphone-qt PREFIX "${CMAKE_BINARY_DIR}/linphone-app"
		SOURCE_DIR "${CMAKE_SOURCE_DIR}/linphone-app"
		INSTALL_DIR "${APPLICATION_OUTPUT_DIR}"
		BINARY_DIR "${CMAKE_BINARY_DIR}/linphone-app"
		DEPENDS ${APP_DEPENDS}
		BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
		INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
		LIST_SEPARATOR | # Use the alternate list separator
		CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
	# ${APP_OPTIONS}
		BUILD_ALWAYS ON
	)
	if( ENABLE_BUILD_APP_PLUGINS)
		ExternalProject_Add(app-plugins PREFIX "${CMAKE_BINARY_DIR}/plugins-app"
			SOURCE_DIR "${CMAKE_SOURCE_DIR}/plugins"
			INSTALL_DIR "${APPLICATION_OUTPUT_DIR}"
			BINARY_DIR "${CMAKE_BINARY_DIR}/plugins-app"
			DEPENDS linphone-qt
			BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
			INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
			LIST_SEPARATOR | # Use the alternate list separator
			CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
		)
	endif()
	install(CODE "message(STATUS Running install)")
	set(AUTO_REGENERATION auto_regeneration)
	if(	ENABLE_BUILD_APP_PLUGINS)
		add_custom_target(${AUTO_REGENERATION} ALL
			COMMAND ${CMAKE_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}
			DEPENDS app-plugins)
	else()
		add_custom_target(${AUTO_REGENERATION} ALL
			COMMAND ${CMAKE_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}
			DEPENDS linphone-qt)
	endif()
else()
	message("Adding Linphone Desktop in an IDE-friendly state")
	set(CMAKE_INSTALL_PREFIX "${APPLICATION_OUTPUT_DIR}")
	add_subdirectory(${CMAKE_SOURCE_DIR}/linphone-app)
	if(NOT LINPHONE_QT_ONLY)
		add_dependencies(app-library ${APP_DEPENDS})
	endif()
	if( ENABLE_BUILD_APP_PLUGINS)
		add_subdirectory(${CMAKE_SOURCE_DIR}/plugins "plugins-app")
	endif()
endif()
ExternalProject_Add(linphone-qt-only PREFIX "${CMAKE_BINARY_DIR}/linphone-app"
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/linphone-app"
    INSTALL_DIR "${APPLICATION_OUTPUT_DIR}"
    BINARY_DIR "${CMAKE_BINARY_DIR}/linphone-app"
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
#    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
    LIST_SEPARATOR | # Use the alternate list separator
    CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
    EXCLUDE_FROM_ALL ON
    #BUILD_ALWAYS ON
)
