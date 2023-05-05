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
// `SettingsSipAccounts.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

var gAccount

function initForm (account) {
  var AccountSettingsModel = Linphone.AccountSettingsModel

  gAccount = account
    ? account.account
    : AccountSettingsModel.createAccount('create-app-sip-account.rc')

  var config = AccountSettingsModel.getAccountDescription(gAccount)

  sipAddress.text = config.sipAddress
  serverAddress.text = config.serverAddress
  registrationDuration.text = config.registrationDuration
  publishDuration.text = config.publishDuration

  var currentTransport = config.transport.toUpperCase()
  transport.currentIndex = Number(
    Utils.findIndex(transport.model, function (value) {
      return value === currentTransport
    })
  )

  route.text = config.route
  conferenceUri.text = config.conferenceUri
  videoConferenceUri.text = config.videoConferenceUri
  limeServerUrl.text = config.limeServerUrl
  contactParams.text = config.contactParams
  avpfInterval.text = config.avpfInterval
  registerEnabled.checked = config.registerEnabled
  publishPresence.checked = config.publishPresence
  avpfEnabled.checked = config.avpfEnabled
  
  dialPrefixCallChat.checked = config.dialPrefixCallChat
  dialPrefix.text = config.dialPrefix
  dialEscapePlus.checked = config.dialEscapePlus
  
  iceEnabled.checked = config.iceEnabled
  turnEnabled.checked = config.turnEnabled
  stunServer.text = config.stunServer
  turnPassword.text = config.turnPassword
  turnUser.text = config.turnUser
  
  rtpBundleEnabled.checked = config.rtpBundleEnabled  

  if (account) {
    dialog._sipAddressOk = true
    dialog._serverAddressOk = true
  }

  dialog._routeOk = true
}

function formIsValid () {
  return dialog._sipAddressOk && dialog._serverAddressOk && dialog._routeOk && dialog._conferenceUriOk && dialog._videoConferenceUriOk && dialog._limeServerUrlOk
}

// -----------------------------------------------------------------------------

function validAccount (account) {
	var data = {
		sipAddress: sipAddress.text,
		serverAddress: serverAddress.text,
		registrationDuration: registrationDuration.text,
		publishDuration: publishDuration.text,
		transport: transport.currentText,
		route: route.text,
		conferenceUri: conferenceUri.text,
		videoConferenceUri: videoConferenceUri.text,
		limeServerUrl: limeServerUrl.text,
		contactParams: contactParams.text,
		avpfInterval: avpfInterval.text,
		registerEnabled: registerEnabled.checked,
		publishPresence: publishPresence.checked,
		avpfEnabled: avpfEnabled.checked,
		dialPrefix: dialPrefix.text,
		dialPrefixCallChat: dialPrefixCallChat.checked,
		dialEscapePlus: dialEscapePlus.checked,
		iceEnabled: iceEnabled.checked,
		turnEnabled: turnEnabled.checked,
		stunServer: stunServer.text,
		turnUser: turnUser.text,
		turnPassword: turnPassword.text,
		rtpBundleEnabled: rtpBundleEnabled.checked
	  }
	  
  if (gAccount && Linphone.AccountSettingsModel.addOrUpdateAccount(gAccount, data)
		|| !account && Linphone.AccountSettingsModel.addOrUpdateAccount(data)) {
    dialog.exit(1)
  } else {
    // TODO: Display errors on the form (if necessary).
  }
}

// -----------------------------------------------------------------------------

function handleRouteChanged (route) {
  dialog._routeOk = route.length === 0 || Linphone.SipAddressesModel.addressIsValid(route)
}
function handleConferenceUriChanged (uri) {
  dialog._conferenceUriOk = uri=='' || Linphone.SipAddressesModel.addressIsValid(uri)	
}

function handleVideoConferenceUriChanged (uri) {
  dialog._videoConferenceUriOk = uri=='' || Linphone.SipAddressesModel.addressIsValid(uri)	
}

function handleServerAddressChanged (address) {
  if (address.length === 0) {
    dialog._serverAddressOk = false
    return
  }

  var newTransport = Linphone.SipAddressesModel.getTransportFromSipAddress(address)

  if (newTransport.length > 0) {
    transport.currentIndex = Utils.findIndex(transport.model, function (value) {
      return value === newTransport
    })
    dialog._serverAddressOk = true
  } else {
    dialog._serverAddressOk = false
  }
}

function handleSipAddressChanged (address) {
  dialog._sipAddressOk = address.length > 0 &&
    Linphone.SipAddressesModel.sipAddressIsValid(address)
}

function handleTransportChanged (transport) {
  var newServerAddress = Linphone.SipAddressesModel.addTransportToSipAddress(serverAddress.text, transport)
  if (newServerAddress.length > 0) {
    serverAddress.text = newServerAddress
    dialog._serverAddressOk = true
  } else {
    dialog._serverAddressOk = false
  }
}

// -----------------------------------------------------------------------------
