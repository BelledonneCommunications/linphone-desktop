############################################################################
# FindISpell.cmake
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
# - Find the ispell include files and library
#
#  ISpell_FOUND - system has lib ispell
#  ISpell_SOURCE_DIR - the ispell include directory
#  ISpell_BINARY_DIR - the ispell library directory

if(NOT TARGET ${ISPELL_TARGET_NAME})
    set(EXPORT_PATH ${ISPELL_OUTPUT_DIR})
    include(GNUInstallDirs)
    include(${EXPORT_PATH}/${CMAKE_INSTALL_LIBDIR}/cmake/${ISPELL_TARGET_NAME}/${ISPELL_TARGET_NAME}Config.cmake)
endif()

set(_ISpell_REQUIRED_VARS ISpell_TARGET)
set(_ISpell_CACHE_VARS ${_ISpell_REQUIRED_VARS})

if(TARGET ${ISPELL_TARGET_NAME})
	set(ISpell_TARGET ${ISPELL_TARGET_NAME})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ISpell
	REQUIRED_VARS ${_ISpell_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_ISpell_CACHE_VARS})
