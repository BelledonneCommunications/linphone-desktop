QT = core gui quick widgets quickcontrols2

TARGET = linphone
TEMPLATE = app
CONFIG += c++11

RESOURCES = resources.qrc

SOURCES = \
  src/app.cpp \
  src/main.cpp \
  src/models/notification/NotificationModel.cpp \
  src/models/settings/AccountSettingsListModel.cpp \
  src/models/settings/AccountSettingsModel.cpp \
  src/models/settings/SettingsModel.cpp \

HEADERS = \
  src/app.hpp \
  src/models/notification/NotificationModel.hpp \
  src/models/settings/AccountSettingsListModel.hpp \
  src/models/settings/AccountSettingsModel.hpp \
  src/models/settings/SettingsModel.hpp \

TRANSLATIONS = \
  languages/en.ts \
  languages/fr.ts \

lupdate_only{
  SOURCES = \
    ui/Linphone/*.qml \
    ui/Linphone/Chat/*.qml \
    ui/Linphone/Collapse/*.qml \
    ui/Linphone/Contact/*.qml \
    ui/Linphone/Dialog/*.qml \
    ui/Linphone/Form/*.qml \
    ui/Linphone/Image/*.qml \
    ui/Linphone/InvertedMouseArea/*.qml \
    ui/Linphone/Misc/*.qml \
    ui/Linphone/Popup/*.qml \
    ui/Linphone/ScrollBar/*.qml \
    ui/Linphone/SearchBox/*.qml \
    ui/Linphone/Select/*.qml \
    ui/Linphone/Styles/*.qml \
    ui/Linphone/Timeline/*.qml \
    ui/Linphone/View/*.qml \
    ui/Views/*.qml \
    ui/Views/MainWindow/*.qml \

}
