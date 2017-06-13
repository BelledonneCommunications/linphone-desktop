// =============================================================================
// `SettingsUi.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function cleanAvatars () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('cleanAvatarsDescription'),
  }, function (status) {
    if (status) {
      Linphone.ContactsListModel.cleanAvatars()
    }
  })
}

function getAvailableLocales () {
  var locales = []

  Linphone.App.availableLocales.forEach(function (locale) {
    locales.push({
      key: Utils.capitalizeFirstLetter(locale.nativeLanguageName),
      value: locale.name
    })
  })

  return [{
    key: qsTr('systemLocale'),
    value: ''
  }].concat(locales.sort(function (a, b) {
    return a > b
  }))
}

function setLocale (locale) {
  var App = Linphone.App
  App.configLocale = locale

  window.detachVirtualWindow()
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('setLocaleDescription'),
  }, function (status) {
    if (status) {
      App.restart()
    }
  })
}
