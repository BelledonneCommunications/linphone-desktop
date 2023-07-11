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
#
# - Find the bctoolbox include files and library
#  LINPHONE_TARGETS - Add usable targets into this list.
#  BCToolbox_FOUND - System has lib bctoolbox
#  BCToolbox_INCLUDE_DIRS - The bctoolbox include directories
#  BCToolbox_LIBRARIES - The libraries needed to use bctoolbox
#  BCToolbox_CMAKE_DIR - The bctoolbox cmake directory
#  BCToolbox_CORE_FOUND - System has core bctoolbox
#  BCToolbox_CORE_INCLUDE_DIRS - The core bctoolbox include directories
#  BCToolbox_CORE_LIBRARIES - The core bctoolbox libraries
#  BCToolbox_TESTER_FOUND - System has bctoolbox tester
#  BCToolbox_TESTER_INCLUDE_DIRS - The bctoolbox tester include directories
#  BCToolbox_TESTER_LIBRARIES - The bctoolbox tester libraries 

if(NOT TARGET bctoolbox)
    set(EXPORT_PATH ${LINPHONE_OUTPUT_DIR})
    include(GNUInstallDirs)
    set(BCToolbox_CMAKE_DIR ${EXPORT_PATH}/${CMAKE_INSTALL_DATADIR}/bctoolbox/cmake)
    include(${BCToolbox_CMAKE_DIR}/bctoolboxTargets.cmake)
else()
    get_target_property(BCToolbox_SOURCE_DIR bctoolbox SOURCE_DIR)
    set(BCToolbox_CMAKE_DIR "${BCToolbox_SOURCE_DIR}/../cmake")
endif()

if(TARGET bctoolbox)
	list(APPEND LINPHONE_TARGETS bctoolbox)
	include(${BCToolbox_CMAKE_DIR}/BCToolboxCMakeUtils.cmake)
    set(BCToolbox_CORE_LIBRARIES bctoolbox)
    get_target_property(BCToolbox_CORE_INCLUDE_DIRS bctoolbox INTERFACE_INCLUDE_DIRECTORIES)
    set(BCToolbox_CORE_FOUND TRUE)

    if(TARGET bctoolbox-tester)
            set(BCToolbox_TESTER_LIBRARIES bctoolbox-tester)
            get_target_property(BCToolbox_TESTER_INCLUDE_DIRS bctoolbox-tester INTERFACE_INCLUDE_DIRECTORIES)
            set(BCToolbox_TESTER_FOUND TRUE)
            set(BCToolbox_TESTER_COMPONENT_VARIABLES BCToolbox_TESTER_FOUND BCToolbox_TESTER_INCLUDE_DIRS BCToolbox_TESTER_LIBRARIES)
    endif()
    set(BCToolbox_LIBRARIES ${BCToolbox_CORE_LIBRARIES} ${BCToolbox_TESTER_LIBRARIES})
    set(BCToolbox_INCLUDE_DIRS ${BCToolbox_CORE_INCLUDE_DIRS} ${BCToolbox_TESTER_INCLUDE_DIRS})


    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(BCToolbox
            DEFAULT_MSG
            BCToolbox_INCLUDE_DIRS BCToolbox_LIBRARIES BCToolbox_CMAKE_DIR
            BCToolbox_CORE_FOUND BCToolbox_CORE_INCLUDE_DIRS BCToolbox_CORE_LIBRARIES
            ${BCToolbox_TESTER_COMPONENT_VARIABLES}
    )

    mark_as_advanced(
            BCToolbox_INCLUDE_DIRS BCToolbox_LIBRARIES BCToolbox_CMAKE_DIR
            BCToolbox_CORE_FOUND BCToolbox_CORE_INCLUDE_DIRS BCToolbox_CORE_LIBRARIES
            ${BCToolbox_TESTER_COMPONENT_VARIABLES}
    )
endif()