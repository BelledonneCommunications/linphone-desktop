# ====================================================================
# CMakeLists.txt
# ====================================================================

cmake_minimum_required(VERSION 3.0)
project(linphone)

set(LINPHONE_EXEC linphone)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# --------------------------------------------------------------------
# Define packages, libs, sources, headers, resources and languages
# --------------------------------------------------------------------

set(QT5_PACKAGES Core Gui Quick Widgets QuickControls2 LinguistTools)

set(LIBS)
foreach (package ${QT5_PACKAGES})
  # `qt5_create_translation` is provided from `LinguistTools` package.
  # But the `Qt5::LinguistTools` lib does not exist. Remove it.
  if (NOT (${package} STREQUAL LinguistTools))
    list(APPEND LIBS "Qt5::${package}")
  endif ()
endforeach ()

set(SOURCES
  src/app/App.cpp
  src/app/Logger.cpp
  src/components/chat/ChatModel.cpp
  src/components/contacts/ContactModel.cpp
  src/components/contacts/ContactsListModel.cpp
  src/components/contacts/ContactsListProxyModel.cpp
  src/components/linphone/LinphoneCore.cpp
  src/components/notifier/Notifier.cpp
  src/components/settings/AccountSettingsModel.cpp
  src/components/settings/SettingsModel.cpp
  src/components/timeline/TimelineModel.cpp
  src/main.cpp
)

set(HEADERS
  src/app/App.hpp
  src/app/Logger.hpp
  src/components/chat/ChatModel.hpp
  src/components/contacts/ContactModel.hpp
  src/components/contacts/ContactsListModel.hpp
  src/components/contacts/ContactsListProxyModel.hpp
  src/components/linphone/LinphoneCore.hpp
  src/components/notifier/Notifier.hpp
  src/components/presence/Presence.hpp
  src/components/settings/AccountSettingsModel.hpp
  src/components/settings/SettingsModel.hpp
  src/components/timeline/TimelineModel.hpp
)

set(QRC_RESOURCES
  resources.qrc
)

set(LANGUAGES_DIRECTORY assets/languages)
set(I18N_FILENAME i18n.qrc)
set(LANGUAGES en fr)

# --------------------------------------------------------------------

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

# --------------------------------------------------------------------
# Compute QML files list.
# --------------------------------------------------------------------

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

# --------------------------------------------------------------------
# Init git hooks.
# --------------------------------------------------------------------

execute_process(COMMAND ${CMAKE_COMMAND} -E copy
  "${CMAKE_SOURCE_DIR}/tools/private/pre-commit"
  "${CMAKE_SOURCE_DIR}/../.git/hooks/pre-commit"
)

# --------------------------------------------------------------------
# Build.
# --------------------------------------------------------------------

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
target_link_libraries(${LINPHONE_EXEC} ${LIBS})
