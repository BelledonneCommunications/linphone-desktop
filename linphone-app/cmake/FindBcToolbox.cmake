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
#
#  BCTOOLBOX_FOUND - System has lib bctoolbox
#  BCTOOLBOX_INCLUDE_DIRS - The bctoolbox include directories
#  BCTOOLBOX_LIBRARIES - The libraries needed to use bctoolbox
#  BCTOOLBOX_CMAKE_DIR - The bctoolbox cmake directory
#  BCTOOLBOX_CORE_FOUND - System has core bctoolbox
#  BCTOOLBOX_CORE_INCLUDE_DIRS - The core bctoolbox include directories
#  BCTOOLBOX_CORE_LIBRARIES - The core bctoolbox libraries
#  BCTOOLBOX_TESTER_FOUND - System has bctoolbox tester
#  BCTOOLBOX_TESTER_INCLUDE_DIRS - The bctoolbox tester include directories
#  BCTOOLBOX_TESTER_LIBRARIES - The bctoolbox tester libraries 

if(TARGET bctoolbox)

	set(BCTOOLBOX_CORE_LIBRARIES bctoolbox)
	get_target_property(BCTOOLBOX_CORE_INCLUDE_DIRS bctoolbox INTERFACE_INCLUDE_DIRECTORIES)
	set(BCTOOLBOX_CORE_FOUND TRUE)
	get_target_property(BCTOOLBOX_SOURCE_DIR bctoolbox SOURCE_DIR)
	set(BCTOOLBOX_CMAKE_DIR "${BCTOOLBOX_SOURCE_DIR}/../cmake")
	if(TARGET bctoolbox-tester)
		set(BCTOOLBOX_TESTER_LIBRARIES bctoolbox-tester)
		get_target_property(BCTOOLBOX_TESTER_INCLUDE_DIRS bctoolbox-tester INTERFACE_INCLUDE_DIRECTORIES)
		set(BCTOOLBOX_TESTER_FOUND TRUE)
		set(BCTOOLBOX_TESTER_COMPONENT_VARIABLES BCTOOLBOX_TESTER_FOUND BCTOOLBOX_TESTER_INCLUDE_DIRS BCTOOLBOX_TESTER_LIBRARIES)
	endif()
	set(BCTOOLBOX_LIBRARIES ${BCTOOLBOX_CORE_LIBRARIES} ${BCTOOLBOX_TESTER_LIBRARIES})
	set(BCTOOLBOX_INCLUDE_DIRS ${BCTOOLBOX_CORE_INCLUDE_DIRS} ${BCTOOLBOX_TESTER_INCLUDE_DIRS})


	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(BcToolbox
		DEFAULT_MSG
		BCTOOLBOX_INCLUDE_DIRS BCTOOLBOX_LIBRARIES BCTOOLBOX_CMAKE_DIR
		BCTOOLBOX_CORE_FOUND BCTOOLBOX_CORE_INCLUDE_DIRS BCTOOLBOX_CORE_LIBRARIES
		${BCTOOLBOX_TESTER_COMPONENT_VARIABLES}
	)

	mark_as_advanced(
		BCTOOLBOX_INCLUDE_DIRS BCTOOLBOX_LIBRARIES BCTOOLBOX_CMAKE_DIR
		BCTOOLBOX_CORE_FOUND BCTOOLBOX_CORE_INCLUDE_DIRS BCTOOLBOX_CORE_LIBRARIES
		${BCTOOLBOX_TESTER_COMPONENT_VARIABLES}
	)

endif()
