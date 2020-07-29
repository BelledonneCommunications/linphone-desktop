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

project(contactsPlugin CXX)

include(GNUInstallDirs)

set(SOURCES src/ContactsImporterNetworkAPI.cpp
		src/ContactsImporterDataAPI.cpp)
set(HEADERS src/ContactsImporterPlugin.hpp
	src/ContactsImporterNetworkAPI.hpp
	src/ContactsImporterDataAPI.hpp)


set(QT5_PACKAGES Core Widgets Network)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS ${QT5_PACKAGES} REQUIRED)
find_package(LinphoneCxx CONFIG)


#-------------------------------------------------------------------------------
# Install.
#-------------------------------------------------------------------------------
#add_custom_target(contactsPlugin ALL)

add_library(contactsPlugin STATIC ${SOURCES} ${HEADERS} )
target_link_libraries(contactsPlugin PRIVATE Qt5::Widgets Qt5::Network ${LINPHONECXX_LIBRARIES})
target_include_directories(contactsPlugin PRIVATE ${LINPHONECXX_INCLUDE_DIRS})
#install(FILES "src/ContactsImporterPlugin.hpp" DESTINATION "include/linphoneapp/contacts")
configure_file("src/ContactsImporterPlugin.hpp" "${CMAKE_INSTALL_PREFIX}/include/linphoneapp/contacts/ContactsImporterPlugin.hpp" COPYONLY)
configure_file("src/ContactsImporterNetworkAPI.hpp" "${CMAKE_INSTALL_PREFIX}/include/linphoneapp/contacts/ContactsImporterNetworkAPI.hpp" COPYONLY)
configure_file("src/ContactsImporterDataAPI.hpp" "${CMAKE_INSTALL_PREFIX}/include/linphoneapp/contacts/ContactsImporterDataAPI.hpp" COPYONLY)
install(TARGETS contactsPlugin 
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	ARICHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	)


