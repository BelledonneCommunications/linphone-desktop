QT = core gui quick widgets quickcontrols2

TARGET = linphone
TEMPLATE = app

SOURCES = \
  src/app.cpp \
  src/main.cpp \
  src/models/settings/AccountSettingsModel.cpp \
  src/models/settings/SettingsModel.cpp

HEADERS = \
  src/app.hpp \
  src/models/settings/AccountSettingsModel.hpp \
  src/models/settings/SettingsModel.hpp

TRANSLATIONS = \
  languages/en.ts \
  languages/fr.ts

lupdate_only{
  # Each component folder must be added explicitly.
  SOURCES = \
    ui/components/dialog/*.qml \
    ui/components/form/*.qml \
    ui/components/misc/*.qml \
    ui/components/select/*.qml \
    ui/views/*.qml \
    ui/views/mainWindow/*.qml
}

RESOURCES += \
  resources.qrc
