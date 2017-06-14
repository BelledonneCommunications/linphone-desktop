// =============================================================================
// `Conversation.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleContactUpdated () {
  var contact = contactEdit._contact

  if (!contactEdit._edition) {
    var vcard = contact.vcard

    if (contactEdit._vcard !== vcard) {
      // Not in edition mode, the contact was updated in other place.
      contactEdit._vcard = vcard
    } else {
      // Edition ended.
      handleVcardChanged(contact.vcard)
    }
  } else {
    // Edition not ended, the contact was updated in other place.
    // Update fields with new data.
    contactEdit._vcard = contact.cloneVcardModel()
  }
}

function handleCreation () {
  var sipAddress = contactEdit.sipAddress
  var contact = contactEdit._contact = Linphone.SipAddressesModel.mapSipAddressToContact(
    sipAddress
  )

  if (!contact) {
    // Add a new contact.
    var vcard = Linphone.CoreManager.createDetachedVcardModel()

    if (sipAddress && sipAddress.length > 0) {
      vcard.addSipAddress(sipAddress)
    }

    contactEdit._vcard = vcard
    contactEdit._edition = true
  } else {
    // See or edit a contact.
    contactEdit._vcard = contact.vcard
  }
}

function handleVcardChanged (vcard) {
  if (!vcard) {
    vcard = {}
  }

  addresses.setData(vcard.sipAddresses)
  companies.setData(vcard.companies)
  emails.setData(vcard.emails)
  urls.setData(vcard.urls)
}

// -----------------------------------------------------------------------------

function editContact () {
  var contact = contactEdit._contact

  contactEdit._vcard = contact.cloneVcardModel()
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
  var vcard = contactEdit._vcard

  contactEdit._edition = false

  if (contact) {
    contact.vcard = vcard
    window.unlockView()
  } else {
    contactEdit._contact = Linphone.ContactsListModel.addContact(vcard)
    handleVcardChanged(vcard) // Called directly, because the vcard is not modified in the view.
  }
}

function cancel () {
  var contact = contactEdit._contact

  if (contact) {
    contactEdit._vcard = contact.vcard
    window.unlockView()

    contactEdit._edition = false
  } else {
    window.setView('Contacts')
  }
}

// -----------------------------------------------------------------------------

function setAvatar (url) {
  contactEdit._vcard.avatar = Utils.getSystemPathFromUri(url)
}

function setUsername (username) {
  var vcard = contactEdit._vcard

  vcard.username = username

  // Update current text with new/old username.
  usernameInput.text = _vcard.username
}

// -----------------------------------------------------------------------------

function handleValueChanged (fields, index, oldValue, newValue, add, update) {
  if (newValue === oldValue) {
    return
  }

  var vcard = contactEdit._vcard
  var soFarSoGood = (oldValue.length === 0)
    ? vcard[add](newValue)
    : vcard[update](oldValue, newValue)

  fields.setInvalid(index, !soFarSoGood)
}

function handleSipAddressChanged () {
  var args = Array.prototype.slice.call(arguments)
  args.push('addSipAddress', 'updateSipAddress')
  handleValueChanged.apply(this, args)
}

function handleCompanyChanged () {
  var args = Array.prototype.slice.call(arguments)
  args.push('addCompany', 'updateCompany')
  handleValueChanged.apply(this, args)
}

function handleEmailChanged () {
  var args = Array.prototype.slice.call(arguments)
  args.push('addEmail', 'updateEmail')
  handleValueChanged.apply(this, args)
}

function handleUrlChanged () {
  var args = Array.prototype.slice.call(arguments)
  args.push('addUrl', 'updateUrl')
  handleValueChanged.apply(this, args)
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
