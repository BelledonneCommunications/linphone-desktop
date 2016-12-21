# ==============================================================================
# CMakeLists.txt
# ==============================================================================

cmake_minimum_required(VERSION 3.1)
project(linphone)

set(LINPHONE_EXEC linphone)
set(CMAKE_CXX_STANDARD 11)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CUSTOM_FLAGS "\
-Wcast-align \
-Wconversion \
-Werror=suggest-override \
-Wextra \
-Wfloat-equal \
-Winit-self \
-Winline \
-Wlogical-op \
-Wold-style-cast \
-Woverloaded-virtual \
-Wpointer-arith \
-Wsuggest-override \
-Wuninitialized \
-Wunused \
")
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${CUSTOM_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG")

# ------------------------------------------------------------------------------
# Define packages, libs, sources, headers, resources and languages.
# ------------------------------------------------------------------------------

set(QT5_PACKAGES Core Gui Quick Widgets QuickControls2 LinguistTools)

set(LIBS)
foreach (package ${QT5_PACKAGES})
  # `qt5_create_translation` is provided from `LinguistTools` package.
  # But the `Qt5::LinguistTools` lib does not exist. Remove it.
  if (NOT (${package} STREQUAL LinguistTools))
    list(APPEND LIBS "Qt5::${package}")
  endif ()
endforeach ()

list(APPEND LIBS "${CMAKE_SOURCE_DIR}/../OUTPUT/desktop/lib64/liblinphone++.so")
list(APPEND LIBS "${CMAKE_SOURCE_DIR}/../OUTPUT/desktop/lib64/libbelcard.so")

set(SOURCES
  src/app/App.cpp
  src/app/AvatarProvider.cpp
  src/app/Database.cpp
  src/app/DefaultTranslator.cpp
  src/app/Logger.cpp
  src/components/camera/Camera.cpp
  src/components/chat/ChatModel.cpp
  src/components/chat/ChatProxyModel.cpp
  src/components/contact/ContactModel.cpp
  src/components/contact/VcardModel.cpp
  src/components/contacts/ContactsListModel.cpp
  src/components/contacts/ContactsListProxyModel.cpp
  src/components/core/CoreManager.cpp
  src/components/notifier/Notifier.cpp
  src/components/settings/AccountSettingsModel.cpp
  src/components/settings/SettingsModel.cpp
  src/components/sip-addresses/SipAddressesModel.cpp
  src/components/sip-addresses/UnregisteredSipAddressesModel.cpp
  src/components/sip-addresses/UnregisteredSipAddressesProxyModel.cpp
  src/components/smart-search-bar/SmartSearchBarModel.cpp
  src/components/timeline/TimelineModel.cpp
  src/main.cpp
)

set(HEADERS
  src/app/App.hpp
  src/app/AvatarProvider.hpp
  src/app/Database.hpp
  src/app/DefaultTranslator.hpp
  src/app/Logger.hpp
  src/components/camera/Camera.hpp
  src/components/chat/ChatModel.hpp
  src/components/chat/ChatProxyModel.hpp
  src/components/contact/ContactModel.hpp
  src/components/contact/VcardModel.hpp
  src/components/contacts/ContactsListModel.hpp
  src/components/contacts/ContactsListProxyModel.hpp
  src/components/core/CoreManager.hpp
  src/components/notifier/Notifier.hpp
  src/components/presence/Presence.hpp
  src/components/settings/AccountSettingsModel.hpp
  src/components/settings/SettingsModel.hpp
  src/components/sip-addresses/SipAddressesModel.hpp
  src/components/sip-addresses/UnregisteredSipAddressesModel.hpp
  src/components/sip-addresses/UnregisteredSipAddressesProxyModel.hpp
  src/components/smart-search-bar/SmartSearchBarModel.hpp
  src/components/timeline/TimelineModel.hpp
  src/utils.hpp
)

set(QRC_RESOURCES
  resources.qrc
)

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

add_custom_target(
  check_qml DEPENDS ${QML_SOURCES}
  COMMAND "${CMAKE_SOURCE_DIR}/tools/check_qml_syntax"
)

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

find_package(Qt5 COMPONENTS ${QT5_PACKAGES})

# Add languages support.
add_subdirectory(${LANGUAGES_DIRECTORY})
list(APPEND QRC_RESOURCES "${CMAKE_BINARY_DIR}/${LANGUAGES_DIRECTORY}/${I18N_FILENAME}")

# Add qrc. (images, qml, translations...)
qt5_add_resources(RESOURCES ${QRC_RESOURCES})

# Build.
# Note: `update_translations` is provided by `languages/CMakeLists.txt`.
add_executable(${LINPHONE_EXEC} ${SOURCES} ${HEADERS} ${RESOURCES})
add_dependencies(${LINPHONE_EXEC} update_translations)
add_dependencies(update_translations check_qml)

target_include_directories(${LINPHONE_EXEC} SYSTEM PRIVATE "${CMAKE_SOURCE_DIR}/../OUTPUT/desktop/include/")

target_link_libraries(${LINPHONE_EXEC} ${LIBS})
