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
project(linphoneqt VERSION 3.9.0)

set(EXECUTABLE_NAME linphone)
set(TARGET_NAME linphone-qt)
set(CMAKE_CXX_STANDARD 11)

set(ASSETS_DIR assets)

option(ENABLE_UPDATE_CHECK "Enable update check." NO)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

if (NOT WIN32)
  check_cxx_compiler_flag("-Wsuggest-override" SUGGEST_OVERRIDE)
  set(CUSTOM_FLAGS "\
-Wall \
-Wcast-align \
-Wconversion \
-Werror=return-type \
-Wextra \
-Wfloat-equal \
-Winit-self \
-Winline \
-Wold-style-cast \
-Woverloaded-virtual \
-Wpointer-arith \
-Wuninitialized \
-Wunused \
")
  if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CUSTOM_FLAGS "${CUSTOM_FLAGS} -Wlogical-op")
  endif ()
  if (SUGGEST_OVERRIDE)
    set(CUSTOM_FLAGS "${CUSTOM_FLAGS} -Wsuggest-override -Werror=suggest-override")
  endif ()
endif ()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CUSTOM_FLAGS}")
# See: http://stackoverflow.com/a/1372836
if (WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WINSOCKAPI_")
endif ()

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG -DQT_NO_DEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG")

# ------------------------------------------------------------------------------
# Define packages, libs, sources, headers, resources and languages.
# ------------------------------------------------------------------------------

set(QT5_PACKAGES Core Gui Quick Widgets QuickControls2 Svg LinguistTools Concurrent Network)
set(QT5_PACKAGES_OPTIONAL TextToSpeech)

if (LINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS)
  include("${EP_linphone_CONFIG_DIR}/LinphoneConfig.cmake")
  include("${EP_linphone_CONFIG_DIR}/wrappers/cpp/LinphoneCxxConfig.cmake")
  include("${EP_bctoolbox_CONFIG_DIR}/BcToolboxConfig.cmake")
  include("${EP_belcard_CONFIG_DIR}/BelcardConfig.cmake")
else ()
  find_package(Linphone REQUIRED)
  find_package(LinphoneCxx REQUIRED)
  find_package(BcToolbox REQUIRED)
  find_package(Belcard REQUIRED)
endif ()

set(SOURCES
  src/app/App.cpp
  src/app/logger/Logger.cpp
  src/app/paths/Paths.cpp
  src/app/providers/AvatarProvider.cpp
  src/app/providers/ThumbnailProvider.cpp
  src/app/translator/DefaultTranslator.cpp
  src/components/assistant/AssistantModel.cpp
  src/components/authentication/AuthenticationNotifier.cpp
  src/components/call/CallModel.cpp
  src/components/calls/CallsListModel.cpp
  src/components/calls/CallsListProxyModel.cpp
  src/components/camera/Camera.cpp
  src/components/camera/CameraPreview.cpp
  src/components/camera/MSFunctions.cpp
  src/components/chat/ChatModel.cpp
  src/components/chat/ChatProxyModel.cpp
  src/components/clipboard/Clipboard.cpp
  src/components/codecs/AbstractCodecsModel.cpp
  src/components/codecs/AudioCodecsModel.cpp
  src/components/codecs/VideoCodecsModel.cpp
  src/components/conference/ConferenceAddModel.cpp
  src/components/conference/ConferenceHelperModel.cpp
  src/components/conference/ConferenceModel.cpp
  src/components/contact/ContactModel.cpp
  src/components/contact/VcardModel.cpp
  src/components/contacts/ContactsListModel.cpp
  src/components/contacts/ContactsListProxyModel.cpp
  src/components/core/CoreHandlers.cpp
  src/components/core/CoreManager.cpp
  src/components/notifier/Notifier.cpp
  src/components/presence/OwnPresenceModel.cpp
  src/components/presence/Presence.cpp
  src/components/settings/AccountSettingsModel.cpp
  src/components/settings/SettingsModel.cpp
  src/components/sip-addresses/SipAddressesModel.cpp
  src/components/sip-addresses/SipAddressesProxyModel.cpp
  src/components/sip-addresses/SipAddressObserver.cpp
  src/components/sound-player/SoundPlayer.cpp
  src/components/telephone-numbers/TelephoneNumbersModel.cpp
  src/components/text-to-speech/TextToSpeech.cpp
  src/components/timeline/TimelineModel.cpp
  src/externals/single-application/SingleApplication.cpp
  src/main.cpp
  src/LinphoneUtils.cpp
  src/Utils.cpp
)

set(HEADERS
  src/app/App.hpp
  src/app/logger/Logger.hpp
  src/app/paths/Paths.hpp
  src/app/providers/AvatarProvider.hpp
  src/app/providers/ThumbnailProvider.hpp
  src/app/translator/DefaultTranslator.hpp
  src/components/assistant/AssistantModel.hpp
  src/components/authentication/AuthenticationNotifier.hpp
  src/components/call/CallModel.hpp
  src/components/calls/CallsListModel.hpp
  src/components/calls/CallsListProxyModel.hpp
  src/components/camera/Camera.hpp
  src/components/camera/CameraPreview.hpp
  src/components/camera/MSFunctions.hpp
  src/components/chat/ChatModel.hpp
  src/components/chat/ChatProxyModel.hpp
  src/components/clipboard/Clipboard.cpp
  src/components/codecs/AbstractCodecsModel.hpp
  src/components/codecs/AudioCodecsModel.hpp
  src/components/codecs/VideoCodecsModel.hpp
  src/components/Components.hpp
  src/components/conference/ConferenceAddModel.hpp
  src/components/conference/ConferenceHelperModel.hpp
  src/components/conference/ConferenceModel.hpp
  src/components/contact/ContactModel.hpp
  src/components/contact/VcardModel.hpp
  src/components/contacts/ContactsListModel.hpp
  src/components/contacts/ContactsListProxyModel.hpp
  src/components/core/CoreHandlers.hpp
  src/components/core/CoreManager.hpp
  src/components/notifier/Notifier.hpp
  src/components/presence/OwnPresenceModel.hpp
  src/components/presence/Presence.hpp
  src/components/settings/AccountSettingsModel.hpp
  src/components/settings/SettingsModel.hpp
  src/components/sip-addresses/SipAddressesModel.hpp
  src/components/sip-addresses/SipAddressesProxyModel.hpp
  src/components/sip-addresses/SipAddressObserver.hpp
  src/components/sound-player/SoundPlayer.hpp
  src/components/telephone-numbers/TelephoneNumbersModel.hpp
  src/components/text-to-speech/TextToSpeech.hpp
  src/components/timeline/TimelineModel.hpp
  src/externals/single-application/SingleApplication.hpp
  src/externals/single-application/SingleApplicationPrivate.hpp
  src/LinphoneUtils.hpp
  src/Utils.hpp
)

set(QRC_RESOURCES resources.qrc)

set(LANGUAGES_DIRECTORY "${ASSETS_DIR}/languages")
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
PREPEND(SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/")
PREPEND(HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/")
PREPEND(QRC_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/")

# ------------------------------------------------------------------------------
# Compute QML files list.
# ------------------------------------------------------------------------------

set(QML_SOURCES)
file(STRINGS ${QRC_RESOURCES} QRC_RESOURCES_CONTENT)
foreach (line ${QRC_RESOURCES_CONTENT})
  set(result)
  string(REGEX REPLACE
    "^[ \t]*<[ \t]*file[ \t]*>[ \t]*(.+\\.[a-z]+)[ \t]*<[ \t]*/[ \t]*file[ \t]*>[ \t]*$"
    "\\1"
    result
    ${line})
  string(REGEX MATCH "\\.[a-z]+$" isUi ${result})
  if (NOT ${isUi} STREQUAL "")
    list(APPEND QML_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/${result}")
  endif ()
endforeach ()

# ------------------------------------------------------------------------------
# Init git hooks.
# ------------------------------------------------------------------------------

if (NOT WIN32)
  add_custom_target(
    check_qml DEPENDS ${QML_SOURCES}
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tools/check_qml_syntax"
  )
endif ()

execute_process(COMMAND ${CMAKE_COMMAND} -E copy
  "${CMAKE_CURRENT_SOURCE_DIR}/tools/private/pre-commit"
  "${CMAKE_CURRENT_SOURCE_DIR}/../.git/hooks/pre-commit"
)

# ------------------------------------------------------------------------------
# Create config.h file
# ------------------------------------------------------------------------------

set(MSPLUGINS_DIR "${CMAKE_INSTALL_LIBDIR}/mediastreamer/plugins")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake" "${CMAKE_CURRENT_BINARY_DIR}/config.h")

# ------------------------------------------------------------------------------
# Build.
# ------------------------------------------------------------------------------

find_package(Qt5 COMPONENTS ${QT5_PACKAGES} REQUIRED)
find_package(Qt5 COMPONENTS ${QT5_PACKAGES_OPTIONAL} QUIET)

if (CMAKE_INSTALL_RPATH)
  get_target_property(LUPDATE_PATH Qt5::lupdate LOCATION)
  get_filename_component(LUPDATE_PATH "${LUPDATE_PATH}" DIRECTORY)
  get_filename_component(QT_PATH "${LUPDATE_PATH}/../lib" ABSOLUTE)
  list(APPEND CMAKE_INSTALL_RPATH "${QT_PATH}")
endif ()

# Add languages support.
add_subdirectory(${LANGUAGES_DIRECTORY})
list(APPEND QRC_RESOURCES "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGES_DIRECTORY}/${I18N_FILENAME}")

# Add qrc. (images, qml, translations...)
qt5_add_resources(RESOURCES ${QRC_RESOURCES})

# Build.
# Note: `update_translations` is provided by `languages/CMakeLists.txt`.
if (WIN32)
  add_executable(${TARGET_NAME} WIN32 ${SOURCES} ${HEADERS} ${RESOURCES} linphone.rc)
else ()
  add_executable(${TARGET_NAME} ${SOURCES} ${HEADERS} ${RESOURCES})
endif ()
  bc_git_version(${TARGET_NAME} ${PROJECT_VERSION})
  add_dependencies(${TARGET_NAME} ${TARGET_NAME}-git-version)
  add_dependencies(${TARGET_NAME} update_translations)
if (NOT WIN32)
  add_dependencies(update_translations check_qml)
endif ()
set_target_properties(${TARGET_NAME} PROPERTIES OUTPUT_NAME "${EXECUTABLE_NAME}")
target_include_directories(${TARGET_NAME} SYSTEM PRIVATE "${LINPHONECXX_INCLUDE_DIRS}" "${LINPHONE_INCLUDE_DIRS}" "${BELCARD_INCLUDE_DIRS}" "${BCTOOLBOX_INCLUDE_DIRS}")

foreach (package ${QT5_PACKAGES})
  target_include_directories(${TARGET_NAME} SYSTEM PRIVATE "${Qt5${package}_INCLUDE_DIRS}")
  # `qt5_create_translation` is provided from `LinguistTools` package.
  # But the `Qt5::LinguistTools` lib does not exist. Remove it.
  if (NOT (${package} STREQUAL LinguistTools))
    target_link_libraries(${TARGET_NAME} ${Qt5${package}_LIBRARIES})
  endif ()
endforeach ()

foreach (package ${QT5_PACKAGES_OPTIONAL})
  if ("${Qt5${package}_FOUND}")
    message("Optional package ${package} found.")
    target_include_directories(${TARGET_NAME} SYSTEM PRIVATE "${Qt5${package}_INCLUDE_DIRS}")
    target_link_libraries(${TARGET_NAME} ${Qt5${package}_LIBRARIES})

    string(TOUPPER "${package}" INCLUDE_NAME)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D${INCLUDE_NAME}_ENABLED")
  else ()
    message("Optional package ${package} not found.")
  endif ()
endforeach ()

target_link_libraries(${TARGET_NAME} ${BCTOOLBOX_CORE_LIBRARIES} ${BELCARD_LIBRARIES} ${LINPHONE_LIBRARIES} ${LINPHONECXX_LIBRARIES})

install(TARGETS ${TARGET_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

# ------------------------------------------------------------------------------
# Install rc files.
# ------------------------------------------------------------------------------

install(FILES "${ASSETS_DIR}/linphonerc-factory"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/linphone"
)

set(ASSETS_ASSISTANT_DIR "${ASSETS_DIR}/assistant")
set(ASSISTANT_INSTALL_DATADIR "${CMAKE_INSTALL_DATADIR}/linphone/assistant")

install(FILES "${ASSETS_ASSISTANT_DIR}/use-other-sip-account.rc"
  DESTINATION "${ASSISTANT_INSTALL_DATADIR}"
)
install(FILES "${ASSETS_ASSISTANT_DIR}/create-linphone-sip-account.rc"
  DESTINATION "${ASSISTANT_INSTALL_DATADIR}"
)
install(FILES "${ASSETS_ASSISTANT_DIR}/use-linphone-sip-account.rc"
  DESTINATION "${ASSISTANT_INSTALL_DATADIR}"
)
