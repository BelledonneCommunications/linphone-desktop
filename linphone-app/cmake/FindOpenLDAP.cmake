############################################################################
# Copyright (c) 2021-2023 Belledonne Communications SARL.
#
# This file is part of liblinphone.
#
# This program is free software: you can redistribute it and/or modify	
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
############################################################################
#
# - Find the OpenLDAP include file and library
#
#  LINPHONE_TARGETS - Add usable targets into this list.
#  OPENLDAP_FOUND - system has OpenLDAP
#  OPENLDAP_INCLUDE_DIRS - the OpenLDAP include directory
#  OPENLDAP_LIBRARIES - The libraries needed to use OpenLDAP

if(TARGET ldap)
	list(APPEND LINPHONE_TARGETS ldap)
	set(OPENLDAP_LIBRARIES ldap)
	get_target_property(OPENLDAP_INCLUDE_DIRS ldap INTERFACE_INCLUDE_DIRECTORIES)

else()

	#Note : There are double find* because of priority given to the HINTS first. The second call will keep the result if there is one.
	#INCLUDES
	find_path(OPENLDAP_INCLUDE_DIRS
		NAMES ldap.h
		PATH_SUFFIXES include/openldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
		NO_DEFAULT_PATH
	)
	find_path(OPENLDAP_INCLUDE_DIRS
		NAMES ldap.h
		PATH_SUFFIXES include/openldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
	)

	#LDAP
	find_library(LDAP_LIB
		NAMES ldap libldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
		NO_DEFAULT_PATH
	)
	find_library(LDAP_LIB
		NAMES ldap libldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
	)

	#LBER
	find_library(LBER_LIB
		NAMES lber liblber
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
		NO_DEFAULT_PATH
	)
	find_library(LBER_LIB
		NAMES lber liblber
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
	)
	set(OPENLDAP_LIBRARIES ${LDAP_LIB} ${LBER_LIB})

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenLDAP
	DEFAULT_MSG
	OPENLDAP_INCLUDE_DIRS OPENLDAP_LIBRARIES
)

mark_as_advanced(OPENLDAP_INCLUDE_DIRS OPENLDAP_LIBRARIES)
