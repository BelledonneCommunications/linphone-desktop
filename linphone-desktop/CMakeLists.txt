################################################################################
# CMakeLists.txt
# Copyright (C) 2017  Belledonne Communications, Grenoble France
#
################################################################################
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
################################################################################

cmake_minimum_required(VERSION 3.1)
project(linphoneqt)

set(EXECUTABLE_NAME linphone)
set(TARGET_NAME linphone-qt)
set(CMAKE_CXX_STANDARD 11)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

if(NOT WIN32)
  check_cxx_compiler_flag("-Wsuggest-override" SUGGEST_OVERRIDE)
  set(CUSTOM_FLAGS "\
-Wall \
-Wcast-align \
-Wconversion \
-Wextra \
-Wfloat-equal \
-Winit-self \
-Winline \
-Wlogical-op \
-Wold-style-cast \
-Woverloaded-virtual \
-Wpointer-arith \
-Wuninitialized \
-Wunused \
")
  if(SUGGEST_OVERRIDE)
    set(CUSTOM_FLAGS "${CUSTOM_FLAGS} -Wsuggest-override -Werror=suggest-override")
  endif()
endif()
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${CUSTOM_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG")

# ------------------------------------------------------------------------------
# Define packages, libs, sources, headers, resources and languages.
# ------------------------------------------------------------------------------

set(QT5_PACKAGES Core Gui Quick Widgets QuickControls2 Svg LinguistTools Network)

find_package(Linphone REQUIRED)
find_package(LinphoneCxx REQUIRED)

set(SOURCES
  src/app/App.cpp
  src/app/AvatarProvider.cpp
  src/app/DefaultTranslator.cpp
  src/app/Logger.cpp
  src/app/Paths.cpp
  src/app/ThumbnailProvider.cpp
  src/components/camera/Camera.cpp
  src/components/camera/MSFunctions.cpp
  src/components/call/CallModel.cpp
  src/components/calls/CallsListModel.cpp
  src/components/chat/ChatModel.cpp
  src/components/chat/ChatProxyModel.cpp
  src/components/contact/ContactObserver.cpp
  src/components/contact/ContactModel.cpp
  src/components/contact/VcardModel.cpp
  src/components/contacts/ContactsListModel.cpp
  src/components/contacts/ContactsListProxyModel.cpp
  src/components/core/CoreHandlers.cpp
  src/components/core/CoreManager.cpp
  src/components/notifier/Notifier.cpp
  src/components/settings/AccountSettingsModel.cpp
  src/components/settings/SettingsModel.cpp
  src/components/sip-addresses/SipAddressesModel.cpp
  src/components/smart-search-bar/SmartSearchBarModel.cpp
  src/components/timeline/TimelineModel.cpp
  src/externals/single-application/SingleApplication.cpp
  src/main.cpp
)

set(HEADERS
  src/app/App.hpp
  src/app/AvatarProvider.hpp
  src/app/DefaultTranslator.hpp
  src/app/Logger.hpp
  src/app/Paths.hpp
  src/app/ThumbnailProvider.hpp
  src/components/camera/Camera.hpp
  src/components/camera/MSFunctions.hpp
  src/components/call/CallModel.hpp
  src/components/calls/CallsListModel.hpp
  src/components/chat/ChatModel.hpp
  src/components/chat/ChatProxyModel.hpp
  src/components/contact/ContactObserver.hpp
  src/components/contact/ContactModel.hpp
  src/components/contact/VcardModel.hpp
  src/components/contacts/ContactsListModel.hpp
  src/components/contacts/ContactsListProxyModel.hpp
  src/components/core/CoreHandlers.hpp
  src/components/core/CoreManager.hpp
  src/components/notifier/Notifier.hpp
  src/components/presence/Presence.hpp
  src/components/settings/AccountSettingsModel.hpp
  src/components/settings/SettingsModel.hpp
  src/components/sip-addresses/SipAddressesModel.hpp
  src/components/smart-search-bar/SmartSearchBarModel.hpp
  src/components/timeline/TimelineModel.hpp
  src/externals/single-application/SingleApplication.hpp
  src/externals/single-application/SingleApplicationPrivate.hpp
  src/utils.hpp
)

set(QRC_RESOURCES resources.qrc)

set(LANGUAGES_DIRECTORY assets/languages)
set(I18N_FILENAME i18n.qrc)
set(LANGUAGES en fr)

# ------------------------------------------------------------------------------

function (PREPEND list prefix)
  set(new_list "")

  foreach (elem ${${list}})
    list(APPEND new_list "${prefix}${elem}")
  endforeach ()

  set(${list} ${new_list} PARENT_SCOPE)
endfunction ()

# Force absolute paths.
PREPEND(SOURCES "${CMAKE_SOURCE_DIR}/")
PREPEND(HEADERS "${CMAKE_SOURCE_DIR}/")
PREPEND(QRC_RESOURCES "${CMAKE_SOURCE_DIR}/")

# ------------------------------------------------------------------------------
# Compute QML files list.
# ------------------------------------------------------------------------------

set(QML_SOURCES)
file(STRINGS ${QRC_RESOURCES} QRC_RESOURCES_CONTENT)
foreach (line ${QRC_RESOURCES_CONTENT})
  set(result)
  string(REGEX REPLACE
    "^[ \t]*<[ \t]*file[ \t]*>[ \t]*(.+\\.qml)[ \t]*<[ \t]*/[ \t]*file[ \t]*>[ \t]*$"
    "\\1"
    result
    ${line})
  string(REGEX MATCH "qml$" isQml ${result})
  if (NOT ${isQml} STREQUAL "")
    list(APPEND QML_SOURCES "${CMAKE_SOURCE_DIR}/${result}")
  endif ()
endforeach ()

if(NOT WIN32)
  add_custom_target(
    check_qml DEPENDS ${QML_SOURCES}
    COMMAND "${CMAKE_SOURCE_DIR}/tools/check_qml_syntax"
  )
endif()

# ------------------------------------------------------------------------------
# Init git hooks.
# ------------------------------------------------------------------------------

execute_process(COMMAND ${CMAKE_COMMAND} -E copy
  "${CMAKE_SOURCE_DIR}/tools/private/pre-commit"
  "${CMAKE_SOURCE_DIR}/../.git/hooks/pre-commit"
)

# ------------------------------------------------------------------------------
# Build.
# ------------------------------------------------------------------------------

find_package(Qt5 COMPONENTS ${QT5_PACKAGES} REQUIRED)

if(CMAKE_INSTALL_RPATH)
  get_target_property(LUPDATE_PATH Qt5::lupdate LOCATION)
  get_filename_component(LUPDATE_PATH "${LUPDATE_PATH}" DIRECTORY)
  get_filename_component(QT_PATH "${LUPDATE_PATH}/../lib" ABSOLUTE)
  list(APPEND CMAKE_INSTALL_RPATH "${QT_PATH}")
endif()

# Add languages support.
add_subdirectory(${LANGUAGES_DIRECTORY})
list(APPEND QRC_RESOURCES "${CMAKE_BINARY_DIR}/${LANGUAGES_DIRECTORY}/${I18N_FILENAME}")

# Add qrc. (images, qml, translations...)
qt5_add_resources(RESOURCES ${QRC_RESOURCES})

# Build.
# Note: `update_translations` is provided by `languages/CMakeLists.txt`.
if(WIN32)
  add_executable(${TARGET_NAME} WIN32 ${SOURCES} ${HEADERS} ${RESOURCES} linphone.rc)
else()
  add_executable(${TARGET_NAME} ${SOURCES} ${HEADERS} ${RESOURCES})
endif()
  add_dependencies(${TARGET_NAME} update_translations)
if(NOT WIN32)
  add_dependencies(update_translations check_qml)
endif()
set_target_properties(${TARGET_NAME} PROPERTIES OUTPUT_NAME "${EXECUTABLE_NAME}")

target_include_directories(${TARGET_NAME} SYSTEM PRIVATE "${LINPHONE_INCLUDE_DIRS}")
foreach (package ${QT5_PACKAGES})
  target_include_directories(${TARGET_NAME} SYSTEM PRIVATE "${Qt5${package}_INCLUDE_DIRS}")
  # `qt5_create_translation` is provided from `LinguistTools` package.
  # But the `Qt5::LinguistTools` lib does not exist. Remove it.
  if (NOT (${package} STREQUAL LinguistTools))
    target_link_libraries(${TARGET_NAME} ${Qt5${package}_LIBRARIES})
  endif()
endforeach ()

target_link_libraries(${TARGET_NAME} ${LINPHONE_LIBRARIES} ${LINPHONECXX_LIBRARIES})

install(TARGETS ${TARGET_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)
