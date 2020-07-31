################################################################################
#
#  Copyright (c) 2017-2020 Belledonne Communications SARL.
# 
#  This file is part of linphone-desktop
#  (see https://www.linphone.org).
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#
################################################################################
cmake_minimum_required(VERSION 3.1)


## Add custom plugins
macro(get_all_subdirs result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child} AND NOT ${child} MATCHES "contacts-api")
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist})
endmacro()
get_all_subdirs(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${CMAKE_INSTALL_PREFIX}/include")


find_library(CONTACTS_PLUGIN_LIBRARY linphoneAppContactsApi HINTS "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
if(NOT CONTACTS_PLUGIN_LIBRARY)
	string(REPLACE ";" "|" PREFIX_PATH "${CMAKE_PREFIX_PATH}")
	include(ExternalProject)
	ExternalProject_Add("app-contacts" PREFIX "${CMAKE_BINARY_DIR}/contacts-api"
			SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/contacts-api"
			INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
			BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
	#	    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
			LIST_SEPARATOR | # Use the alternate list separator
			CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
		# ${APP_OPTIONS}
			BUILD_ALWAYS ON
		)
	
 	foreach(subdir ${SUBDIRS})
		message("Adding ${subdir} external plugin")
		ExternalProject_Add("app-${subdir}" PREFIX "${CMAKE_BINARY_DIR}/${subdir}"
			SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${subdir}"
			INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
			DEPENDS app-contacts
			BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> ${PROJECT_BUILD_COMMAND}
	#	    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Install step is already done at build time."
			LIST_SEPARATOR | # Use the alternate list separator
			CMAKE_ARGS ${APP_OPTIONS} ${USER_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_PREFIX_PATH=${PREFIX_PATH}
		# ${APP_OPTIONS}
			BUILD_ALWAYS ON
		)
	endforeach()
	install(CODE "message(STATUS Running plugin install)")
else()
	add_subdirectory(contacts-api)
	foreach(subdir ${SUBDIRS})
		message("Adding ${subdir} plugin")
		add_subdirectory(${subdir})
	endforeach()
endif()
