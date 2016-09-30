QT = core gui quick widgets quickcontrols2

TARGET = linphone
TEMPLATE = app
CONFIG += c++11

RESOURCES = resources.qrc

SOURCES = \
  src/app.cpp \
  src/main.cpp \
  src/models/contacts/ContactModel.cpp \
  src/models/contacts/ContactsListModel.cpp \
  src/models/notification/NotificationModel.cpp \
  src/models/settings/AccountSettingsListModel.cpp \
  src/models/settings/AccountSettingsModel.cpp \
  src/models/settings/SettingsModel.cpp \

HEADERS = \
  src/app.hpp \
  src/models/contacts/ContactModel.hpp \
  src/models/contacts/ContactsListModel.hpp \
  src/models/notification/NotificationModel.hpp \
  src/models/settings/AccountSettingsListModel.hpp \
  src/models/settings/AccountSettingsModel.hpp \
  src/models/settings/SettingsModel.hpp \

TRANSLATIONS = \
  languages/en.ts \
  languages/fr.ts \

lupdate_only{
  SOURCES = \
    ui/modules/Linphone/*.qml \
    ui/modules/Linphone/Chat/*.qml \
    ui/modules/Linphone/Contact/*.qml \
    ui/modules/Linphone/Dialog/*.qml \
    ui/modules/Linphone/Form/*.qml \
    ui/modules/Linphone/Image/*.qml \
    ui/modules/Linphone/Popup/*.qml \
    ui/modules/Linphone/Select/*.qml \
    ui/modules/Linphone/Styles/*.qml \
    ui/modules/Linphone/Styles/Contact/*.qml \
    ui/modules/Linphone/Styles/Form/*.qml \
    ui/modules/Linphone/View/*.qml \
    ui/views/*.qml \
    ui/views/MainWindow/*.qml \

}
