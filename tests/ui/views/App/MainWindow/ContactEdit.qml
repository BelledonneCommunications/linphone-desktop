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

  function _handleSipAddressChanged (index, default_value, new_value) {
    if (!Utils.startsWith(new_value, 'sip:')) {
      new_value = 'sip:' + new_value

      if (new_value === default_value) {
        return
      }
    }

    var so_far_so_good = (default_value.length === 0)
      ? _contact.addSipAddress(new_value)
      : _contact.updateSipAddress(default_value, new_value)

    if (!so_far_so_good) {
      addresses.setInvalid(index, true)
    }
  }

  function _handleUrlChanged (index, default_value, new_value) {
    var url = Utils.extractFirstUri(new_value)
    if (url === default_value) {
      return
    }

    var so_far_so_good = (default_value.length === 0)
      ? url && _contact.addUrl(new_value)
      : url && _contact.updateUrl(default_value, new_value)

    if (!so_far_so_good) {
      urls.setInvalid(index, true)
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
    contentWidth: width - ScrollBar.vertical.width
    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
      id: infoList

      width: flick.contentWidth

      SmartConnect {
        id: infoUpdater
      }

      ListForm {
        id: addresses

        Layout.leftMargin: ContactEditStyle.values.leftMargin
        Layout.rightMargin: ContactEditStyle.values.rightMargin
        Layout.topMargin: ContactEditStyle.values.topMargin

        defaultData: _contact.sipAddresses
        placeholder: qsTr('sipAccountsInput')
        title: qsTr('sipAccounts')

        onChanged: _handleSipAddressChanged(index, default_value, new_value)
        onRemoved: _contact.removeSipAddress(value)
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

        defaultData: _contact.companies
        placeholder: qsTr('companiesInput')
        title: qsTr('companies')

        onChanged: default_value.length === 0
          ? _contact.addCompany(new_value)
          : _contact.updateCompany(default_value, new_value)
        onRemoved: _contact.removeCompany(value)
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

        defaultData: _contact.emails
        placeholder: qsTr('emailsInput')
        title: qsTr('emails')

        onChanged: default_value.length === 0
          ? _contact.addEmail(new_value)
          : _contact.updateEmail(default_value, new_value)
        onRemoved: _contact.removeEmail(value)
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

        defaultData: _contact.urls
        placeholder: qsTr('webSitesInput')
        title: qsTr('webSites')

        onChanged: _handleUrlChanged(index, default_value, new_value)
        onRemoved: _contact.removeUrl(value)
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: ContactEditStyle.values.separator.height
        color: ContactEditStyle.values.separator.color
      }

      Loader {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: ContactEditStyle.buttons.topMargin

        sourceComponent: Row {
          spacing: ContactEditStyle.buttons.spacing

          TextButtonB {
            text: qsTr('save')
          }

          TextButtonA {
            text: qsTr('cancel')
          }
        }
      }

      Item {
        Layout.bottomMargin: ContactEditStyle.values.bottomMargin
      }
    }
  }
}
