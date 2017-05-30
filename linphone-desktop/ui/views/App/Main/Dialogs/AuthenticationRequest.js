// =============================================================================
// `AuthenticationRequest.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

function confirmPassword () {
  Linphone.AccountSettingsModel.addAuthInfo(dialog.authInfo, password.text, userId.text)
}
