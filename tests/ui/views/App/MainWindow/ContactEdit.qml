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

  // ---------------------------------------------------------------------------

  spacing: 0

  Component.onCompleted: {
    _contact = SipAddressesModel.mapSipAddressToContact(sipAddress)

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
        enabled: _edition
        icon: 'contact_card_photo'
        iconSize: ContactEditStyle.infoBar.avatarSize

        onClicked: avatarChooser.open()

        Avatar {
          id: avatar

          anchors.fill: parent
          image: _vcard.avatar
          username: _vcard.username
          visible: isLoaded() && (!parent.hovered || !_edition)
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

  Loader {
    Layout.fillHeight: true
    Layout.fillWidth: true

    active: _vcard != null
    sourceComponent: Flickable {
      id: flick

      // -----------------------------------------------------------------------

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

      function _handleCompanyChanged (index, defaultValue, newValue) {
        var so_far_so_good = (defaultValue.length === 0)
          ? _vcard.addCompany(newValue)
          : _vcard.updateCompany(defaultValue, newValue)

          companies.setInvalid(index, !so_far_so_good)
      }

      function _handleEmailChanged (index, defaultValue, newValue) {
        var so_far_so_good = (defaultValue.length === 0)
          ? _vcard.addEmail(newValue)
          : _vcard.updateEmail(defaultValue, newValue)

          emails.setInvalid(index, !so_far_so_good)
      }

      function _handleUrlChanged (index, defaultValue, newValue) {
        var url = Utils.extractFirstUri(newValue)
        if (url === defaultValue) {
          return
        }

        var so_far_so_good = url && (
          defaultValue.length === 0
            ? _vcard.addUrl(newValue)
            : _vcard.updateUrl(defaultValue, newValue)
        )

        urls.setInvalid(index, !so_far_so_good)
      }

      function _handleAddressChanged (index, value) {
        if (index === 0) { // Street.
          _vcard.setStreet(value)
        } else if (index === 1) { // Locality.
          _vcard.setLocality(value)
        } else if (index === 2) { // Postal code.
          _vcard.setPostalCode(value)
        } else if (index === 3) { // Country.
          _vcard.setCountry(value)
        }
      }

      // -----------------------------------------------------------------------

      ScrollBar.vertical: ForceScrollBar {}

      boundsBehavior: Flickable.StopAtBounds
      clip: true
      contentHeight: infoList.height
      contentWidth: width - ScrollBar.vertical.width
      flickableDirection: Flickable.VerticalFlick

      SmartConnect {
        Component.onCompleted: this.connect(_vcard, 'onVcardUpdated', function () {
          addresses.setData(_vcard.sipAddresses)
          companies.setData(_vcard.companies)
          emails.setData(_vcard.emails)
          urls.setData(_vcard.urls)
        })
      }

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
          placeholder: qsTr('companiesPlaceholder')
          readOnly: !_edition
          title: qsTr('companies')

          onChanged: _handleCompanyChanged(index, defaultValue, newValue)
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

          onChanged: _handleEmailChanged(index, defaultValue, newValue)
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

          onChanged: _handleUrlChanged(index, defaultValue, newValue)
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

          fields: {
            var address = _vcard.address

            return [{
              placeholder: qsTr('street'),
              text: address.street
            }, {
              placeholder: qsTr('locality'),
              text: address.locality
            }, {
              placeholder: qsTr('postalCode'),
              text: address.postalCode
            }, {
              placeholder: qsTr('country'),
              text: address.country
            }]
          }

          readOnly: !_edition
          title: qsTr('address')

          onChanged: _handleAddressChanged(index, value)
        }

        // ---------------------------------------------------------------------
        // Edition buttons.
        // ---------------------------------------------------------------------

        Row {
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: ContactEditStyle.values.bottomMargin
          Layout.topMargin: ContactEditStyle.buttons.topMargin

          spacing: ContactEditStyle.buttons.spacing
          visible: _edition

          TextButtonA {
            text: qsTr('cancel')
            onClicked: _cancel()
          }

          TextButtonB {
            enabled: usernameInput.text.length > 0 && _vcard.sipAddresses.length > 0
            text: qsTr('save')
            onClicked: _save()
          }
        }
      }
    }
  }
}
