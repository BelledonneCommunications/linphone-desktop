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
            text: SettingsModel.logsUploadUrl

            onEditingFinished: SettingsModel.logsUploadUrl = text
          }
        }
      }

      FormEmptyLine {}
    }

    TextButtonB {
      anchors.right: parent.right
      text: qsTr('sendLogs')

      onClicked: CoreManager.sendLogs()
    }

    // -------------------------------------------------------------------------
    // Internal settings.
    // -------------------------------------------------------------------------

    // Nothing for the moment.
  }
}
