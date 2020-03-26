############################################################################
# FindMinizip.cmake
# Copyright (C) 2018  Belledonne Communications, Grenoble France
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
# - Find the minizip include file and library
#
#  MINIZIP_FOUND - system has minizip
#  MINIZIP_INCLUDE_DIRS - the minizip include directory
#  MINIZIP_LIBRARIES - The libraries needed to use minizip

find_path(MINIZIP_INCLUDE_DIRS
	NAMES mz.h
	PATH_SUFFIXES include
)

if(MINIZIP_INCLUDE_DIRS)
	set(HAVE_MZ_H 1)
endif()

find_library(MINIZIP_LIBRARIES
	NAMES minizip minizipd
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Minizip
	DEFAULT_MSG
	MINIZIP_INCLUDE_DIRS MINIZIP_LIBRARIES HAVE_MZ_H
)

mark_as_advanced(MINIZIP_INCLUDE_DIRS MINIZIP_LIBRARIES HAVE_MZ_H)
