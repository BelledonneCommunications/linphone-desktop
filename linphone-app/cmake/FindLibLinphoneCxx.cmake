############################################################################
# FindLinphoneCxx.cmake
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
#  LibLinphoneCxx_FOUND - The liblinphone library has been found
#  LibLinphoneCxx_TARGET - The name of the CMake target for the liblinphone library

if(NOT TARGET liblinphone++)
    set(EXPORT_PATH ${LINPHONE_OUTPUT_DIR})
    include(GNUInstallDirs)
    include(${EXPORT_PATH}/${CMAKE_INSTALL_DATADIR}/LinphoneCxx/cmake/LinphoneCxxTargets.cmake)
endif()

set(_LibLinphoneCxx_REQUIRED_VARS LibLinphoneCxx_TARGET)
set(_LibLinphoneCxx_CACHE_VARS ${_LibLinphoneCxx_REQUIRED_VARS})

if(TARGET liblinphone++)
	set(LibLinphoneCxx_TARGET liblinphone++)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibLinphoneCxx
	REQUIRED_VARS ${_LibLinphoneCxx_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_LibLinphoneCxx_CACHE_VARS})

