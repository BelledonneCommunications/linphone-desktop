############################################################################
# FindLinphone.cmake
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
# - Find the linphone include files and library
#
#  LINPHONE_FOUND - system has lib linphone
#  LINPHONE_INCLUDE_DIRS - the linphone include directory
#  LINPHONE_LIBRARIES - The library needed to use linphone

if(TARGET linphone)

	set(LINPHONE_LIBRARIES linphone)
	get_target_property(LINPHONE_INCLUDE_DIRS linphone INTERFACE_INCLUDE_DIRECTORIES)


	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(Linphone
		DEFAULT_MSG
		LINPHONE_INCLUDE_DIRS LINPHONE_LIBRARIES
	)

	mark_as_advanced(LINPHONE_INCLUDE_DIRS LINPHONE_LIBRARIES)

endif()
