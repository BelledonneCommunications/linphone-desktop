import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import App.Styles 1.0

import 'ContactEdit.js' as Logic

// =============================================================================

ColumnLayout  {
  id: contactEdit

  property string sipAddress

  property bool _edition: false
  property var _contact
  property var _vcard

  // ---------------------------------------------------------------------------

  spacing: 0

  Component.onCompleted: Logic.handleCreation()
  Component.onDestruction: Logic.handleDestruction()

  // ---------------------------------------------------------------------------

  FileDialog {
    id: avatarChooser

    folder: shortcuts.home
    title: qsTr('avatarChooserTitle')

    onAccepted: Logic.setAvatar(fileUrls[0])
  }

  // ---------------------------------------------------------------------------
  // Info bar.
  // ---------------------------------------------------------------------------

  Rectangle {
    id: infoBar

    Layout.fillWidth: true
    Layout.preferredHeight: ContactEditStyle.bar.height
    color: ContactEditStyle.bar.color

    RowLayout {
      anchors {
        fill: parent
        leftMargin: ContactEditStyle.bar.leftMargin
        rightMargin: ContactEditStyle.bar.rightMargin
      }

      spacing: ContactEditStyle.bar.spacing

      ActionButton {
        enabled: _edition
        icon: 'contact_card_photo'
        iconSize: ContactEditStyle.bar.avatarSize

        onClicked: avatarChooser.open()

        Avatar {
          id: avatar

          anchors.fill: parent
          image: _vcard.avatar
          username: _vcard.username
          presenceLevel: _contact ? _contact.presenceLevel : -1
          visible: (isLoaded() && !parent.hovered) || !_edition
        }
      }

      TransparentTextInput {
        id: usernameInput

        Layout.fillWidth: true
        Layout.preferredHeight: ContactEditStyle.bar.buttons.size

        color: ContactEditStyle.bar.username.color

        font {
          bold: true
          pointSize: ContactEditStyle.bar.username.fontSize
        }
        forceFocus: true
        readOnly: !_edition
        text: avatar.username

        onEditingFinished: Logic.setUsername(text)
      }

      Row {
        Layout.alignment: Qt.AlignRight
        Layout.fillHeight: true

        spacing: ContactEditStyle.bar.actions.spacing
        visible: _contact != null

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter
          iconSize: ContactEditStyle.bar.actions.history.iconSize

          ActionButton {
            icon: 'history'

            onClicked: sipAddressesMenu.showMenu()
          }
        }

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter

          ActionButton {
            icon: 'edit'
            iconSize: ContactEditStyle.bar.actions.edit.iconSize

            visible: !_edition
            onClicked: Logic.editContact()
          }

          ActionButton {
            icon: 'delete'
            iconSize: ContactEditStyle.bar.actions.del.iconSize

            onClicked: Logic.removeContact()
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  SipAddressesMenu {
    id: sipAddressesMenu

    relativeTo: infoBar
    relativeX: infoBar.width - SipAddressesMenuStyle.entry.width
    relativeY: infoBar.height

    sipAddresses: _contact ? _contact.vcard.sipAddresses : [ contactEdit.sipAddress ]

    onSipAddressClicked: window.setView('Conversation', {
      sipAddress: sipAddress
    })
  }

  // ---------------------------------------------------------------------------
  // Info list.
  // ---------------------------------------------------------------------------

  Rectangle {
    Layout.fillHeight: true
    Layout.fillWidth: true

    color: ContactEditStyle.content.color

    Loader {
      anchors.fill: parent

      active: _vcard != null
      sourceComponent: Flickable {
        id: flick

        ScrollBar.vertical: ForceScrollBar {}

        boundsBehavior: Flickable.StopAtBounds
        clip: true
        contentHeight: infoList.height
        contentWidth: width - ScrollBar.vertical.width
        flickableDirection: Flickable.VerticalFlick

        // ---------------------------------------------------------------------

        Connections {
          target: _vcard

          onVcardUpdated: {
            addresses.setData(_vcard.sipAddresses)
            companies.setData(_vcard.companies)
            emails.setData(_vcard.emails)
            urls.setData(_vcard.urls)
          }
        }

        // ---------------------------------------------------------------------

        ColumnLayout {
          id: infoList

          width: flick.contentWidth

          ListForm {
            id: addresses

            Layout.leftMargin: ContactEditStyle.values.leftMargin
            Layout.rightMargin: ContactEditStyle.values.rightMargin
            Layout.topMargin: ContactEditStyle.values.topMargin

            defaultData: _vcard.sipAddresses
            minValues: _contact ? 1 : 0
            placeholder: qsTr('sipAccountsPlaceholder')
            readOnly: !_edition
            title: qsTr('sipAccounts')

            onChanged: Logic.handleSipAddressChanged(addresses, index, defaultValue, newValue)
            onRemoved: _vcard.removeSipAddress(value)
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ContactEditStyle.values.separator.height
            color: ContactEditStyle.values.separator.color
          }

          ListForm {
            id: companies

            Layout.leftMargin: ContactEditStyle.values.leftMargin
            Layout.rightMargin: ContactEditStyle.values.rightMargin

            defaultData: _vcard.companies
            placeholder: qsTr('companiesPlaceholder')
            readOnly: !_edition
            title: qsTr('companies')

            onChanged: Logic.handleCompanyChanged(companies, index, defaultValue, newValue)
            onRemoved: _vcard.removeCompany(value)
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ContactEditStyle.values.separator.height
            color: ContactEditStyle.values.separator.color
          }

          ListForm {
            id: emails

            Layout.leftMargin: ContactEditStyle.values.leftMargin
            Layout.rightMargin: ContactEditStyle.values.rightMargin

            defaultData: _vcard.emails
            inputMethodHints: Qt.ImhEmailCharactersOnly
            placeholder: qsTr('emailsPlaceholder')
            readOnly: !_edition
            title: qsTr('emails')

            onChanged: Logic.handleEmailChanged(emails, index, defaultValue, newValue)
            onRemoved: _vcard.removeEmail(value)
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ContactEditStyle.values.separator.height
            color: ContactEditStyle.values.separator.color
          }

          ListForm {
            id: urls

            Layout.leftMargin: ContactEditStyle.values.leftMargin
            Layout.rightMargin: ContactEditStyle.values.rightMargin

            defaultData: _vcard.urls
            inputMethodHints: Qt.ImhUrlCharactersOnly
            placeholder: qsTr('webSitesPlaceholder')
            readOnly: !_edition
            title: qsTr('webSites')

            onChanged: Logic.handleUrlChanged(urls, index, defaultValue, newValue)
            onRemoved: _vcard.removeUrl(value)
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ContactEditStyle.values.separator.height
            color: ContactEditStyle.values.separator.color
          }

          StaticListForm {
            Layout.leftMargin: ContactEditStyle.values.leftMargin
            Layout.rightMargin: ContactEditStyle.values.rightMargin

            fields: Logic.buildAddressFields()

            readOnly: !_edition
            title: qsTr('address')

            onChanged: Logic.handleAddressChanged(index, value)
          }

          // -------------------------------------------------------------------
          // Edition buttons.
          // -------------------------------------------------------------------

          Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: ContactEditStyle.values.bottomMargin
            Layout.topMargin: ContactEditStyle.buttons.topMargin

            spacing: ContactEditStyle.buttons.spacing
            visible: _edition

            TextButtonA {
              text: qsTr('cancel')
              onClicked: Logic.cancel()
            }

            TextButtonB {
              enabled: usernameInput.text.length > 0 && _vcard.sipAddresses.length > 0
              text: qsTr('save')
              onClicked: Logic.save()
            }
          }
        }
      }
    }
  }
}
