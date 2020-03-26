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

function editAccount (account) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/SettingsSipAccountsEdit.qml'), {
    account: account
  })
}

function deleteAccount (account) {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('deleteAccountDescription'),
  }, function (status) {
    if (status) {
      Linphone.AccountSettingsModel.removeProxyConfig(account.proxyConfig)
    }
  })
}

function eraseAllPasswords () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('eraseAllPasswordsDescription'),
  }, function (status) {
    if (status) {
      Linphone.AccountSettingsModel.eraseAllPasswords()
    }
  })
}
