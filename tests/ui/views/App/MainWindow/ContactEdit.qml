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
  property var _vcard

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
    _vcard.avatar = path.match(/^(?:file:\/\/)?(.*)$/)[1]
  }

  function _setUsername (username) {
    _vcard.username = username

    // Update current text with new username.
    usernameInput.text = _vcard.username
  }

  function _handleSipAddressChanged (index, default_value, new_value) {
    if (!Utils.startsWith(new_value, 'sip:')) {
      new_value = 'sip:' + new_value

      if (new_value === default_value) {
        return
      }
    }

    var so_far_so_good = (default_value.length === 0)
      ? _vcard.addSipAddress(new_value)
      : _vcard.updateSipAddress(default_value, new_value)

    addresses.setInvalid(index, !so_far_so_good)
  }

  function _handleUrlChanged (index, default_value, new_value) {
    var url = Utils.extractFirstUri(new_value)
    if (url === default_value) {
      return
    }

    var so_far_so_good = (default_value.length === 0)
      ? url && _vcard.addUrl(new_value)
      : url && _vcard.updateUrl(default_value, new_value)

    urls.setInvalid(index, !so_far_so_good)
  }

  // -----------------------------------------------------------------

  spacing: 0

  Component.onCompleted: {
    _contact = ContactsListModel.mapSipAddressToContact(sipAddress)
    _vcard = _contact.vcard
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
          image: _vcard.avatar
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
        visible: _contact != null

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

      ListForm {
        id: addresses

        Layout.leftMargin: ContactEditStyle.values.leftMargin
        Layout.rightMargin: ContactEditStyle.values.rightMargin
        Layout.topMargin: ContactEditStyle.values.topMargin

      defaultData: _vcard.sipAddresses
        minValues: 1
        placeholder: qsTr('sipAccountsInput')
        title: qsTr('sipAccounts')

        onChanged: _handleSipAddressChanged(index, default_value, new_value)
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
        title: qsTr('companies')

        onChanged: default_value.length === 0
          ? _vcard.addCompany(new_value)
          : _vcard.updateCompany(default_value, new_value)
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
        title: qsTr('emails')

        onChanged: default_value.length === 0
          ? _vcard.addEmail(new_value)
          : _vcard.updateEmail(default_value, new_value)
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
        title: qsTr('webSites')

        onChanged: _handleUrlChanged(index, default_value, new_value)
        onRemoved: _vcard.removeUrl(value)
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
