cmake_minimum_required(VERSION 3.0)
project(linphone)

set(LINPHONE_EXEC linphone)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

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
  src/app.cpp
  src/components/contacts/ContactModel.cpp
  src/components/contacts/ContactsListModel.cpp
  src/components/contacts/ContactsListProxyModel.cpp
  src/components/notification/Notification.cpp
  src/components/settings/AccountSettingsListModel.cpp
  src/components/settings/AccountSettingsModel.cpp
  src/components/settings/SettingsModel.cpp
  src/main.cpp
)

set(HEADERS
  src/app.hpp
  src/components/contacts/ContactModel.hpp
  src/components/contacts/ContactsListModel.hpp
  src/components/contacts/ContactsListProxyModel.hpp
  src/components/notification/Notification.hpp
  src/components/presence/Presence.hpp
  src/components/settings/AccountSettingsListModel.hpp
  src/components/settings/AccountSettingsModel.hpp
  src/components/settings/SettingsModel.hpp
)

set(QRC_RESOURCES
  resources.qrc
)

set(LANGUAGES_DIRECTORY languages)
set(LANGUAGES en fr)

# --------------------------------------------------------------------

find_package(Qt5 COMPONENTS ${QT5_PACKAGES})

# Build languages resource file.
set(TS_FILES)
set(I18N_CONTENT "<!DOCTYPE RCC>\n<RCC version=\"1.0\">\n  <qresource prefix=\"/\">\n")
foreach (lang ${LANGUAGES})
  list(APPEND TS_FILES "${LANGUAGES_DIRECTORY}/${lang}.ts")

  # Note: the below `languages/` path is not the same as the `${LANGUAGES_DIRECTORY}` value.
  # It's the symbolic path used by the linphone binary in the qrc model.
  set(I18N_CONTENT "${I18N_CONTENT}    <file alias=\"languages/${lang}\">${lang}.qm</file>\n")
endforeach ()
set(I18N_CONTENT "${I18N_CONTENT}  </qresource>\n</RCC>\n")

set(I18N_RESOURCE i18n.qrc)
file(WRITE "${CMAKE_BINARY_DIR}/${I18N_RESOURCE}" "${I18N_CONTENT}")

# Create `qm` files from `ts` files.
qt5_create_translation(QM_FILES ${TS_FILES} src ui)

# Add qrc. (images, qml, translations...)
qt5_add_resources(RESOURCES ${QRC_RESOURCES} "${CMAKE_BINARY_DIR}/${I18N_RESOURCE}")

# Build.
add_executable(${LINPHONE_EXEC} ${SOURCES} ${HEADERS} ${RESOURCES})
target_link_libraries(${LINPHONE_EXEC} ${LIBS})
