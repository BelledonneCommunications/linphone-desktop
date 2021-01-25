################################################################################
#
#  Copyright (c) 2017-2020 Belledonne Communications SARL.
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
#-------------------------------------------------
# Customizable data
set(SOURCES
    src/Plugin.cpp
    src/NetworkAPI.cpp
    src/DataAPI.cpp
    )

set(HEADERS
    src/Plugin.hpp
    src/NetworkAPI.hpp
    src/DataAPI.hpp
    )

list(APPEND SOURCES
    src/PluginMetaData.json)

set(TARGET_NAME linphonePluginExample )
#-------------------------------------------------

find_package(bctoolbox CONFIG)
set(FULL_VERSION )
bc_compute_full_version(FULL_VERSION)
set(version_major )
set(version_minor )
set(version_patch )
set(identifiers )
set(metadata )
bc_parse_full_version("${FULL_VERSION}" version_major version_minor version_patch identifiers metadata)
set(PLUGIN_VERSION "${version_major}.${version_minor}.${version_patch}")

project(${TARGET_NAME} VERSION ${PLUGIN_VERSION})

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)

message("${TARGET_NAME} version : ${PLUGIN_VERSION}")

set(CMAKE_CXX_STANDARD 11)
SET_PROPERTY(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS true)

if(UNIX AND NOT APPLE)
    set(CMAKE_INSTALL_RPATH "$ORIGIN;$ORIGIN/lib64;$ORIGIN/../lib64;$ORIGIN/lib;$ORIGIN/../lib")
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif()
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/include)

if(WIN32)
    set(EXECUTABLE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_DIR} )
	set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_DIR} )
	set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_DIR} )
	foreach( OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES} )# Apply to all configurations
		string( TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG )
		set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${EXECUTABLE_OUTPUT_DIR} )
		set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${EXECUTABLE_OUTPUT_DIR} )
		set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${EXECUTABLE_OUTPUT_DIR} )
	endforeach( OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES )
endif()

# Build configuration
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG -DQT_NO_DEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" )

if( WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WINSOCKAPI_")#remove error from windows headers order
endif()
set(CMAKE_INCLUDE_CURRENT_DIR ON)#useful for config.h

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS ${QT5_PACKAGES_OPTIONAL} QUIET)

find_package(LinphoneCxx CONFIG)
find_package(bctoolbox CONFIG)

find_library(APP_PLUGIN_LIBRARY NAMES "app-plugin" PATHS "${APP_PLUGIN_LIB_PATH}" REQUIRED)

# ------------------------------------------------------------------------------
# Build.
# ------------------------------------------------------------------------------

add_library(${TARGET_NAME} SHARED ${SOURCES} ${HEADERS})

target_link_libraries(${TARGET_NAME} PRIVATE ${LINPHONECXX_LIBRARIES} ${APP_PLUGIN_LIBRARY})
target_compile_options(${TARGET_NAME} PRIVATE ${COMPILE_OPTIONS})
set_source_files_properties( ${TARGET_NAME} PROPERTIES EXTERNAL_OBJECT true  GENERATED true )

set_property(TARGET ${TARGET_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)   #Need by Qt
target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_PREFIX_PATH} ${LINPHONECXX_INCLUDE_DIRS})
set_target_properties(${TARGET_NAME} PROPERTIES OUTPUT_NAME "${TARGET_NAME}-${PLUGIN_VERSION}")

# Qt stuffs
set(QT5_PACKAGES Gui Core Widgets Network)
find_package(Qt5 COMPONENTS ${QT5_PACKAGES} REQUIRED)
foreach (package ${QT5_PACKAGES})
	list(APPEND QT_INCLUDED_DIRECTORIES "${Qt5${package}_INCLUDE_DIRS}")
	list(APPEND QT_ALL_LIBRARIES ${Qt5${package}_LIBRARIES})
	if(APPLE)# On Mac, shared libs can be generated with absolute path on Qt libs. This lead to get undeployable shared library.
		add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND install_name_tool -change "/usr/local/opt/qt/lib/Qt${package}.framework/Versions/5/Qt${package}" "@rpath/Qt${package}.framework/Versions/5/Qt${package}" $<TARGET_FILE:${TARGET_NAME}>)
	endif()
endforeach ()
target_include_directories(${TARGET_NAME} SYSTEM PUBLIC ${QT_INCLUDED_DIRECTORIES})
target_link_libraries(${TARGET_NAME} PUBLIC ${QT_ALL_LIBRARIES})
if(APPLE)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND install_name_tool -add_rpath "@executable_path/../Frameworks/" $<TARGET_FILE:${TARGET_NAME}>)
	add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND install_name_tool -add_rpath "@executable_path/../lib/" $<TARGET_FILE:${TARGET_NAME}>)
endif()

#-------------------------------------------------------------------------------
# IDE
#-------------------------------------------------------------------------------

source_group(
    "Json"  REGULAR_EXPRESSION ".+\.json$"
)

#-------------------------------------------------------------------------------
# Install.
#-------------------------------------------------------------------------------
set(LINPHONE_APP_CONTACT_PLUGINS_PATH "plugins/app")
install(TARGETS ${TARGET_NAME} DESTINATION "${LINPHONE_APP_CONTACT_PLUGINS_PATH}")



