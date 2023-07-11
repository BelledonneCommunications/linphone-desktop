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

if(TARGET ${QTKEYCHAIN_TARGET_NAME})
	list(APPEND LINPHONE_TARGETS ${QTKEYCHAIN_TARGET_NAME})
	set(QtKeychain_LIBRARIES ${QTKEYCHAIN_TARGET_NAME})
	get_target_property(QtKeychain_INCLUDE_DIRS ${QTKEYCHAIN_TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
	set(QtKeychain_USE_BUILD_INTERFACE TRUE)
	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(QtKeychain
		DEFAULT_MSG
		QtKeychain_INCLUDE_DIRS QtKeychain_LIBRARIES
	)
	mark_as_advanced(QtKeychain_INCLUDE_DIRS QtKeychain_LIBRARIES)
endif()

