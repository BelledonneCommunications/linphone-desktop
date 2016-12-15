import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout  {
  id: contactEdit

  property string sipAddress

  property bool _edition: false
  property var _contact
  property var _vcard

  // ---------------------------------------------------------------------------

  function _editContact () {
    _contact.startEdit()
    _edition = true
  }

  function _save () {
    if (_contact) {
      _contact.endEdit()
    } else {
      _contact = ContactsListModel.addContact(_vcard)
    }

    _edition = false
  }

  function _cancel () {
    if (_contact) {
      _contact.abortEdit()
      _edition = false
    } else {
      window.setView('Contacts')
    }
  }

  function _removeContact () {
    Utils.openConfirmDialog(window, {
      descriptionText: qsTr('removeContactDescription'),
      exitHandler: function (status) {
        if (status) {
          window.setView('Contacts')
          ContactsListModel.removeContact(_contact)
        }
      },
      title: qsTr('removeContactTitle')
    })
  }

  function _setAvatar (path) {
    _vcard.avatar = path.match(/^(?:file:\/\/)?(.*)$/)[1]
  }

  function _setUsername (username) {
    _vcard.username = username

    // Update current text with new/old username.
    usernameInput.text = _vcard.username
  }

  function _handleSipAddressChanged (index, defaultValue, newValue) {
    if (!Utils.startsWith(newValue, 'sip:')) {
      newValue = 'sip:' + newValue

      if (newValue === defaultValue) {
        return
      }
    }

    var so_far_so_good = (defaultValue.length === 0)
      ? _vcard.addSipAddress(newValue)
      : _vcard.updateSipAddress(defaultValue, newValue)

    addresses.setInvalid(index, !so_far_so_good)
  }

  function _handleUrlChanged (index, defaultValue, newValue) {
    var url = Utils.extractFirstUri(newValue)
    if (url === defaultValue) {
      return
    }

    var so_far_so_good = (defaultValue.length === 0)
      ? url && _vcard.addUrl(newValue)
      : url && _vcard.updateUrl(defaultValue, newValue)

    urls.setInvalid(index, !so_far_so_good)
  }

  // ---------------------------------------------------------------------------

  spacing: 0

  Component.onCompleted: {
    _contact = ContactsListModel.mapSipAddressToContact(sipAddress)

    if (!_contact) {
      _vcard = CoreManager.createDetachedVcardModel()
      _edition = true
    } else {
      _vcard = _contact.vcard
    }
  }

  Component.onDestruction: {
    if (_edition && _contact) {
      _contact.abortEdit()
    }

    // TODO: Remove photo if contact not created.
  }

  // ---------------------------------------------------------------------------

  FileDialog {
    id: avatarChooser

    folder: shortcuts.home
    title: qsTr('avatarChooserTitle')

    onAccepted: _setAvatar(fileUrls[0])
  }

  // ---------------------------------------------------------------------------
  // Info bar.
  // ---------------------------------------------------------------------------

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
          image: _vcard.avatar
          username: _vcard.username
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
        forceFocus: true
        readOnly: !_edition
        text: avatar.username

        onEditingFinished: _setUsername(text)
      }

      ActionBar {
        Layout.alignment: Qt.AlignRight
        iconSize: ContactEditStyle.infoBar.buttons.size
        spacing: ContactEditStyle.infoBar.buttons.spacing
        visible: _contact != null

        ActionButton {
          icon: 'history'

          onClicked: window.setView('Conversation', {
            sipAddress: contactEdit.sipAddress
          })
        }

        ActionButton {
          icon: 'edit'
          visible: !_edition
          onClicked: _editContact()
        }

        ActionButton {
          icon: 'delete'

          onClicked: _removeContact()
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Info list.
  // ---------------------------------------------------------------------------

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

      ListForm {
        id: addresses

        Layout.leftMargin: ContactEditStyle.values.leftMargin
        Layout.rightMargin: ContactEditStyle.values.rightMargin
        Layout.topMargin: ContactEditStyle.values.topMargin

        defaultData: _vcard.sipAddresses
        minValues: _contact ? 1 : 0
        placeholder: qsTr('sipAccountsInput')
        readOnly: !_edition
        title: qsTr('sipAccounts')

        onChanged: _handleSipAddressChanged(index, defaultValue, newValue)
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
        placeholder: qsTr('companiesInput')
        readOnly: !_edition
        title: qsTr('companies')

        onChanged: defaultValue.length === 0
          ? _vcard.addCompany(newValue)
          : _vcard.updateCompany(defaultValue, newValue)
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
        placeholder: qsTr('emailsInput')
        readOnly: !_edition
        title: qsTr('emails')

        onChanged: defaultValue.length === 0
          ? _vcard.addEmail(newValue)
          : _vcard.updateEmail(defaultValue, newValue)
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
        placeholder: qsTr('webSitesInput')
        readOnly: !_edition
        title: qsTr('webSites')

        onChanged: _handleUrlChanged(index, defaultValue, newValue)
        onRemoved: _vcard.removeUrl(value)
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: ContactEditStyle.values.separator.height
        color: ContactEditStyle.values.separator.color
      }

      // -----------------------------------------------------------------------
      // Edition buttons.
      // -----------------------------------------------------------------------

      Row {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: ContactEditStyle.buttons.topMargin
        spacing: ContactEditStyle.buttons.spacing
        visible: _edition

        TextButtonB {
          enabled: _vcard.sipAddresses.length > 0
          text: qsTr('save')
          onClicked: _save()
        }

        TextButtonA {
          text: qsTr('cancel')
          onClicked: _cancel()
        }
      }

      Item {
        Layout.bottomMargin: ContactEditStyle.values.bottomMargin
      }
    }
  }
}
