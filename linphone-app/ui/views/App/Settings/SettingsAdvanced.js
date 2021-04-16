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
// `SettingsAdvanced.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function editLdap (ldap) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/SettingsLdapEdit.qml'), {
    ldapData: ldap
  })
}

function cleanLogs () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('cleanLogsDescription'),
  }, function (status) {
    if (status) {
      Linphone.CoreManager.cleanLogs()
    }
  })
}

function handleLogsUploaded (url) {
  if (url.length && Utils.startsWith(url, 'http')) {

    if(Qt.openUrlExternally(
          'mailto:' + encodeURIComponent(Linphone.SettingsModel.logsEmail) +
          '?subject=' + encodeURIComponent('Desktop Linphone Log') +
          '&body=' + encodeURIComponent(url)
        ))
        sendLogsBlock.stop(qsTr('logsMailerSuccess').replace('%1', url))
    else
        sendLogsBlock.stop(qsTr('logsMailerFailed').replace('%1', url))
  } else {
    sendLogsBlock.stop(qsTr('logsUploadFailed'))
  }
}
