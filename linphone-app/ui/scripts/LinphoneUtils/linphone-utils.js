/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// =============================================================================
// Contains linphone helpers.
// =============================================================================

.pragma library

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
// Contact/SIP address helpers.
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

  return str.substring(0, end).trim() || undefined
}

function _getDisplayName (str) {
  var name = _getDisplayNameFromQuotedString(str)
  if (name != null) {
    return name
  }

  return _getDisplayNameFromString(str)
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
    return Utils.decode(str.substring(start))
  }

  return Utils.decode(str.substring(start, end))
}

// -----------------------------------------------------------------------------

// Returns the username of a contact/sipAddressObserver object or URI string.
function getContactUsername (contact) {
  if(contact){
      var object = contact.contact || // Contact object from `SipAddressObserver`.
        (contact.vcard && contact) // Contact object.
    
      // 1. `object` is a contact.
      if (object) {
        return object.vcard.username
      }
    
      // 2. `object` is just a string.
      object = Utils.isString(contact.peerAddress)
        ? contact.peerAddress // String from `SipAddressObserver`.
        : contact // Just a String.
    
      // Use display name.
      var name = _getDisplayName(object)
      if (name != null) {
        return name
      }
    
      // Use username.
      name = _getUsername(object)
      return name == null ? 'Bad EGG' : name
  }else
    return '';
}

// =============================================================================
// Codec helpers.
// =============================================================================

function openCodecOnlineInstallerDialog (window, codecInfo, cb) {
  var VideoCodecsModel = Linphone.VideoCodecsModel
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('downloadCodecDescription')
      .replace('%1', codecInfo.mime)
      .replace('%2', codecInfo.encoderDescription)
  }, function (status) {
    if (status) {
      window.attachVirtualWindow(buildDialogUri('OnlineInstallerDialog'), {
        downloadUrl: codecInfo.downloadUrl,
        extract: true,
        installFolder: VideoCodecsModel.codecsFolder,
        installName: codecInfo.installName,
        mime: codecInfo.mime
      }, function (status) {
        if (status) {
          VideoCodecsModel.reload()
        }
        if (cb) {
          cb(window)
        }
      })
    }
    else if (cb) {
      cb(window)
    }
  })
}

// =============================================================================
// QML helpers.
// =============================================================================

function buildDialogUri (component) {
  return 'qrc:/ui/modules/Linphone/Dialog/' + component + '.qml'
}
