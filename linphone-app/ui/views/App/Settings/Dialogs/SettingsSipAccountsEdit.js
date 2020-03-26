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

var proxyConfig

function initForm (account) {
  var AccountSettingsModel = Linphone.AccountSettingsModel

  proxyConfig = account
    ? account.proxyConfig
    : AccountSettingsModel.createProxyConfig()

  var config = AccountSettingsModel.getProxyConfigDescription(proxyConfig)

  sipAddress.text = config.sipAddress
  serverAddress.text = config.serverAddress
  registrationDuration.text = config.registrationDuration

  var currentTransport = config.transport.toUpperCase()
  transport.currentIndex = Number(
    Utils.findIndex(transport.model, function (value) {
      return value === currentTransport
    })
  )

  route.text = config.route
  contactParams.text = config.contactParams
  avpfInterval.text = config.avpfInterval
  registerEnabled.checked = config.registerEnabled
  publishPresence.checked = config.publishPresence
  avpfEnabled.checked = config.avpfEnabled
  iceEnabled.checked = config.iceEnabled
  turnEnabled.checked = config.turnEnabled
  stunServer.text = config.stunServer
  turnPassword.text = config.turnPassword
  turnUser.text = config.turnUser

  if (account) {
    dialog._sipAddressOk = true
    dialog._serverAddressOk = true
  }

  dialog._routeOk = true
}

function formIsValid () {
  return dialog._sipAddressOk && dialog._serverAddressOk && dialog._routeOk
}

// -----------------------------------------------------------------------------

function validProxyConfig () {
  if (Linphone.AccountSettingsModel.addOrUpdateProxyConfig(proxyConfig, {
    sipAddress: sipAddress.text,
    serverAddress: serverAddress.text,
    registrationDuration: registrationDuration.text,
    transport: transport.currentText,
    route: route.text,
    contactParams: contactParams.text,
    avpfInterval: avpfInterval.text,
    registerEnabled: registerEnabled.checked,
    publishPresence: publishPresence.checked,
    avpfEnabled: avpfEnabled.checked,
    iceEnabled: iceEnabled.checked,
    turnEnabled: turnEnabled.checked,
    stunServer: stunServer.text,
    turnUser: turnUser.text,
    turnPassword: turnPassword.text
  })) {
    dialog.exit(1)
  } else {
    // TODO: Display errors on the form (if necessary).
  }
}

// -----------------------------------------------------------------------------

function handleRouteChanged (route) {
  dialog._routeOk = route.length === 0 || Linphone.SipAddressesModel.addressIsValid(route)
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
