cmake_minimum_required(VERSION 3.0)
project(linphone)

set(LINPHONE_EXEC linphone)

# Use automatically moc from Qt5.
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(QT5_PACKAGES Core Gui Quick Widgets QuickControls2)

set(LIBS "")
foreach(package ${QT5_PACKAGES})
  list(APPEND LIBS "Qt::${package}")

find_package(Qt5 COMPONENTS ${QT5_PACKAGES})

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

# Include `qrc` files.
qt5_add_resources(RESOURCES resources.qrc)

# Build.
add_executable(${LINPHONE_EXEC} ${SOURCES} ${HEADERS} ${RESOURCES})
target_link_libraries(${LINPHONE_EXEC} ${LIBS})
