############################################################################
# Copyright (c) 2025 Belledonne Communications SARL.
#
# This file is part of Linphone.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
############################################################################
# This module will set the following variables in your project:
#
#  Crashpad_FOUND - The crashpad library has been found
#  Crashpad::Crashpad - Imported target to build against
#  CRASHPAD_BIN_DIR - Directory where the crashpad_handler executable is found
#  CRASHPAD_EXECUTABLE_NAME - Crash handler executable
#  CRASHPAD_INCLUDE_DIR - Headers folder of Crashpad.

if(TARGET Crashpad)
	get_target_property(CRASHPAD_BIN_DIR Crashpad CRASHPAD_BIN_DIR)
	get_target_property(CRASHPAD_BUILD_DIR Crashpad CRASHPAD_BUILD_DIR)
	get_target_property(CRASHPAD_EXECUTABLE_NAME Crashpad CRASHPAD_EXECUTABLE_NAME)
	get_target_property(CRASHPAD_GEN_DIR Crashpad CRASHPAD_GEN_DIR)
	get_target_property(CRASHPAD_INCLUDE_DIR Crashpad CRASHPAD_INCLUDE_DIR)
	get_target_property(CRASHPAD_LIB_DIR Crashpad CRASHPAD_LIB_DIR)
	get_target_property(CRASHPAD_SOURCE_DIR Crashpad CRASHPAD_SOURCE_DIR)
endif()

if(NOT CRASHPAD_BUILD_DIR)
  set(CRASHPAD_BUILD_DIR ${CMAKE_BINARY_DIR}/external/google/crashpad/out)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CRASHPAD_BUILD_DIR ${CRASHPAD_BUILD_DIR}/debug)
  else()
    set(CRASHPAD_BUILD_DIR ${CRASHPAD_BUILD_DIR}/release)
  endif()
endif()
if(NOT CRASHPAD_SOURCE_DIR)
  set(CRASHPAD_SOURCE_DIR ${CMAKE_SOURCE_DIR}/external/google/crashpad)
endif()

if(NOT CRASHPAD_EXECUTABLE_NAME OR NOT CRASHPAD_BIN_DIR)
  find_program(CRASHPAD_EXECUTABLE
    NAMES crashpad_handler.exe crashpad_handler
    HINTS
      "${CRASHPAD_BUILD_DIR}"
      "${CMAKE_PREFIX_PATH}"
  )
  get_filename_component(CRASHPAD_BIN_DIR ${CRASHPAD_EXECUTABLE} DIRECTORY)
  get_filename_component(CRASHPAD_EXECUTABLE_NAME ${CRASHPAD_EXECUTABLE} NAME)
endif()



if(NOT CRASHPAD_INCLUDE_DIR)
  find_path(CRASHPAD_INCLUDE_DIR
    NAMES client/crashpad_client.h
    HINTS
      "${CRASHPAD_SOURCE_DIR}"
      "${CMAKE_PREFIX_PATH}"
  )
endif()

if(NOT CRASHPAD_LIB_DIR)
  find_path(CRASHPAD_LIB_DIR
    NAMES util/libutil.a util/util.lib
    HINTS
      "${CRASHPAD_BIN_DIR}/obj"
      "${CMAKE_PREFIX_PATH}"
  )
endif()

if(NOT CRASHPAD_GEN_DIR)
  find_path(CRASHPAD_GEN_DIR
      NAMES build/chromeos_buildflags.h
      PATH_SUFFIXES gen
      HINTS
        "${CRASHPAD_BIN_DIR}"
        "${CMAKE_PREFIX_PATH}"
  )
endif()

if(APPLE)
  find_path(CRASHPAD_OBJ_DIR
    NAMES mig_output.child_portServer.o
    PATH_SUFFIXES gen/util/mach
    HINTS
      "${CRASHPAD_OBJECT_DIR}"
      "${CRASHPAD_LIB_DIR}"
      "${CMAKE_PREFIX_PATH}"
    )
  set(CRASHPAD_APPLE_VARS CRASHPAD_OBJ_DIR CRASHPAD_GEN_DIR)
  find_library(FWbsm bsm)
  find_library(FWAppKit AppKit)
  find_library(FWIOKit IOKit)
  find_library(FWSecurity Security)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Crashpad DEFAULT_MSG
  CRASHPAD_BIN_DIR CRASHPAD_INCLUDE_DIR CRASHPAD_LIB_DIR CRASHPAD_EXECUTABLE_NAME ${CRASHPAD_APPLE_VARS}
)

#[[

if(Crashpad_FOUND)
  add_library(Crashpad::Crashpad UNKNOWN IMPORTED)
  target_include_directories(Crashpad::Crashpad INTERFACE
    "${CRASHPAD_INCLUDE_DIR}"
    "${CRASHPAD_INCLUDE_DIR}/third_party/mini_chromium/mini_chromium"
    "${CRASHPAD_GEN_DIR}")
  if(WIN32)
    target_link_libraries(Crashpad::Crashpad INTERFACE
      "${CRASHPAD_LIB_DIR}/third_party/mini_chromium/mini_chromium/base/base.lib"
      "${CRASHPAD_LIB_DIR}/util/util.lib"
      "${CRASHPAD_LIB_DIR}/client/client.lib"
      "${CRASHPAD_LIB_DIR}/client/common.lib"
      advapi32)
    set_target_properties(Crashpad::Crashpad PROPERTIES
      IMPORTED_LOCATION "${CRASHPAD_LIB_DIR}/client/client.lib")
  elseif(APPLE)
    target_link_libraries(Crashpad::Crashpad INTERFACE
      "${CRASHPAD_LIB_DIR}/third_party/mini_chromium/mini_chromium/base/libbase.a"
      "${CRASHPAD_LIB_DIR}/util/libutil.a"
      "${CRASHPAD_LIB_DIR}/client/libclient.a"
      "${CRASHPAD_OBJ_DIR}/mig_output.child_portServer.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.child_portUser.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.excServer.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.excUser.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.mach_excServer.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.mach_excUser.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.notifyServer.o"
      "${CRASHPAD_OBJ_DIR}/mig_output.notifyUser.o"
      ${FWbsm} ${FWAppKit} ${FWIOKit} ${FWSecurity})
    set_target_properties(Crashpad::Crashpad PROPERTIES
      IMPORTED_LOCATION "${CRASHPAD_LIB_DIR}/client/libclient.a")
  elseif(UNIX)
    target_link_libraries(Crashpad::Crashpad INTERFACE
      "${CRASHPAD_LIB_DIR}/third_party/mini_chromium/mini_chromium/base/libbase.a"
      "${CRASHPAD_LIB_DIR}/util/libutil.a"
      "${CRASHPAD_LIB_DIR}/client/libclient.a")
    set_target_properties(Crashpad::Crashpad PROPERTIES
      IMPORTED_LOCATION "${CRASHPAD_LIB_DIR}/client/libclient.a")
  endif()
endif()
]]#