############################################################################
# FindMediastreamer2.cmake
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
# - Find the mediastreamer2 include files and library
#
#  MEDIASTREAMER2_FOUND - system has lib mediastreamer2
#  MEDIASTREAMER2_INCLUDE_DIRS - the mediasteamer2 include directory
#  MEDIASTREAMER2_LIBRARIES - The library needed to use mediasteamer2
#  MEDIASTREAMER2_PLUGINS_LOCATION - The location of the mediastreamer2 plugins

if(TARGET mediastreamer2)

	set(MEDIASTREAMER2_LIBRARIES mediastreamer2)
	get_target_property(MEDIASTREAMER2_INCLUDE_DIRS mediastreamer2 INTERFACE_INCLUDE_DIRECTORIES)
	define_property(TARGET PROPERTY "MS2_PLUGINS" BRIEF_DOCS "Stores the location of mediastreamer2 plugins" FULL_DOCS "Stores the location of mediastreamer2 plugins")
	get_target_property(MEDIASTREAMER2_PLUGINS_LOCATION mediastreamer2 MS2_PLUGINS)


	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(Mediastreamer2
		DEFAULT_MSG
		MEDIASTREAMER2_INCLUDE_DIRS MEDIASTREAMER2_LIBRARIES
	)

	mark_as_advanced(MEDIASTREAMER2_INCLUDE_DIRS MEDIASTREAMER2_LIBRARIES)

endif()
