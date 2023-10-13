################################################################################
#
#  Copyright (c) 2017-2024 Belledonne Communications SARL.
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

set(TARGET_NAME Linphone)

if (GIT_EXECUTABLE AND NOT(LINPHONEAPP_VERSION))
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always
    OUTPUT_VARIABLE LINPHONEAPP_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../.."
  )
elseif (NOT(LINPHONEAPP_VERSION))
  set(LINPHONEAPP_VERSION "0.0.0")
endif ()

set(LINPHONE_VERSION ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION})
set(PACKAGE_VERSION "${LINPHONEAPP_VERSION}")

install(TARGETS ${TARGET_NAME}
    BUNDLE DESTINATION .
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(ENABLE_APP_PACKAGE_ROOTCA)
	install(FILES "${LINPHONE_OUTPUT_DIR}/share/linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}")
endif()

# ==============================================================================
#                               CPack.
# ==============================================================================
set(LINPHONE_QML_DIR "${CMAKE_SOURCE_DIR}/Linphone/view")
set(QT_PATH "${Qt6Core_DIR}/../../..")

if(${ENABLE_APP_PACKAGING})
	set(CPACK_BINARY_STGZ OFF)
	set(CPACK_BINARY_TGZ OFF)
	set(CPACK_BINARY_TZ OFF)
	set(CPACK_PACKAGE_NAME "${APPLICATION_NAME}")
	set(CPACK_PACKAGE_VENDOR "${APPLICATION_VENDOR}")
	set(CPACK_PACKAGE_VERSION_MAJOR ${LINPHONE_MAJOR_VERSION})
	set(CPACK_PACKAGE_VERSION_MINOR ${LINPHONE_MINOR_VERSION})
	if (LINPHONE_MICRO_VERSION)
		set(CPACK_PACKAGE_VERSION_PATCH ${LINPHONE_MICRO_VERSION})
	endif ()
	set(CPACK_PACKAGE_EXECUTABLES "${EXECUTABLE_NAME};${APPLICATION_NAME}")

	if(ENABLE_APP_LICENSE)
		set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")
	else()
		unset(CPACK_RESOURCE_FILE_LICENSE)
	endif()
	set(CPACK_RESOURCE_FILE_LICENSE_PROVIDED ${ENABLE_APP_LICENSE})
	set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icon.ico")
	set(PERFORM_SIGNING 0)
##############################################
#	LINUX
##############################################
	set(DO_APPIMAGE YES)
	set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}")
	set(PACKAGE_EXT "AppImage")
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/linux/linphone.desktop.cmake" "${CMAKE_BINARY_DIR}/cmake/install/linux/${EXECUTABLE_NAME}.desktop" @ONLY)
	install(FILES "${CMAKE_BINARY_DIR}/cmake/install/linux/${EXECUTABLE_NAME}.desktop" DESTINATION "${CMAKE_INSTALL_DATADIR}/applications" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
	install(FILES "${CMAKE_SOURCE_DIR}/Linphone/data/image/logo.svg" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/apps/" RENAME "${EXECUTABLE_NAME}.svg")
	set(ICON_DIRS 16x16 22x22 24x24 32x32 64x64 128x128 256x256)
	foreach (DIR ${ICON_DIRS})
		install(FILES "${CMAKE_SOURCE_DIR}/Linphone/data/icon/hicolor/${DIR}/apps/icon.png" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/${DIR}/apps/" RENAME "${EXECUTABLE_NAME}.png")
	endforeach ()
	message(STATUS "Set AppImage CPack generator in OUTPUT/Packages")
##############################################
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/packaging.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake")
	include(CPack)
endif()

