// =============================================================================
// Contains linphone helpers.
// =============================================================================

.pragma library

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function _getDisplayNameFromQuotedString (str) {
  var start = str.indexOf('"')
  if (start === -1) {
    return
  }

  var end = str.lastIndexOf('"')
  if (end === -1 || start === end) {
    return
  }

  return str.substring(start + 1, end)
}

function _getDisplayNameFromString  (str) {
  var end = str.indexOf('<')
  if (end === -1) {
    return
  }

  return str.substring(0, end).trim()
}

function _getDisplayName (str) {
  var name = _getDisplayNameFromQuotedString(str)
  if (name != null) {
    return name
  }

  return _getDisplayNameFromString (str)
}

// -----------------------------------------------------------------------------

function _getUsername (str) {
  var start = str.indexOf('sip')
  if (start === -1) {
    return
  }
  start += 4 + Number(str.charAt(start + 4) === ':') // Deal with `sip:` and `sips:`

  var end = str.indexOf('@', start + 1)
  if (end === -1) {
    return
  }

  return str.substring(start, end)
}

// -----------------------------------------------------------------------------

// Returns the username of a contact/sipAddressObserver object or URI string.
function getContactUsername (contact) {
  var object = contact.contact || // Contact object from `SipAddressObserver`.
    (contact.vcard && contact) // Contact object.

  // 1. `object` is a contact.
  if (object) {
    return object.vcard.username
  }

  // 2. `object` is just a string.
  object = Utils.isString(contact.sipAddress)
    ? contact.sipAddress // String from `SipAddressObserver`.
    : contact // Just a String.

  // Use display name.
  var name = _getDisplayName(object)
  if (name != null) {
    return name
  }

  // Use username.
  name = _getUsername(object)
  return name == null ? 'Bad EGG' : name
}

function cleanSipAddress (sipAddress) {
  var index = sipAddress.indexOf('<')
  return index === -1
    ? sipAddress
    : sipAddress.substring(index + 1, sipAddress.lastIndexOf('>'))
}
