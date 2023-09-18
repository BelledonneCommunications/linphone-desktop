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

set(LINPHONEAPP_NAME "linphone-app")
set(LINPHONEAPP_PLATFORM "macos")
set(SUB_TARGET app_macos)
string(TOLOWER "${LINPHONEAPP_PLATFORM}" LINPHONEAPP_PLATFORM_LOWER)
set(_MACOS_INSTALL_RELATIVE_DIR "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM_LOWER}")
set(_MACOS_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${_MACOS_INSTALL_RELATIVE_DIR}")

############################################################################
# Build each selected architecture
############################################################################

#linphone_sdk_get_inherited_cmake_args(_CMAKE_CONFIGURE_ARGS _CMAKE_BUILD_ARGS)
#linphone_sdk_get_enable_cmake_args(_MACOS_CMAKE_ARGS)

set(_MACOS_TARGETS)
foreach(_MACOS_ARCH IN LISTS _MACOS_ARCHS)
	set(_TARGET_NAME ${SUB_TARGET}-${_MACOS_ARCH})
	set(_MACOS_ARCH_BINARY_DIR "${PROJECT_BINARY_DIR}/${_TARGET_NAME}")
	#set(_MACOS_ARCH_INSTALL_DIR "${PROJECT_BINARY_DIR}/${LINPHONEAPP_NAME}/mac-${_MACOS_ARCH}")
	set(_MACOS_ARCH_INSTALL_DIR "${_MACOS_INSTALL_DIR}-${_MACOS_ARCH}")

	add_custom_target(${_TARGET_NAME} ALL
		COMMAND ${CMAKE_COMMAND} -B ${_MACOS_ARCH_BINARY_DIR} -DMONO_ARCH=${_MACOS_ARCH} ${USER_ARGS} ${OPTION_LIST} ${_MACOS_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${_MACOS_ARCH_INSTALL_DIR} -DLINPHONE_OUTPUT_DIR=${LINPHONE_OUTPUT_DIR} -DQTKEYCHAIN_OUTPUT_DIR="${QTKEYCHAIN_OUTPUT_DIR}" -DCMAKE_TOOLCHAIN_FILE=${PROJECT_SOURCE_DIR}/cmake/toolchains/toolchain-mac-x86_64.cmake -DLINPHONEAPP_BUILD_TYPE="Normal"
		COMMAND ${CMAKE_COMMAND} --build ${_MACOS_ARCH_BINARY_DIR} --target install ${_CMAKE_BUILD_ARGS}
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT "Building Linphone APP for MacOS ${_MACOS_ARCH}"
		USES_TERMINAL
		COMMAND_EXPAND_LISTS
	)
	list(APPEND _MACOS_TARGETS ${_TARGET_NAME})
endforeach()


############################################################################
# Generate the aggregated apps
############################################################################
#message(FATAL_ERROR "${CMAKE_BINARY_DIR} / ${_MACOS_INSTALL_DIR} / ${LINPHONEAPP_MACOS_ARCHS} / ${LINPHONEAPP_NAME} / ${_MACOS_ARCH_BINARY_DIR} / ${_MACOS_ARCH_INSTALL_DIR} / ${CMAKE_INSTALL_PREFIX}")
add_custom_target(gen-apps ALL
	COMMAND "${CMAKE_COMMAND}"
	"-DLINPHONESDK_DIR=${PROJECT_SOURCE_DIR}/linphone-sdk"
	"-DLINPHONEAPP_BUILD_DIR=${CMAKE_BINARY_DIR}"
	"-DLINPHONEAPP_MACOS_ARCHS=${LINPHONEAPP_MACOS_ARCHS}"
	"-DLINPHONEAPP_NAME=${SUB_TARGET}"
	"-DLINPHONEAPP_PLATFORM=${LINPHONEAPP_PLATFORM_LOWER}"
	"-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
	"-DENABLE_FAT_BINARY=${ENABLE_FAT_BINARY}"
	"-P" "${PROJECT_SOURCE_DIR}/cmake/GenerateAppMacos.cmake"
	DEPENDS ${_MACOS_TARGETS}
	WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
	COMMENT "Aggregating applications of all architectures"
	USES_TERMINAL
)

install(CODE "message(\"Dummy install target\")")

