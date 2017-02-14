############################################################################
# additional_steps.cmake
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

# Create a shortcut to linphone.exe in install prefix
if(LINPHONE_BUILDER_TARGET STREQUAL linphoneqt AND WIN32)
	set(SHORTCUT_PATH "${CMAKE_INSTALL_PREFIX}/linphone.lnk")
	set(SHORTCUT_TARGET_PATH "${CMAKE_INSTALL_PREFIX}/bin/linphone.exe")
	set(SHORTCUT_WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}")
	configure_file("${CMAKE_CURRENT_LIST_DIR}/linphone_package/winshortcut.vbs.in" "${CMAKE_CURRENT_BINARY_DIR}/winshortcut.vbs" @ONLY)
	add_custom_command(OUTPUT "${SHORTCUT_PATH}" COMMAND "cscript" "${CMAKE_CURRENT_BINARY_DIR}/winshortcut.vbs")
	add_custom_target(linphoneqt_winshortcut ALL DEPENDS "${SHORTCUT_PATH}" TARGET_linphone_builder)
endif()

# Packaging
if(ENABLE_PACKAGING)
	get_cmake_property(_varnames VARIABLES)
	set(ENABLE_VARIABLES )
	foreach(_varname ${_varnames})
		if(_varname MATCHES "^ENABLE_.*")
			list(APPEND ENABLE_VARIABLES -D${_varname}=${${_varname}})
	    endif()
	endforeach()

	if(LINPHONE_BUILDER_TARGET STREQUAL linphoneqt)
		# Linphone and linphone SDK packages
		linphone_builder_apply_flags()
		linphone_builder_set_ep_directories(linphone_package)
		linphone_builder_expand_external_project_vars()
		ExternalProject_Add(TARGET_linphone_package
			DEPENDS TARGET_linphone_builder
			TMP_DIR ${ep_tmp}
			BINARY_DIR ${ep_build}
			SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/linphone_package"
			DOWNLOAD_COMMAND ""
			CMAKE_GENERATOR ${CMAKE_GENERATOR}
			CMAKE_ARGS ${LINPHONE_BUILDER_EP_ARGS} -DCMAKE_INSTALL_PREFIX=${LINPHONE_BUILDER_WORK_DIR}/PACKAGE -DTOOLS_DIR=${CMAKE_BINARY_DIR}/programs -DLINPHONE_OUTPUT_DIR=${CMAKE_INSTALL_PREFIX} -DLINPHONE_DESKTOP_DIR=${CMAKE_CURRENT_LIST_DIR}/../linphone-desktop -DLINPHONE_SOURCE_DIR=${EP_linphone_SOURCE_DIR} ${ENABLE_VARIABLES} -DOPENH264_VERSION=${OPENH264_VERSION}
		)
	endif()
endif()
