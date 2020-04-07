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
project(LINPHONE_PACKAGE) # Dummy project.
if(ENABLE_BUILD_VERBOSE)
	message("Linphone-packages paths : ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}")
endif()
include("${CMAKE_CURRENT_SOURCE_DIR}/../../application_info.cmake")

find_package(Git)
#Policy set to allow link from other directory (cmake 3.13)
if (POLICY CMP0079)
  cmake_policy(SET CMP0079 NEW)
endif ()

set(LINPHONE_QML_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../ui")

# ==============================================================================
# Build package version.
# ==============================================================================

if (GIT_EXECUTABLE AND NOT(APP_PROJECT_VERSION))
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always
    OUTPUT_VARIABLE APP_PROJECT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../.."
  )
elseif (NOT(APP_PROJECT_VERSION))
  set(APP_PROJECT_VERSION "0.0.0")
endif ()
string(REGEX REPLACE "([0-9.]+)-?.*" "\\1" LINPHONE_VERSION "${APP_PROJECT_VERSION}")
string(REPLACE "." ";" SPLITTED_LINPHONE_VERSION "${LINPHONE_VERSION}")
list(LENGTH SPLITTED_LINPHONE_VERSION SPLITTED_LINPHONE_VERSION_LENGTH)
list(GET SPLITTED_LINPHONE_VERSION 0 LINPHONE_MAJOR_VERSION)
list(GET SPLITTED_LINPHONE_VERSION 1 LINPHONE_MINOR_VERSION)
if (SPLITTED_LINPHONE_VERSION_LENGTH GREATER 2)
  list(GET SPLITTED_LINPHONE_VERSION 2 LINPHONE_MICRO_VERSION)
endif ()
set(PACKAGE_VERSION "${APP_PROJECT_VERSION}")
message(STATUS "Versions : ${APP_PROJECT_VERSION}, ${LINPHONE_VERSION}")
# ==============================================================================
# Preparing the Linphone SDK bundle.
# ==============================================================================

if (WIN32)
  set(LIBDIR ${CMAKE_INSTALL_BINDIR})
  set(LIBPREFIX "")
  set(LIBEXT "dll")
  set(PLUGINEXT "dll")
elseif (APPLE)
  set(LIBDIR ${CMAKE_INSTALL_LIBDIR})
  set(LIBPREFIX "lib")
  set(LIBEXT "dylib")
  set(PLUGINEXT "so")
endif ()

# Removed unless it is usefull to get a zip from SDK : The SDK is packaged with binaries.
#if (WIN32)
#  find_program(7Z_PROGRAM 7z PATHS "$ENV{ProgramFiles}/7-Zip")
#  if (7Z_PROGRAM)
#    execute_process(
#      COMMAND ${7Z_PROGRAM} a -tzip ${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${APP_PROJECT_VERSION}-win32.zip "@${EXECUTABLE_NAME}-sdk.list"
#      WORKING_DIRECTORY ${LINPHONE_OUTPUT_DIR}
#    )
#  else ()
#    message(WARNING "7z has not been found, cannot generate the SDK!")
#  endif ()
#elseif (APPLE)
#  execute_process(
#    COMMAND rm -rf "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${APP_PROJECT_VERSION}-mac.zip"
#    COMMAND zip -ry "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${APP_PROJECT_VERSION}-mac.zip" . -i "@${EXECUTABLE_NAME}-sdk.list"
#    WORKING_DIRECTORY ${LINPHONE_OUTPUT_DIR}
#  )
#endif ()

# ==============================================================================
# Specific deployment.
# ==============================================================================

if (WIN32)
	find_program(DEPLOYQT_PROGRAM windeployqt)
	if (NOT DEPLOYQT_PROGRAM)
		message(FATAL_ERROR "Could not find the windeployqt program. Make sure it is in the PATH.")
	endif ()
	file(GLOB LIB_FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/*.dll")
	install(FILES ${LIB_FILES} DESTINATION "${CMAKE_INSTALL_BINDIR}/")
	file(GLOB LIB_FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}/*.dll")
	install(FILES ${LIB_FILES} DESTINATION "${CMAKE_INSTALL_BINDIR}/")
	file(GLOB EXE_FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}/*.exe")
	install(FILES ${EXE_FILES} DESTINATION "${CMAKE_INSTALL_BINDIR}/")
	if (EXISTS "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer")
		install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer" DESTINATION "${CMAKE_INSTALL_LIBDIR}" USE_SOURCE_PERMISSIONS)
	endif ()
	file(GLOB GRAMMAR_FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Belr/grammars/*")
	install(FILES ${GRAMMAR_FILES} DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/" )
	install(FILES "${MINIZIP_PREFIX}/${CMAKE_INSTALL_BINDIR}/minizip.dll" DESTINATION "${CMAKE_INSTALL_BINDIR}")
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS OPTIONAL)
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/sounds" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS)
	install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}/")
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/linphonerc-factory" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}")
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/use-other-sip-account.rc" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/create-app-sip-account.rc" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/use-app-sip-account.rc" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")
	#get_target_property(DIRR linphone-qt RUNTIME_OUTPUT_DIRECTORY)	#No need that, the binary should be in ${CMAKE_CURRENT_BINARY_DIR}/../..
	#message("DIR : ${DIRR}")
	install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}.exe" DESTINATION "${CMAKE_INSTALL_BINDIR}")
	install( CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}.exe\" -qmldir=${LINPHONE_QML_DIR} --compiler-runtime)")# -verbose=2)"  COMPONENT binary_application)

#  list(REMOVE_ITEM SHARE_CONTENT "${CMAKE_INSTALL_DATAROOTDIR}/belr" "${CMAKE_INSTALL_DATAROOTDIR}/Belr" "${CMAKE_INSTALL_DATAROOTDIR}/images" "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}" "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}" "${CMAKE_INSTALL_DATAROOTDIR}/sounds")
#  foreach (ITEM IN LISTS SHARE_CONTENT)
#    list(APPEND SHARE_CONTENT_EXCLUDE PATTERN "${ITEM}" EXCLUDE)
#  endforeach ()
elseif (APPLE)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/Info.plist.in" "${CMAKE_CURRENT_BINARY_DIR}/../../Info.plist" @ONLY)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/linphone.icns" "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}.icns" COPYONLY)
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/../../Info.plist" DESTINATION "${APPLICATION_NAME}.app/Contents")
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}.icns" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources")
  install( CODE "execute_process(COMMAND rsync -a \"${LINPHONE_OUTPUT_DIR}/Frameworks\"  \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/\" )") #Use rsync to bypass symlinks override issues of frameworks
  install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}" DESTINATION "${APPLICATION_NAME}.app/Contents/MacOS")
  file(GLOB SHARED_LIBRARIES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/lib*.dylib")
  foreach (LIBRARY ${SHARED_LIBRARIES})
    install(FILES "${LIBRARY}" DESTINATION "${APPLICATION_NAME}.app/Contents/Frameworks")
  endforeach ()
  if (EXISTS "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer")
    file(COPY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_LIBDIR}" USE_SOURCE_PERMISSIONS)
  endif ()
  if(ENABLE_BUILD_VERBOSE)
    message("Take Minizip from ${MINIZIP_PREFIX}/${CMAKE_INSTALL_LIBDIR}/libminizip.dylib")
  endif()
  file(GLOB GRAMMAR_FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Belr/grammars/*")
  install(FILES ${GRAMMAR_FILES} DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/")
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS OPTIONAL)
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/sounds" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS)
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Linphone/rootca.pem" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/linphonerc-factory" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/use-other-sip-account.rc" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/create-app-sip-account.rc" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/assistant/use-app-sip-account.rc" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}/assistant")

  file(GLOB SHARED_LIBRARIES "${CMAKE_CURRENT_BINARY_DIR}/../../${APPLICATION_NAME}.app/Contents/Frameworks/lib*.dylib")

  foreach (LIBRARY ${SHARED_LIBRARIES})
    get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
    if(NOT ("${LIBRARY_FILENAME}" STREQUAL "libminizip.dylib"))
      message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '@executable_path/../Frameworks'")
      execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "@executable_path/../Frameworks" "${LIBRARY}")
    endif()
  endforeach ()
  install(FILES "${MINIZIP_PREFIX}/${CMAKE_INSTALL_LIBDIR}/libminizip.dylib" DESTINATION "${APPLICATION_NAME}.app/Contents/Frameworks/")
  install( CODE "execute_process(COMMAND install_name_tool -id \"@executable_path/../Frameworks/libminizip.dylib\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/Frameworks/libminizip.dylib\")")
  install( CODE "execute_process(COMMAND install_name_tool -change libminizip.dylib \"@executable_path/../Frameworks/libminizip.dylib\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/MacOS/${EXECUTABLE_NAME}\")")
  install( CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../Frameworks/\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/MacOS/${EXECUTABLE_NAME}\")")
  install( CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../lib/\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/MacOS/${EXECUTABLE_NAME}\")")
  if(ENABLE_APP_PACKAGING)
    find_program(DEPLOYQT_PROGRAM macdeployqt)
    if (NOT DEPLOYQT_PROGRAM)
        message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
    endif()
    install( CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} \${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR})")
  endif()
  if (LINPHONE_BUILDER_SIGNING_IDENTITY)
   install(CODE "file(GLOB FRAMEWORKS_NAMES \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/Frameworks/*\")
      foreach (FRAMEWORK \${FRAMEWORKS_NAMES})
        execute_process(COMMAND \"codesign\" \"--options\" \"runtime,library\" \"--force\" \"--deep\" \"--verbose\" \"-s\" \"${LINPHONE_BUILDER_SIGNING_IDENTITY}\" \"\${FRAMEWORK}\")
      endforeach ()")
    install( CODE "execute_process(COMMAND \"codesign\" \"--force\" \"--deep\" \"--options\" \"runtime,library\" \"--verbose\" \"-s\" \"${LINPHONE_BUILDER_SIGNING_IDENTITY}\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/Frameworks/mediastreamer2.framework/Versions/A/Libraries/libmswebrtc.so\")")
    install( CODE "execute_process(COMMAND \"codesign\" \"--force\" \"--deep\" \"--options\" \"runtime,library\" \"--verbose\" \"-s\" \"${LINPHONE_BUILDER_SIGNING_IDENTITY}\" \"\${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app\")")
  endif ()
#  install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app" DESTINATION "." USE_SOURCE_PERMISSIONS)

else()# Not Windows and Apple
    foreach (LIBRARY ${SHARED_LIBRARIES})
    get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
      message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '$ORIGIN/../${CMAKE_INSTALL_LIBDIR}'")
      execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "$ORIGIN/../lib" "${LIBRARY}")
      execute_process(COMMAND install_name_tool -addrpath "$ORIGIN/../lib64" "${LIBRARY}")
    endforeach ()
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}/" DESTINATION "${CMAKE_INSTALL_BINDIR}" USE_SOURCE_PERMISSIONS)
  
#Just in case. This is useless because we have to use CMAKE_INSTALL_LIBDIR  
  if( EXISTS "${LINPHONE_OUTPUT_DIR}/lib/")
    install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/lib/" DESTINATION "lib" USE_SOURCE_PERMISSIONS)
  endif()
  if( EXISTS "${LINPHONE_OUTPUT_DIR}/lib64/")
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/lib64/" DESTINATION "lib64" USE_SOURCE_PERMISSIONS)
  endif()
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS)
  if(ENABLE_BUILD_VERBOSE)
    message("INSTALLATION : ${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/" )
  endif()
  if (EXISTS "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer")
    file(COPY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer" DESTINATION "${CMAKE_INSTALL_LIBDIR}" USE_SOURCE_PERMISSIONS)
  endif ()
    # Install desktop/icon files.
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/../../assets/linphone.desktop.cmake" "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}.desktop" @ONLY)

  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}.desktop" DESTINATION "${CMAKE_INSTALL_DATADIR}/applications")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/images/linphone_logo.svg" DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps/" RENAME "${EXECUTABLE_NAME}.svg")

  set(ICON_DIRS 16x16 22x22 24x24 32x32 64x64 128x128 256x256)
  foreach (DIR ${ICON_DIRS})
	install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icons/hicolor/${DIR}/apps/icon.png" DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/${DIR}/apps/" RENAME "${EXECUTABLE_NAME}.png")
  endforeach ()

  install(FILES "${MINIZIP_PREFIX}/${CMAKE_INSTALL_LIBDIR}/libminizip.so" DESTINATION "${CMAKE_INSTALL_LIBDIR}")
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/cpim_grammar" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/")
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/vcard_grammar" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/")
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}")	#We use executable_name because of name folder that is not harmonized from the SDK
  install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../../${EXECUTABLE_NAME}" DESTINATION "${CMAKE_INSTALL_BINDIR}")  
endif ()

if (MSVC)
#  string(REGEX REPLACE "Visual Studio ([0-9]+).*" "\\1" MSVC_VERSION "${CMAKE_GENERATOR}")
  include(InstallRequiredSystemLibraries)
  set(MSVC_VERSION ${MSVC_TOOLSET_VERSION})
  set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(CMAKE_INSTALL_DEBUG_LIBRARIES TRUE)
  endif()
  find_file(UCRTBASE_LIB "ucrtbase.dll" PATHS "C:/Windows/System32")
  install(FILES ${UCRTBASE_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")
  
  # find_file(MSVCP_LIB "msvcp${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
  
  # # Starting with Visual Studio 2015 (MSVC_VERSION==14) the msvcr dll has been renamed to vcruntime.
  # find_file(VCRUNTIME_LIB "vcruntime${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
  # if (NOT VCRUNTIME_LIB)
    # find_file(VCRUNTIME_LIB "msvcr${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
  # endif ()
  # message("MSDIRS : ${MSVCP_LIB} ${UCRTBASE_LIB} ${VCRUNTIME_LIB} => ${MSVC_VERSION}, ${CMAKE_GENERATOR}")
  # install(FILES ${MSVCP_LIB} ${UCRTBASE_LIB} ${VCRUNTIME_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")
  # if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    # find_file(MSVCPD_LIB "msvcp${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
    # find_file(UCRTBASED_LIB "ucrtbased.dll" PATHS "C:/Windows/System32")
    # find_file(VCRUNTIMED_LIB "vcruntime${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
    # if (NOT VCRUNTIMED_LIB)
      # find_file(VCRUNTIMED_LIB "msvcr${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
    # endif ()
    
    # install(FILES ${MSVCPD_LIB} ${UCRTBASED_LIB} ${VCRUNTIMED_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")
  # endif ()
endif ()

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
	set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/../../../LICENSE.txt")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${APPLICATION_NAME}")
	set(CPACK_PACKAGE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/Packages")
	set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icon.ico")
	
	if (APPLE)
	  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-mac")
	  set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_CURRENT_SOURCE_DIR}/macos/background_dmg.jpg")
	  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/linphone_dmg.scpt.in" "${CMAKE_CURRENT_BINARY_DIR}/linphone_dmg.scpt" @ONLY)
	  set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/linphone_dmg.scpt")
	  set(CPACK_BINARY_DRAGNDROP ON)
	  message(STATUS "Set DragNDrop CPack generator in OUTPUT/Packages")
	elseif(NOT(WIN32))
	  set(DO_APPIMAGE YES)
	  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}")
	  message(STATUS "Set AppImage CPack generator in OUTPUT/Packages")
	else()
	  set(CPACK_GENERATOR "NSIS")
	  set(DO_GENERATOR YES)
	  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PACKAGE_VERSION}-win32")
	  string(COMPARE EQUAL ${CPACK_GENERATOR} "NSIS" IS_NSIS)
	  if (${IS_NSIS})
	    set(PACKAGE_EXT "exe")
	    # Use magic `NSIS.template.in` template from the current source directory to force uninstallation
	    # and ensure that linphone is not running before installation.
	    set(CPACK_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/windows")
	    set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\windows\\\\nsis_banner.bmp")
	    set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icon.ico")
	    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icon.ico")
	    set(CPACK_NSIS_DISPLAY_NAME "${APPLICATION_NAME}")
	    if (LINPHONE_MICRO_VERSION)
	      set(CPACK_NSIS_PACKAGE_NAME "${APPLICATION_NAME} ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION}")
	    else ()
	      set(CPACK_NSIS_PACKAGE_NAME "${APPLICATION_NAME} ${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}")
	    endif ()
	    set(CPACK_NSIS_URL_INFO_ABOUT ${APPLICATION_URL})
	
	    file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}" DOS_STYLE_BINARY_DIR)
	    string(REPLACE "\\" "\\\\" ESCAPED_DOS_STYLE_BINARY_DIR "${DOS_STYLE_BINARY_DIR}")
	    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/windows/install.nsi.in" "${CMAKE_CURRENT_BINARY_DIR}/install.nsi" @ONLY)
	    set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\install.nsi\\\"")
	    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/windows/uninstall.nsi.in" "${CMAKE_CURRENT_BINARY_DIR}/uninstall.nsi" COPYONLY)
	    set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "!include \\\"${ESCAPED_DOS_STYLE_BINARY_DIR}\\\\uninstall.nsi\\\"")
	    set(CPACK_NSIS_EXECUTABLES_DIRECTORY "bin")
	    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${EXECUTABLE_NAME}.exe")
	    message(STATUS "Set NSIS CPack generator in OUTPUT/Packages")
	  else ()
	    set(PACKAGE_EXT "msi")
	
	    set(CPACK_WIX_UPGRADE_GUID "C748668E-53D0-4088-A548-E33A76615A3B")
	    set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/icon.ico")
	    set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "${APPLICATION_URL}")
		message(STATUS "Set MSI CPack generator in OUTPUT/Packages")
	    # TODO: Deal with install/uninstall.nsi
	  endif ()
	
	  # Sign the installer.
	  set(TIMESTAMP_URL "http://timestamp.verisign.com/scripts/timestamp.dll")
	  set(PFX_FILE "${CMAKE_CURRENT_SOURCE_DIR}/sign/linphone.pfx")
	  set(PASSPHRASE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt")
	  get_filename_component(WINSDK_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH CACHE)
	  find_package(PythonInterp)
	  find_program(SIGNTOOL signtool PATHS ${WINSDK_DIR}/${CMAKE_INSTALL_BINDIR})
	  set(SIGNTOOL_COMMAND "${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/windows/signtool.py")
	  set(PERFORM_SIGNING 0)
	  if (EXISTS ${PFX_FILE})
	    if (SIGNTOOL)
	      set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} signtool sign /f ${PFX_FILE}")
	      set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} /p ${PASSPHRASE_FILE}")
	      set(SIGNTOOL_COMMAND "${SIGNTOOL_COMMAND} /t ${TIMESTAMP_URL}")
	      message("Found signtool and certificate ${PFX_FILE}")
	      set(PERFORM_SIGNING 1)
	    else ()
	      message(STATUS "Could not find signtool! Code signing disabled (${SIGNTOOL})")
	    endif ()
	  else ()
	    message(STATUS "No signtool certificate found; assuming development machine (${PFX_FILE})")
	  endif ()
	endif ()
	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/packaging.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/packaging.cmake" @ONLY)
	install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/packaging.cmake")
	include(CPack)
endif()
