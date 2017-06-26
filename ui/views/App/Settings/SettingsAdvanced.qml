import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'SettingsAdvanced.js' as Logic

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Logs.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('logsTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('logsFolderLabel')

          FileChooserButton {
            selectedFile: SettingsModel.logsFolder
            selectFolder: true

            onAccepted: SettingsModel.logsFolder = selectedFile
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('logsUploadUrlLabel')

          TextField {
            readOnly: true
            text: SettingsModel.logsUploadUrl

            onEditingFinished: SettingsModel.logsUploadUrl = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('logsEnabledLabel')

          Switch {
            checked: SettingsModel.logsEnabled

            onClicked: SettingsModel.logsEnabled = !checked
          }
        }
      }

      FormEmptyLine {}
    }

    Row {
      anchors.right: parent.right
      spacing: SettingsAdvancedStyle.buttons.spacing

      TextButtonB {
        text: qsTr('cleanLogs')

        onClicked: Logic.cleanLogs()
      }

      TextButtonB {
        enabled: !sendLogsBlock.loading && SettingsModel.logsEnabled
        text: qsTr('sendLogs')

        onClicked: sendLogsBlock.execute()
      }
    }

    RequestBlock {
      id: sendLogsBlock

      action: CoreManager.sendLogs
      width: parent.width

      Connections {
        target: CoreManager

        onLogsUploaded: Logic.handleLogsUploaded(url)
      }
    }

    // -------------------------------------------------------------------------
    // Internal settings.
    // -------------------------------------------------------------------------

    // Nothing for the moment.
  }
}
