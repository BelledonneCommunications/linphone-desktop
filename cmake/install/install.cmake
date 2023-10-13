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
endif()

if (NOT(LINPHONEAPP_VERSION))
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

set(LINPHONE_QML_DIR "${CMAKE_SOURCE_DIR}/Linphone/view")
set(QT_PATH "${Qt6Core_DIR}/../../..")

if(APPLE)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/Info.plist.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/Info.plist" @ONLY)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/entitlements.xml.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/entitlements.xml" @ONLY)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/linphone.icns" "${CMAKE_BINARY_DIR}/cmake/install/macos/${EXECUTABLE_NAME}.icns" COPYONLY)
	set(APP_QT_CONF_PATH "[Paths]\nPlugins = PlugIns\nImports = Resources/qml\nQml2Imports = Resources/qml")

	#configure_file("${CMAKE_SOURCE_DIR}/Linphone/../assets/qt.conf.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/qt.conf" @ONLY)
	#install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/qt.conf" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/..")
	install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/Info.plist" DESTINATION "${APPLICATION_NAME}.app/Contents")
	install(FILES "${CMAKE_BINARY_DIR}/cmake/install/macos/${EXECUTABLE_NAME}.icns" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/..")
	file(GLOB SHARED_LIBRARIES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/lib*.dylib")
	if( ENABLE_OPENH264 )# Remove openH264 lib from the installation. this codec will be download by user
		foreach(item ${SHARED_LIBRARIES})
			get_filename_component(LIBRARY_FILENAME ${item} NAME)
			if("${LIBRARY_FILENAME}" MATCHES "^libopenh264.*.dylib$")
				list(REMOVE_ITEM SHARED_LIBRARIES ${item})
			endif()
		endforeach(item)
	endif()
	install(FILES ${SHARED_LIBRARIES} DESTINATION "${CMAKE_INSTALL_LIBDIR}")
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS OPTIONAL)
	#install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/linphonerc-factory" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}")

	file(GLOB SHARED_LIBRARIES "${CMAKE_BINARY_DIR}/cmake/install/macos/${APPLICATION_NAME}.app/Contents/Frameworks/lib*.dylib")

	foreach (LIBRARY ${SHARED_LIBRARIES})
		get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
		message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '@executable_path/../Frameworks'")
		execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "@executable_path/../Frameworks" "${LIBRARY}")
	endforeach ()
	install(TARGETS ${APP_PLUGIN}
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
	)
	install(CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../Frameworks/\" \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}\")")
	install(CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../lib/\" \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}\")")
	get_filename_component(_qt_bin_dir "${qmake_executable}" DIRECTORY)
	find_program(DEPLOYQT_PROGRAM macdeployqt HINTS "${_qt_bin_dir}")
	if (NOT DEPLOYQT_PROGRAM)
		message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
	endif()
	install(CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} ${APPLICATION_OUTPUT_DIR}/${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR} -no-strip )")
endif()

# ==============================================================================
#                               CPack.
# ==============================================================================


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
	set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/Linphone/data/icon.ico")
	set(PERFORM_SIGNING 0)

	if(APPLE)
##############################################
#	APPLE
##############################################
		set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-mac")
		set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/cmake/install/macos/background_dmg.jpg")
		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/linphone_dmg.scpt.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/linphone_dmg.scpt" @ONLY)
		set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/macos/linphone_dmg.scpt")
		set(CPACK_BINARY_DRAGNDROP ON)
		set(CPACK_BUNDLE_APPLE_CERT_APP ${LINPHONE_BUILDER_SIGNING_IDENTITY})
		set(PACKAGE_EXT "dmg")

		configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/cleanCpack.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/cleanCpack.cmake" @ONLY)
		set(CPACK_PRE_BUILD_SCRIPTS  "${CMAKE_BINARY_DIR}/cmake/install/macos/cleanCPack.cmake")

		message(STATUS "Set DragNDrop CPack generator in OUTPUT/Packages")
	else()
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
	endif()
##############################################
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/packaging.cmake.in" "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_BINARY_DIR}/cmake/install/packaging.cmake")
	include(CPack)
endif()

