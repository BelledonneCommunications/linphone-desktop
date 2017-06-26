// =============================================================================
// Contains linphone helpers.
// =============================================================================

.pragma library

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

// Returns the username of a contact/sipAddressObserver object or URI string.
function getContactUsername (contact) {
  var object = contact.contact || // Contact object from `SipAddressObserver`.
    (contact.vcard && contact) || // Contact object.
    (contact.sipAddress) || // String from `SipAddressObserver`.
    contact // String.

  if (Utils.isString(object)) {
    var index = object.indexOf('@')
    return object.substring(4, index !== -1 ? index : undefined) // 4 = length('sip:')
  }

  return object.vcard.username
}
