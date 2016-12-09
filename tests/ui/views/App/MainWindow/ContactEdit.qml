import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

// ===================================================================

ColumnLayout  {
  id: contactEdit

  property string sipAddress: ''

  property var _contact

  // -----------------------------------------------------------------

  function _removeContact () {
    Utils.openConfirmDialog(window, {
      descriptionText: qsTr('removeContactDescription'),
      exitHandler: function (status) {
        if (status) {
          ContactsListModel.removeContact(_contact)
          window.setView('Home')
        }
      },
      title: qsTr('removeContactTitle')
    })
  }

  function _setAvatar (path) {
    if (Utils.isObject(_contact) && path) {
      _contact.avatar = path.match(/^(?:file:\/\/)?(.*)$/)[1]
    }
  }

  function _setUsername (username) {
    if (Utils.isObject(_contact)) {
      _contact.username = username

      // Update current text with new username.
      usernameInput.text = _contact.username
    }
  }

  // -----------------------------------------------------------------

  spacing: 0

  Component.onCompleted:  {
    var contact = ContactsListModel.mapSipAddressToContact(sipAddress)

    if (contact) {
      infoUpdater.connect(contact, 'onContactUpdated', function () {
        addresses.setData(contact.sipAddresses)
        companies.setData(contact.companies)
        emails.setData(contact.emails)
        urls.setData(contact.urls)
      })

      _contact = contact
    } else {
      _contact = sipAddress
    }
  }

  // -----------------------------------------------------------------

  FileDialog {
    id: avatarChooser

    folder: shortcuts.home
    title: qsTr('avatarChooserTitle')

    onAccepted: _setAvatar(fileUrls[0])
  }

  // -----------------------------------------------------------------
  // Info bar.
  // -----------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: ContactEditStyle.infoBar.height
    color: ContactEditStyle.infoBar.color

    RowLayout {
      anchors {
        fill: parent
        leftMargin: ContactEditStyle.infoBar.leftMargin
        rightMargin: ContactEditStyle.infoBar.rightMargin
      }

      spacing: ContactEditStyle.infoBar.spacing

      ActionButton {
        icon: 'contact_card_photo'
        iconSize: ContactEditStyle.infoBar.avatarSize

        onClicked: avatarChooser.open()

        Avatar {
          id: avatar

          anchors.fill: parent
          image: _contact.avatar
          username: LinphoneUtils.getContactUsername(_contact) || 'John Doe'
          visible: isLoaded() && !parent.hovered
        }
      }

      TransparentTextInput {
        id: usernameInput

        Layout.fillWidth: true
        Layout.preferredHeight: ContactEditStyle.infoBar.buttons.size

        color: ContactEditStyle.infoBar.username.color

        font {
          bold: true
          pointSize: ContactEditStyle.infoBar.username.fontSize
        }

        text: avatar.username

        onEditingFinished: _setUsername(text)
      }

      ActionBar {
        Layout.alignment: Qt.AlignRight
        iconSize: ContactEditStyle.infoBar.buttons.size
        spacing: ContactEditStyle.infoBar.buttons.spacing
        visible: Utils.isObject(_contact)

        ActionButton {
          icon: 'history'
          onClicked: window.setView('Conversation', {
            sipAddress: contactEdit.sipAddress
          })
        }

        ActionButton {
          icon: 'delete'
          onClicked: _removeContact()
        }
      }
    }
  }

  // -----------------------------------------------------------------
  // Info list.
  // -----------------------------------------------------------------

  Flickable {
    id: flick

    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.vertical: ForceScrollBar {}

    boundsBehavior: Flickable.StopAtBounds
    clip: true
    contentHeight: infoList.height
    contentWidth: width - ScrollBar.vertical.width - leftMargin - rightMargin
    flickableDirection: Flickable.VerticalFlick

    leftMargin: ContactEditStyle.values.leftMargin
    rightMargin: ContactEditStyle.values.rightMargin
    topMargin: ContactEditStyle.values.topMargin

    ColumnLayout {
      id: infoList

      width: flick.contentWidth

      SmartConnect {
        id: infoUpdater
      }

      ListForm {
        id: addresses

        defaultData: _contact.sipAddresses
        placeholder: qsTr('sipAccountsInput')
        title: qsTr('sipAccounts')

        onChanged: default_value.length === 0
          ? _contact.addSipAddress(new_value)
          : _contact.updateSipAddress(default_value, new_value)
        onRemoved: _contact.removeSipAddress(value)
      }

      ListForm {
        id: companies

        defaultData: _contact.companies
        placeholder: qsTr('companiesInput')
        title: qsTr('companies')
      }

      ListForm {
        id: emails

        defaultData: _contact.emails
        placeholder: qsTr('emailsInput')
        title: qsTr('emails')

        onChanged: default_value.length === 0
          ? _contact.addEmail(new_value)
          : _contact.updateEmail(default_value, new_value)
        onRemoved: _contact.removeEmail(value)
      }

      ListForm {
        id: urls

        defaultData: _contact.urls
        placeholder: qsTr('webSitesInput')
        title: qsTr('webSites')
      }
    }
  }
}

/*      ListForm {                              */
/*        title: qsTr('address')                */
/*        placeholder: qsTr('addressInput')     */
/*      }                                       */
