############################################################################
# FindLime.cmake
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
# - Find the belcard include files and library
#
#  LINPHONE_TARGETS - Add usable targets into this list.
#  Lime_FOUND - system has lib belcard
#  Lime_INCLUDE_DIRS - the belcard include directory
#  Lime_LIBRARIES - The library needed to use belcard

if(NOT TARGET lime)
    set(EXPORT_PATH ${LINPHONE_OUTPUT_DIR})
    include(GNUInstallDirs)
    include(${EXPORT_PATH}/${CMAKE_INSTALL_DATADIR}/lime/cmake/limeTargets.cmake)
endif()

if(TARGET lime)
	list(APPEND LINPHONE_TARGETS lime)
    set(Lime_LIBRARIES lime)
    get_target_property(Lime_INCLUDE_DIRS lime INTERFACE_INCLUDE_DIRECTORIES)

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(Lime
            DEFAULT_MSG
            Lime_INCLUDE_DIRS Lime_LIBRARIES
    )

    mark_as_advanced(Lime_INCLUDE_DIRS Lime_LIBRARIES)
endif()
