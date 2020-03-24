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
