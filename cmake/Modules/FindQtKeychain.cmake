############################################################################
# FindQtKeychain.cmake
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
# - Find the linphonecxx include files and library
#
#  QtKeychain_FOUND - system has lib linphonecxx
#  QtKeychain_INCLUDE_DIRS - the linphonecxx include directory
#  QtKeychain_LIBRARIES - The library needed to use linphonecxx
if(NOT TARGET ${QTKEYCHAIN_TARGET_NAME})
    set(EXPORT_PATH ${QTKEYCHAIN_OUTPUT_DIR})
    include(GNUInstallDirs)
    include(${EXPORT_PATH}/${CMAKE_INSTALL_LIBDIR}/cmake/${QTKEYCHAIN_TARGET_NAME}/${QTKEYCHAIN_TARGET_NAME}Config.cmake)
endif()

set(_QtKeychain_REQUIRED_VARS QtKeychain_TARGET)
set(_QtKeychain_CACHE_VARS ${_QtKeychain_REQUIRED_VARS})

if(TARGET ${QTKEYCHAIN_TARGET_NAME})
	set(QtKeychain_TARGET ${QTKEYCHAIN_TARGET_NAME})
	set(QtKeychain_USE_BUILD_INTERFACE TRUE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(QtKeychain
	REQUIRED_VARS ${_QtKeychain_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_QtKeychain_CACHE_VARS})

