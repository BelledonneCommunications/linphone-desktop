############################################################################
# FindBctoolbox.cmake
# Copyright (C) 2023  Belledonne Communications, Grenoble France
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

# This module will set the following variables in your project:
#
#  BCToolbox_FOUND - The bctoolbox library has been found
#  BCToolbox_TARGET - The name of the CMake target for the bctoolbox library
#  BCToolbox_CMAKE_DIR - The bctoolbox CMake directory
#  BCToolbox_CMAKE_UTILS - The path to the bctoolbox CMake utils script
#  BCToolbox_tester_FOUND - The bctoolbox-tester library has been found
#  BCToolbox_tester_TARGET - The name of the CMake target for the bctoolbox-tester library


if(NOT TARGET bctoolbox)
    set(EXPORT_PATH ${LINPHONE_OUTPUT_DIR})
    include(GNUInstallDirs)
    set(BCToolbox_CMAKE_DIR ${EXPORT_PATH}/${CMAKE_INSTALL_DATADIR}/bctoolbox/cmake)
    include(${BCToolbox_CMAKE_DIR}/bctoolboxTargets.cmake)
endif()

set(_BCToolbox_REQUIRED_VARS BCToolbox_TARGET BCToolbox_CMAKE_DIR BCToolbox_CMAKE_UTILS)
set(_BCToolbox_CACHE_VARS ${_BCToolbox_REQUIRED_VARS})

if(TARGET bctoolbox)
	set(BCToolbox_TARGET bctoolbox)
	get_target_property(_BCToolbox_SOURCE_DIR ${BCToolbox_TARGET} SOURCE_DIR)
	set(BCToolbox_CMAKE_DIR "${_BCToolbox_SOURCE_DIR}/../cmake")
	set(BCToolbox_CMAKE_UTILS "${BCToolbox_CMAKE_DIR}/BCToolboxCMakeUtils.cmake")
	if(TARGET bctoolbox-tester)
		set(BCToolbox_tester_FOUND TRUE)
		set(BCToolbox_tester_TARGET bctoolbox-tester)
		list(APPEND _BCToolbox_CACHE_VARS BCToolbox_tester_TARGET)
	endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BCToolbox
	REQUIRED_VARS ${_BCToolbox_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_BCToolbox_CACHE_VARS})
