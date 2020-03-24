import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  id: dialog

  buttons: [
    TextButtonB {
      text: qsTr('confirm')

      onClicked: exit(1)
    }
  ]

  centeredButtons: true
  height: SettingsVideoPreviewStyle.height
  width: SettingsVideoPreviewStyle.width

  // ---------------------------------------------------------------------------

  CameraPreview {
    anchors.fill: parent
  }
}
