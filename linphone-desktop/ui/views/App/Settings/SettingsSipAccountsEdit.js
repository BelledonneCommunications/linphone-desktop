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
}

function handleServerAddressChanged (address) {
  var newTransport = Linphone.AccountSettingsModel.getTransportFromServerAddress(address)
  if (newTransport.length > 0) {
    transport.currentIndex = Utils.findIndex(transport.model, function (value) {
      return value === newTransport
    })
  }
}

function validProxyConfig () {
  // TODO: Display errors on the form (if necessary).
  Linphone.AccountSettingsModel.addOrUpdateProxyConfig(proxyConfig, {
    sipAddress: sipAddress.text,
    serverAddress: serverAddress.text,
    registrationDuration: registrationDuration.text,
    transport: transport.currentText,
    route: route.text,
    contactParams: contactParams.text,
    avpfInterval: avpfInterval.text,
    registerEnabled: registerEnabled.checked,
    publishPresence: publishPresence.checked,
    avpfEnabled: avpfEnabled.checked
  })
}
