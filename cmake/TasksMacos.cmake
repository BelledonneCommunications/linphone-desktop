############################################################################
# TasksMacos.cmake
# Copyright (C) 2010-2023 Belledonne Communications, Grenoble France
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

set(LINPHONEAPP_MACOS_ARCHS "x86_64" CACHE STRING "MacOS architectures to build: comma-separated list of values in [arm64, x86_64]")
option(ENABLE_FAT_BINARY "Enable fat binary generation using lipo." ON)

set(_MACOS_ARCHS ${LINPHONEAPP_MACOS_ARCHS})
#linphone_sdk_convert_comma_separated_list_to_cmake_list("${LINPHONESDK_MACOS_ARCHS}" _MACOS_ARCHS)


############################################################################
# Clean previously generated SDK
############################################################################

#add_custom_target(clean-sdk ALL
#  COMMAND "${CMAKE_COMMAND}"
#    "-DLINPHONESDK_DIR=${PROJECT_SOURCE_DIR}"
#    "-DLINPHONESDK_BUILD_DIR=${PROJECT_BINARY_DIR}"
#    "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
#    "-P" "${PROJECT_SOURCE_DIR}/cmake/macos/CleanSDK.cmake"
#  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
#  COMMENT "Cleaning SDK"
#  USES_TERMINAL
#)


############################################################################
# Build each selected architecture
############################################################################

#linphone_sdk_get_inherited_cmake_args(_CMAKE_CONFIGURE_ARGS _CMAKE_BUILD_ARGS)
#linphone_sdk_get_enable_cmake_args(_MACOS_CMAKE_ARGS)


#-DLINPHONE_OUTPUT_DIR=${LINPHONE_OUTPUT_DIR}


set(_MACOS_TARGETS)
foreach(_MACOS_ARCH IN LISTS _MACOS_ARCHS)
        set(_MACOS_ARCH_BINARY_DIR "${PROJECT_BINARY_DIR}/app_mac-${_MACOS_ARCH}")
        set(_MACOS_ARCH_INSTALL_DIR "${PROJECT_BINARY_DIR}/OUTPUT/mac-${_MACOS_ARCH}")
  add_custom_target(app_mac-${_MACOS_ARCH} ALL
	COMMAND ${CMAKE_COMMAND} -B ${_MACOS_ARCH_BINARY_DIR} ${USER_ARGS} ${OPTION_LIST} -DCMAKE_INSTALL_PREFIX=${_MACOS_ARCH_INSTALL_DIR} -DLINPHONE_OUTPUT_DIR=${LINPHONE_OUTPUT_DIR} -DCMAKE_TOOLCHAIN_FILE=${PROJECT_SOURCE_DIR}/cmake/toolchains/toolchain-mac-x86_64.cmake -DLINPHONEAPP_BUILD_TYPE="Normal"
    COMMAND ${CMAKE_COMMAND} --build ${_MACOS_ARCH_BINARY_DIR} --target install ${_CMAKE_BUILD_ARGS}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/linphone-app
    DEPENDS sdk
    COMMENT "Building Linphone APP for MacOS ${_MACOS_ARCH}"    
    USES_TERMINAL
    COMMAND_EXPAND_LISTS
  )
  list(APPEND _MACOS_TARGETS mac-${_MACOS_ARCH})
endforeach()


############################################################################
# Generate the aggregated frameworks
############################################################################

#add_custom_target(gen-frameworks ALL
#	COMMAND "${CMAKE_COMMAND}"
#    "-DLINPHONESDK_DIR=${PROJECT_SOURCE_DIR}"
#    "-DLINPHONESDK_BUILD_DIR=${PROJECT_BINARY_DIR}"
#    "-DLINPHONESDK_MACOS_ARCHS=${LINPHONESDK_MACOS_ARCHS}"
#    "-DCMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}/linphone-sdk/mac"
#    "-DENABLE_FAT_BINARY=${ENABLE_FAT_BINARY}"
#    "-P" "${PROJECT_SOURCE_DIR}/cmake/macos/GenerateFrameworks.cmake"
#	DEPENDS ${_MACOS_TARGETS}
#  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
#	COMMENT "Aggregating frameworks of all architectures"
#  USES_TERMINAL
#)


############################################################################
# Generate the SDK
############################################################################

#list(GET _MACOS_ARCHS 0 _FIRST_ARCH)
#add_custom_target(sdk ALL
#	COMMAND "${CMAKE_COMMAND}"
#    "-DLINPHONESDK_PLATFORM=${LINPHONESDK_PLATFORM}"
#    "-DLINPHONESDK_DIR=${PROJECT_SOURCE_DIR}"
#    "-DLINPHONESDK_BUILD_DIR=${PROJECT_BINARY_DIR}"
#    "-DLINPHONESDK_VERSION=${LINPHONESDK_VERSION}"
#    "-DLINPHONESDK_ENABLED_FEATURES_FILENAME=${CMAKE_BINARY_DIR}/enabled_features.txt"
#    "-DLINPHONESDK_MACOS_ARCHS=${LINPHONESDK_MACOS_ARCHS}"
#    "-DLINPHONESDK_MACOS_BASE_URL=${LINPHONESDK_MACOS_BASE_URL}"
#    "-DENABLE_FAT_BINARY=${ENABLE_FAT_BINARY}"
#    "-P" "${PROJECT_SOURCE_DIR}/cmake/macos/GenerateSDK.cmake"
#  DEPENDS gen-frameworks
#  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
#	COMMENT "Generating the SDK (zip file and podspec)"
#  USES_TERMINAL
#)
