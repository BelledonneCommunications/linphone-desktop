############################################################################
# packaging.cmake
# Copyright (C) 2020  Belledonne Communications, Grenoble France
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

if (APPLE)
	#execute_process(COMMAND install_name_tool -id "@executable_path/../lib/libminizip.dylib" "${CMAKE_INSTALL_PREFIX}/lib/libminizip.dylib")
	execute_process(COMMAND install_name_tool -add_rpath "@executable_path/../Frameworks/" "${CMAKE_INSTALL_PREFIX}/bin/linphone")
	execute_process(COMMAND install_name_tool -add_rpath "@executable_path/../lib/" "${CMAKE_INSTALL_PREFIX}/bin/linphone")
else ()
endif ()
