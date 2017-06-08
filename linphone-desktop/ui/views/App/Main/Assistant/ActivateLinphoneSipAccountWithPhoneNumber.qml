import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  property var assistantModel

  backEnabled: false

  title: qsTr('activateLinphoneSipAccount')

  mainAction: requestBlock.execute
  mainActionEnabled: activationCode.length === 4 && !requestBlock.loading
  mainActionLabel: qsTr('confirmAction')

  Column {
    anchors.centerIn: parent
    spacing: ActivateLinphoneSipAccountWithPhoneNumberStyle.spacing
    width: parent.width

    Text {
      color: ActivateLinphoneSipAccountWithPhoneNumberStyle.activationSteps.color
      font.pointSize: ActivateLinphoneSipAccountWithPhoneNumberStyle.activationSteps.pointSize
      horizontalAlignment: Text.AlignHCenter
      text: qsTr('activationSteps').replace('%1', assistantModel.phoneNumber)
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
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  Connections {
    target: assistantModel

    onActivateStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        window.unlockView()
        window.setView('Home')
      }
    }
  }
}
