QT = core gui quick widgets quickcontrols2

TARGET = linphone
TEMPLATE = app
CONFIG += c++11

RESOURCES = resources.qrc

SOURCES = \
  src/app.cpp \
  src/components/contacts/ContactModel.cpp \
  src/components/contacts/ContactsListModel.cpp \
  src/components/contacts/ContactsListProxyModel.cpp \
  src/components/notification/Notification.cpp \
  src/components/settings/AccountSettingsListModel.cpp \
  src/components/settings/AccountSettingsModel.cpp \
  src/components/settings/SettingsModel.cpp \
  src/main.cpp \

HEADERS = \
  src/app.hpp \
  src/components/contacts/ContactModel.hpp \
  src/components/contacts/ContactsListModel.hpp \
  src/components/contacts/ContactsListProxyModel.hpp \
  src/components/notification/Notification.hpp \
  src/components/presence/Presence.hpp \
  src/components/settings/AccountSettingsListModel.hpp \
  src/components/settings/AccountSettingsModel.hpp \
  src/components/settings/SettingsModel.hpp \

TRANSLATIONS = \
  languages/en.ts \
  languages/fr.ts \

lupdate_only{
  SOURCES = \
    ui/modules/Common/*.qml \
    ui/modules/Common/Dialog/*.qml \
    ui/modules/Common/Form/*.qml \
    ui/modules/Common/Image/*.qml \
    ui/modules/Common/Popup/*.qml \
    ui/modules/Common/Styles/*.qml \
    ui/modules/Common/Styles/Form/*.qml \
    ui/modules/Common/View/*.qml \
    ui/modules/Linphone/*.qml \
    ui/modules/Linphone/Chat/*.qml \
    ui/modules/Linphone/Contact/*.qml \
    ui/modules/Linphone/Select/*.qml \
    ui/modules/Linphone/Styles/*.qml \
    ui/modules/Linphone/Styles/Contact/*.qml \
    ui/views/*.qml \
    ui/views/Calls/*.qml \
    ui/views/MainWindow/*.qml \

}
