import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

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
      spacing: 5

      TextButtonB {
        text: qsTr('cleanLogs')

        onClicked: CoreManager.cleanLogs()
      }

      TextButtonB {
        enabled: !sendLogsBlock.loading
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

        onLogsUploaded: sendLogsBlock.stop(success ? '' : qsTr('logsUploadFailed'))
      }
    }

    // -------------------------------------------------------------------------
    // Internal settings.
    // -------------------------------------------------------------------------

    // Nothing for the moment.
  }
}
