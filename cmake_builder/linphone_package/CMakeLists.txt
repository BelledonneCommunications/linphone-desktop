############################################################################
# CMakeLists.txt
# Copyright (C) 2017-2018  Belledonne Communications, Grenoble France
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

cmake_minimum_required(VERSION 3.1)
project(LINPHONE_PACKAGE) # Dummy project.

include("${LINPHONE_DESKTOP_DIR}/application_info.cmake")

find_package(Linphone REQUIRED)
find_package(Git)
#Policy set to allow link from other directory (cmake 3.13)
if (POLICY CMP0079)
  cmake_policy(SET CMP0079 NEW)
endif ()

set(LINPHONE_QML_DIR "${LINPHONE_DESKTOP_DIR}/ui")

# ==============================================================================
# Build package version.
# ==============================================================================

if (GIT_EXECUTABLE)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always
    OUTPUT_VARIABLE LINPHONE_GIT_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY ${LINPHONE_DESKTOP_DIR}
  )
else ()
  set(LINPHONE_GIT_REVISION "0.0.0")
endif ()
string(REGEX REPLACE "([0-9.]+)-?.*" "\\1" LINPHONE_VERSION "${LINPHONE_GIT_REVISION}")
string(REPLACE "." ";" SPLITTED_LINPHONE_VERSION "${LINPHONE_VERSION}")
list(LENGTH SPLITTED_LINPHONE_VERSION SPLITTED_LINPHONE_VERSION_LENGTH)
list(GET SPLITTED_LINPHONE_VERSION 0 LINPHONE_MAJOR_VERSION)
list(GET SPLITTED_LINPHONE_VERSION 1 LINPHONE_MINOR_VERSION)
if (SPLITTED_LINPHONE_VERSION_LENGTH GREATER 2)
  list(GET SPLITTED_LINPHONE_VERSION 2 LINPHONE_MICRO_VERSION)
endif ()
set(PACKAGE_VERSION "${LINPHONE_VERSION}")

# ==============================================================================
# Preparing the Linphone SDK bundle.
# ==============================================================================

message(" Linphone_SDK_DIR : ${LINPHONE_SDK_DIR}")

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
#      COMMAND ${7Z_PROGRAM} a -tzip ${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${LINPHONE_GIT_REVISION}-win32.zip "@${EXECUTABLE_NAME}-sdk.list"
#      WORKING_DIRECTORY ${LINPHONE_OUTPUT_DIR}
#    )
#  else ()
#    message(WARNING "7z has not been found, cannot generate the SDK!")
#  endif ()
#elseif (APPLE)
#  execute_process(
#    COMMAND rm -rf "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${LINPHONE_GIT_REVISION}-mac.zip"
#    COMMAND zip -ry "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}-sdk-${LINPHONE_GIT_REVISION}-mac.zip" . -i "@${EXECUTABLE_NAME}-sdk.list"
#    WORKING_DIRECTORY ${LINPHONE_OUTPUT_DIR}
#  )
#endif ()

# ==============================================================================
# Specific deployment.
# ==============================================================================

if (WIN32)
  find_program(DEPLOYQT_PROGRAM windeployqt)
  if (NOT DEPLOYQT_PROGRAM)
    message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
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
  install(FILES "${MINIZIP_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}/minizip.dll" DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT application)
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS OPTIONAL)
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/sounds" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS)
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}/")
  #get_target_property(DIRR ${TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
	
  install(PROGRAMS "${EXECUTABLE_OUTPUT_DIR}/${EXECUTABLE_NAME}.exe" DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT application)
  install( CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${EXECUTABLE_NAME}.exe --qmldir=${LINPHONE_QML_DIR})")# -verbose=2)" COMPONENT application)	
#  list(REMOVE_ITEM SHARE_CONTENT "${CMAKE_INSTALL_DATAROOTDIR}/belr" "${CMAKE_INSTALL_DATAROOTDIR}/Belr" "${CMAKE_INSTALL_DATAROOTDIR}/images" "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}" "${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}" "${CMAKE_INSTALL_DATAROOTDIR}/sounds")
#  foreach (ITEM IN LISTS SHARE_CONTENT)
#    list(APPEND SHARE_CONTENT_EXCLUDE PATTERN "${ITEM}" EXCLUDE)
#  endforeach ()
elseif (APPLE)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/Info.plist.in" "${CMAKE_BINARY_DIR}/Info.plist" @ONLY)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/linphone.icns" "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}.icns" COPYONLY)
  install(FILES "${CMAKE_BINARY_DIR}/Info.plist" DESTINATION "${APPLICATION_NAME}.app/Contents")
  install(FILES "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}.icns" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources")
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/Frameworks/" DESTINATION "${APPLICATION_NAME}.app/Contents/Frameworks" USE_SOURCE_PERMISSIONS COMPONENT application)
  install(PROGRAMS "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}" DESTINATION "${APPLICATION_NAME}.app/Contents/MacOS" COMPONENT application)
  file(GLOB SHARED_LIBRARIES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/lib*.dylib")
  foreach (LIBRARY ${SHARED_LIBRARIES})
    install(FILES "${LIBRARY}" DESTINATION "${APPLICATION_NAME}.app/Contents/Frameworks" COMPONENT application)
  endforeach ()

  find_program(DEPLOYQT_PROGRAM macdeployqt)
  if (NOT DEPLOYQT_PROGRAM)
    message(FATAL_ERROR "Could not find the macdeployqt program. Make sure it is in the PATH.")
  endif ()


  if (EXISTS "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer")
    file(COPY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_LIBDIR}" USE_SOURCE_PERMISSIONS)
  endif ()
  install(FILES "${MINIZIP_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/libminizip.dylib" DESTINATION "${APPLICATION_NAME}.app/Contents/Frameworks/" COMPONENT application)
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Belr/grammars/cpim_grammar" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/" COMPONENT application)
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Belr/grammars/vcard_grammar" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/" COMPONENT application)
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/images" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS COMPONENT application OPTIONAL)
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/sounds" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS COMPONENT application)
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/Linphone/rootca.pem" DESTINATION "${APPLICATION_NAME}.app/Contents/Resources/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}" COMPONENT application)

  file(GLOB SHARED_LIBRARIES "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app/Contents/Frameworks/lib*.dylib")

  foreach (LIBRARY ${SHARED_LIBRARIES})
    get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
    if(NOT ("${LIBRARY_FILENAME}" STREQUAL "libminizip.dylib"))
      message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '@executable_path/../Frameworks'")
      execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "@executable_path/../Frameworks" "${LIBRARY}")
    endif()
  endforeach ()

  install( CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../Frameworks/\" \"${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/MacOS/${EXECUTABLE_NAME}\")")
  install( CODE "execute_process(COMMAND install_name_tool -add_rpath \"@executable_path/../lib/\" \"${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app/Contents/MacOS/${EXECUTABLE_NAME}\")")

  install( CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} \${CMAKE_INSTALL_PREFIX}/${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR})")# -verbose=2)"  COMPONENT binary_application)

  if (LINPHONE_BUILDER_SIGNING_IDENTITY)
    file(GLOB FRAMEWORKS_NAMES "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app/Contents/Frameworks/*")
    foreach (FRAMEWORK ${FRAMEWORKS_NAMES})
      execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${FRAMEWORK}")
    endforeach ()
    file(GLOB PLUGINS_NAMES "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app/Contents/PlugIns/*")
    foreach (PLUGIN ${PLUGINS_NAMES})
      file(GLOB PLUGINS_FILES "${PLUGIN}/*")
      foreach (PLUGIN_FILE ${PLUGINS_FILES})
        execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${PLUGIN_FILE}")
      endforeach ()
    endforeach ()
    execute_process(COMMAND "codesign" "--verbose" "-s" "${LINPHONE_BUILDER_SIGNING_IDENTITY}" "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app")
  endif ()
#  install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${APPLICATION_NAME}.app" DESTINATION "." USE_SOURCE_PERMISSIONS COMPONENT application)

  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/packaging.cmake.in" "packaging.cmake" @ONLY)
#  install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/packaging.cmake")
else()# Not Windows and Apple
    foreach (LIBRARY ${SHARED_LIBRARIES})
    get_filename_component(LIBRARY_FILENAME ${LIBRARY} NAME)
      message("Changing RPATH of ${LIBRARY_FILENAME} from '${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}' to '$ORIGIN/../${CMAKE_INSTALL_LIBDIR}'")
      execute_process(COMMAND install_name_tool -rpath "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}" "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}" "${LIBRARY}")
    endforeach ()  
    message(${CMAKE_INSTALL_PREFIX})
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_BINDIR}/" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}" USE_SOURCE_PERMISSIONS)
#Just in case. This is useless because we have to use CMAKE_INSTALL_LIBDIR  
  if( EXISTS "${LINPHONE_OUTPUT_DIR}/lib/")
    install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/lib/" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" USE_SOURCE_PERMISSIONS)
  endif()
  if( EXISTS "${LINPHONE_OUTPUT_DIR}/lib64/")
	install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/lib64/" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib64" USE_SOURCE_PERMISSIONS)
  endif()
  install(DIRECTORY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}" USE_SOURCE_PERMISSIONS)

  if (EXISTS "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer")
    file(COPY "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_LIBDIR}/mediastreamer" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}" USE_SOURCE_PERMISSIONS)
  endif ()
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/cpim_grammar" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/")
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/vcard_grammar" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/belr/grammars/")
  install(FILES "${LINPHONE_OUTPUT_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/${APPLICATION_NAME}")	#We use executable_name because of name folder that is not harmonized from the SDK
  install(PROGRAMS "${CMAKE_BINARY_DIR}/${EXECUTABLE_NAME}" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}" COMPONENT application)
endif ()

# Temporary deactivate
#if (MSVC)
#  string(REGEX REPLACE "Visual Studio ([0-9]+).*" "\\1" MSVC_VERSION "${CMAKE_GENERATOR}")
#  find_file(MSVCP_LIB "msvcp${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
#  find_file(UCRTBASE_LIB "ucrtbase.dll" PATHS "C:/Windows/System32")
#  # Starting with Visual Studio 2015 (MSVC_VERSION==14) the msvcr dll has been renamed to vcruntime.
#  find_file(VCRUNTIME_LIB "vcruntime${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
#  if (NOT VCRUNTIME_LIB)
#    find_file(VCRUNTIME_LIB "msvcr${MSVC_VERSION}0.dll" PATHS "C:/Windows/System32")
#  endif ()
#  install(FILES ${MSVCP_LIB} ${UCRTBASE_LIB} ${VCRUNTIME_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")
#  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
#    find_file(MSVCPD_LIB "msvcp${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
#    find_file(UCRTBASED_LIB "ucrtbased.dll" PATHS "C:/Windows/System32")
#    find_file(VCRUNTIMED_LIB "vcruntime${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
#    if (NOT VCRUNTIMED_LIB)
#      find_file(VCRUNTIMED_LIB "msvcr${MSVC_VERSION}0d.dll" PATHS "C:/Windows/System32")
#    endif ()
#    install(FILES ${MSVCPD_LIB} ${UCRTBASED_LIB} ${VCRUNTIMED_LIB} DESTINATION "${CMAKE_INSTALL_BINDIR}")
#  endif ()
#endif ()

# ==============================================================================
#                               CPack.
# ==============================================================================

set(CPACK_BINARY_STGZ OFF)
set(CPACK_BINARY_TGZ OFF)
set(CPACK_PACKAGE_NAME "${APPLICATION_NAME}")
set(CPACK_PACKAGE_VENDOR "${APPLICATION_VENDOR}")
set(CPACK_PACKAGE_VERSION_MAJOR ${LINPHONE_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${LINPHONE_MINOR_VERSION})
if (LINPHONE_MICRO_VERSION)
  set(CPACK_PACKAGE_VERSION_PATCH ${LINPHONE_MICRO_VERSION})
endif ()
set(CPACK_PACKAGE_EXECUTABLES "${EXECUTABLE_NAME};${APPLICATION_NAME}")
set(CPACK_RESOURCE_FILE_LICENSE "${LINPHONE_DESKTOP_DIR}/LICENSE.txt")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${APPLICATION_NAME}")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/CPackBuild")
set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/assets/icon.ico")


if (APPLE)
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${LINPHONE_GIT_REVISION}-mac")
  set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_CURRENT_SOURCE_DIR}/macos/background_dmg.jpg")

  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/macos/linphone_dmg.scpt.in" "${CMAKE_BINARY_DIR}/linphone_dmg.scpt" @ONLY)
#  set(CPACK_INSTALL_COMMANDS "install( CODE "execute_process(COMMAND ${DEPLOYQT_PROGRAM} ${APPLICATION_NAME}.app -qmldir=${LINPHONE_QML_DIR})")# -verbose=2)"  COMPONENT binary_application)")
  
  set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/linphone_dmg.scpt")
  set(CPACK_BINARY_DRAGNDROP ON)
else()
endif ()

if (WIN32)
  set(CPACK_GENERATOR "NSIS")
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${LINPHONE_GIT_REVISION}-win32")

  string(COMPARE EQUAL ${CPACK_GENERATOR} "NSIS" IS_NSIS)
  if (${IS_NSIS})
    set(PACKAGE_EXT "exe")

    # Use magic `NSIS.template.in` template from the current source directory to force uninstallation
    # and ensure that linphone is not running before installation.
    set(CPACK_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/windows")
    set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\windows\\\\nsis_banner.bmp")

    set(CPACK_NSIS_MUI_ICON "${LINPHONE_DESKTOP_DIR}/assets/icon.ico")
    set(CPACK_NSIS_MUI_UNIICON "${LINPHONE_DESKTOP_DIR}/assets/icon.ico")
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
  else ()
    set(PACKAGE_EXT "msi")

    set(CPACK_WIX_UPGRADE_GUID "C748668E-53D0-4088-A548-E33A76615A3B")
    set(CPACK_WIX_PRODUCT_ICON "${LINPHONE_DESKTOP_DIR}/assets/icon.ico")
    set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "${APPLICATION_URL}")

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
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/windows/packaging.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/packaging.cmake" @ONLY)
 # install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/packaging.cmake")
endif ()
include(CPack)
