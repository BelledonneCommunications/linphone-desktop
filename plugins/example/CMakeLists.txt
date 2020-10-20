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
set(TARGET_NAME linphonePluginExample )

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

set(QT5_PACKAGES Core Widgets Network)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS ${QT5_PACKAGES} REQUIRED)
find_package(Qt5 COMPONENTS ${QT5_PACKAGES_OPTIONAL} QUIET)

find_package(LinphoneCxx CONFIG)
find_package(bctoolbox CONFIG)

#-------------------------------------------------

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
# ------------------------------------------------------------------------------
# Build.
# ------------------------------------------------------------------------------

add_library(${TARGET_NAME} SHARED ${SOURCES} ${HEADERS})

target_link_libraries(${TARGET_NAME} PRIVATE Qt5::Widgets Qt5::Network ${LINPHONECXX_LIBRARIES})
target_compile_options(${TARGET_NAME} PRIVATE ${COMPILE_OPTIONS})
set_source_files_properties( ${TARGET_NAME} PROPERTIES EXTERNAL_OBJECT true  GENERATED true )
set_property(TARGET ${TARGET_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)   #Need by Qt
target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_PREFIX_PATH} ${LINPHONECXX_INCLUDE_DIRS})
set_target_properties(${TARGET_NAME} PROPERTIES OUTPUT_NAME "${TARGET_NAME}-${PLUGIN_VERSION}")

#-------------------------------------------------------------------------------
# Install.
#-------------------------------------------------------------------------------
set(LINPHONE_APP_CONTACT_PLUGINS_PATH "plugins/app")
message(${CMAKE_PREFIX_PATH})
#install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}" DESTINATION "${LINPHONE_APP_CONTACT_PLUGINS_PATH}")
install(TARGETS ${TARGET_NAME} DESTINATION "${LINPHONE_APP_CONTACT_PLUGINS_PATH}")



