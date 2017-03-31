// =============================================================================
// `SettingsSipAccounts.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function initForm (account) {
  if (!account) {
    return
  }

  var config = Linphone.AccountSettingsModel.getProxyConfigDescription(account.proxyConfig)

  sipAddress.text = config.sipAddress
  serverAddress.text = config.serverAddress
  registrationDuration.text = config.registrationDuration

  var currentTransport = config.transport.toUpperCase()
  transport.currentIndex = Utils.findIndex(transport.model, function (value) {
    return value === currentTransport
  })

  route.text = config.route
  contactParams.text = config.contactParams
  avpfInterval.text = config.avpfInterval
  registerEnabled.checked = config.registerEnabled
  publishPresence.checked = config.publishPresence
  avpfEnabled.checked = config.avpfEnabled
}
