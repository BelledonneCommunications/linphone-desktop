// =============================================================================
// `ManageAccount.qml` Logic.
// =============================================================================

function getItemIcon (data) {
  var proxyConfig = data.proxyConfig
  if (!proxyConfig) {
    return ''
  }

  var description = AccountSettingsModel.getProxyConfigDescription(proxyConfig)
  return description.registerEnabled && description.registrationState !== AccountSettingsModel.RegistrationStateRegistered
    ? 'generic_error'
    : ''
}
