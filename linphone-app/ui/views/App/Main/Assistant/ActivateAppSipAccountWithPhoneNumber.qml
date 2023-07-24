import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  property var assistantModel

  backEnabled: false

  title: qsTr('activateAppSipAccount').replace('%1', Qt.application.name.toUpperCase())

  mainAction: requestBlock.execute
  mainActionEnabled: activationCode.length === 4 && !requestBlock.loading
  mainActionLabel: qsTr('confirmAction')

  Column {
    anchors.centerIn: parent
    spacing: ActivateAppSipAccountWithPhoneNumberStyle.spacing
    width: parent.width - 10

    Text {
      color: ActivateAppSipAccountWithPhoneNumberStyle.activationSteps.colorModel.color
      font.pointSize: ActivateAppSipAccountWithPhoneNumberStyle.activationSteps.pointSize
      horizontalAlignment: Text.AlignHCenter
      text: qsTr('activationSteps').replace('%1', assistantModel.computedPhoneNumber)
      width: parent.width
      wrapMode: Text.WordWrap
    }

    TextField {
      id: activationCode

      anchors.horizontalCenter: parent.horizontalCenter
      validator: IntValidator {
        bottom: 0
        top: 9999
      }

      onTextChanged: assistantModel.activationCode = text
    }

    RequestBlock {
      id: requestBlock

      action: assistantModel.activate
      width: parent.width
      loading: assistantModel.isProcessing
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  Connections {
    target: assistantModel

    onActivateStatusChanged: {
      requestBlock.setText(error)
      if (!error.length) {
        function quitToHome (window) {
          window.unlockView()
          window.setView('Home')
        }
        var codecInfo = VideoCodecsModel.getCodecInfo('H264')
        if (codecInfo.downloadUrl) {
          Utils.openCodecOnlineInstallerDialog(window, codecInfo, quitToHome)
        } else {
          quitToHome(window)
        }
      }
    }
  }
}
