// =============================================================================
// Contains linphone helpers.
// =============================================================================

.pragma library

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

// Returns the username of a contact/sipAddressObserver object or URI string.
function getContactUsername (contact) {
  var object = contact.contact || // Contact object from `SipAddressObserver`.
    (contact.vcard && contact) // Contact object.

  if (object) {
    return object.vcard.username
  }

  object = Utils.isString(contact.sipAddress)
    ? contact.sipAddress // String from `SipAddressObserver`.
    : contact // Just a String.

  var index = object.indexOf('@')
  return object.substring(4, index !== -1 ? index : undefined) // 4 = length('sip:')
}
