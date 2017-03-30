// =============================================================================
// `Conversation.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleCreation () {
  var sipAddress = contactEdit.sipAddress
  var contact = contactEdit._contact = Linphone.SipAddressesModel.mapSipAddressToContact(
    sipAddress
  )

  if (!contact) {
    var vcard = Linphone.CoreManager.createDetachedVcardModel()
    contactEdit._vcard = vcard

    if (sipAddress && sipAddress.length > 0) {
      vcard.addSipAddress(sipAddress)
    }

    contactEdit._edition = true
  } else {
    contactEdit._vcard = contact.vcard
  }
}

function handleDestruction () {
  var contact = contactEdit._contact

  if (contactEdit._edition && contact) {
    contact.abortEdit()
  }
}

// -----------------------------------------------------------------------------

function editContact () {
  contactEdit._contact.startEdit()
  contactEdit._edition = true

  window.lockView({
    descriptionText: qsTr('abortEditionDescriptionText')
  })
}

function removeContact () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('removeContactDescription'),
  }, function (status) {
    if (status) {
      window.unlockView()
      window.setView('Contacts')
      Linphone.ContactsListModel.removeContact(_contact)
    }
  })
}

// -----------------------------------------------------------------------------

function save () {
  var contact = contactEdit._contact

  if (contact) {
    contact.endEdit()
    window.unlockView()
  } else {
    contactEdit._contact = Linphone.ContactsListModel.addContact(contactEdit._vcard)
  }

  contactEdit._edition = false
}

function cancel () {
  var contact = contactEdit._contact

  if (contact) {
    contact.abortEdit()
    contactEdit._edition = false
    window.unlockView()
  } else {
    window.setView('Contacts')
  }
}

// -----------------------------------------------------------------------------

function setAvatar (path) {
  contactEdit._vcard.avatar = path.match(/^(?:file:\/\/)?(.*)$/)[1]
}

function setUsername (username) {
  var vcard = contactEdit._vcard

  vcard.username = username

  // Update current text with new/old username.
  usernameInput.text = _vcard.username
}

// -----------------------------------------------------------------------------

function handleSipAddressChanged (sipAddresses, index, defaultValue, newValue) {
  if (newValue === defaultValue) {
    return
  }

  var vcard = contactEdit._vcard
  var soFarSoGood = (defaultValue.length === 0)
    ? vcard.addSipAddress(newValue)
    : vcard.updateSipAddress(defaultValue, newValue)

  sipAddresses.setInvalid(index, !soFarSoGood)
}

function handleCompanyChanged (companies, index, defaultValue, newValue) {
  var vcard = contactEdit._vcard
  var soFarSoGood = (defaultValue.length === 0)
    ? vcard.addCompany(newValue)
    : vcard.updateCompany(defaultValue, newValue)

  companies.setInvalid(index, !soFarSoGood)
}

function handleEmailChanged (emails, index, defaultValue, newValue) {
  var vcard = contactEdit._vcard
  var soFarSoGood = (defaultValue.length === 0)
    ? vcard.addEmail(newValue)
    : vcard.updateEmail(defaultValue, newValue)

  emails.setInvalid(index, !soFarSoGood)
}

function handleUrlChanged (urls, index, defaultValue, newValue) {
  var url = Utils.extractFirstUri(newValue)
  if (url === defaultValue) {
    return
  }

  var vcard = contactEdit._vcard
  var soFarSoGood = url && (
    defaultValue.length === 0
      ? vcard.addUrl(newValue)
      : vcard.updateUrl(defaultValue, newValue)
  )

  urls.setInvalid(index, !soFarSoGood)
}

// -----------------------------------------------------------------------------

function buildAddressFields () {
  var address = contactEdit._vcard.address

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

function handleAddressChanged (index, value) {
  var vcard = contactEdit._vcard

  if (index === 0) { // Street.
    vcard.setStreet(value)
  } else if (index === 1) { // Locality.
    vcard.setLocality(value)
  } else if (index === 2) { // Postal code.
    vcard.setPostalCode(value)
  } else if (index === 3) { // Country.
    vcard.setCountry(value)
  }
}
