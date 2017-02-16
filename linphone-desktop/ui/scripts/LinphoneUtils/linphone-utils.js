// =============================================================================
// Contains linphone helpers.
// =============================================================================

.pragma library

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// Returns the username of a contact object or URI string.
function getContactUsername (contact) {
  return Utils.isString(contact)
    ? contact.substring(4, contact.indexOf('@')) // 4 = length('sip:')
    : contact.vcard.username
}
