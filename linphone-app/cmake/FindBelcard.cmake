############################################################################
# FindBelcard.cmake
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
#  Belcard_FOUND - The liblinphone library has been found
#  Belcard_TARGET - The name of the CMake target

if(NOT TARGET belcard)
    set(EXPORT_PATH ${LINPHONE_OUTPUT_DIR})
    include(GNUInstallDirs)
    include(${EXPORT_PATH}/${CMAKE_INSTALL_DATADIR}/Belcard/cmake/BelcardTargets.cmake)
endif()

set(_Belcard_REQUIRED_VARS Belcard_TARGET)
set(_Belcard_CACHE_VARS ${_Belcard_REQUIRED_VARS})

if(TARGET belcard)
	set(Belcard_TARGET belcard)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Belcard
	REQUIRED_VARS ${_Belcard_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_Belcard_CACHE_VARS})
