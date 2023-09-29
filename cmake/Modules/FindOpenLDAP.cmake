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
# This module will set the following variables in your project:
#
#  OpenLDAP_FOUND - The ldap library has been found
#  OpenLDAP_TARGETS - The list of the names of the CMake targets for the openldap libraries
#  OpenLDAP_TARGET - The name of the CMake target for the ldap library
#  OpenLDAP_lber_TARGET - The name of the CMake target for the lber library


include(FindPackageHandleStandardArgs)

set(_OpenLDAP_REQUIRED_VARS OpenLDAP_TARGETS OpenLDAP_TARGET)
set(_OpenLDAP_CACHE_VARS ${_OpenLDAP_REQUIRED_VARS})

if(TARGET ldap)

	set(OpenLDAP_TARGET ldap)
	set(OpenLDAP_TARGETS ldap)
	if(TARGET lber)
		set(OpenLDAP_lber_TARGET lber)
		list(APPEND OpenLDAP_TARGETS lber)
		list(APPEND _OpenLDAP_CACHE_VARS OpenLDAP_lber_TARGET)
	endif()

else()

	# Note : There are double find* because of priority given to the HINTS first. The second call will keep the result if there is one.

	find_path(_OpenLDAP_INCLUDE_DIRS
		NAMES ldap.h
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES include/openldap
		NO_DEFAULT_PATH
	)
	find_path(_OpenLDAP_INCLUDE_DIRS
		NAMES ldap.h
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES include/openldap
	)

	find_library(_OpenLDAP_LIBRARY
		NAMES ldap libldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
		NO_DEFAULT_PATH
	)
	find_library(_OpenLDAP_LIBRARY
		NAMES ldap libldap
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
	)

	find_library(_OpenLDAP_lber_LIBRARY
		NAMES lber liblber
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
		NO_DEFAULT_PATH
	)
	find_library(_OpenLDAP_lber_LIBRARY
		NAMES lber liblber
		HINTS "${CMAKE_INSTALL_PREFIX}"
		PATH_SUFFIXES lib
	)

	if(_OpenLDAP_INCLUDE_DIRS AND _OpenLDAP_LIBRARY)
		add_library(ldap UNKNOWN IMPORTED)
		if(WIN32)
			set_target_properties(ldap PROPERTIES
				INTERFACE_INCLUDE_DIRECTORIES "${_OpenLDAP_INCLUDE_DIRS}"
				IMPORTED_IMPLIB "${_OpenLDAP_LIBRARY}"
			)
		else()
			set_target_properties(ldap PROPERTIES
				INTERFACE_INCLUDE_DIRECTORIES "${_OpenLDAP_INCLUDE_DIRS}"
				IMPORTED_LOCATION "${_OpenLDAP_LIBRARY}"
			)
		endif()
		set(OpenLDAP_TARGET ldap)
		set(OpenLDAP_TARGETS ldap)

		if(_OpenLDAP_lber_LIBRARY)
			add_library(lber UNKNOWN IMPORTED)
			if(WIN32)
				set_target_properties(lber PROPERTIES
					INTERFACE_INCLUDE_DIRECTORIES "${_OpenLDAP_INCLUDE_DIRS}"
					IMPORTED_IMPLIB "${_OpenLDAP_lber_LIBRARY}"
				)
			else()
				set_target_properties(lber PROPERTIES
					INTERFACE_INCLUDE_DIRECTORIES "${_OpenLDAP_INCLUDE_DIRS}"
					IMPORTED_LOCATION "${_OpenLDAP_lber_LIBRARY}"
				)
			endif()
			set(OpenLDAP_lber_TARGET lber)
			set(OpenLDAP_lber_FOUND TRUE)
			list(APPEND OpenLDAP_TARGETS lber)
			list(APPEND _OpenLDAP_CACHE_VARS OpenLDAP_lber_TARGET)
		endif()
	endif()

endif()

find_package_handle_standard_args(OpenLDAP
	REQUIRED_VARS ${_OpenLDAP_REQUIRED_VARS}
	HANDLE_COMPONENTS
)
mark_as_advanced(${_OpenLDAP_CACHE_VARS})

