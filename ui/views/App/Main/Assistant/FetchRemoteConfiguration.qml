import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: requestBlock.execute
  mainActionEnabled: url.text.length > 0
  mainActionLabel: qsTr('confirmAction')

  title: qsTr('fetchRemoteConfigurationTitle')

  // ---------------------------------------------------------------------------

  Connections {
    target: SettingsModel

    onRemoteProvisioningChanged: {
      requestBlock.stop('')

      window.detachVirtualWindow()
      window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
        descriptionText: qsTr('remoteProvisioningUpdateDescription'),
      }, function (status) {
        if (status) {
          App.restart()
        } else {
          window.setView('Home')
        }
      })
    }

    onRemoteProvisioningNotChanged: requestBlock.stop(qsTr('remoteProvisioningError'))
  }

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    Form {
      orientation: Qt.Vertical
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('urlLabel')

          TextField {
            id: url
          }
        }
      }
    }

    RequestBlock {
      id: requestBlock

      action: (function () {
        SettingsModel.remoteProvisioning = url.text
      })

      width: parent.width
    }
  }
}
