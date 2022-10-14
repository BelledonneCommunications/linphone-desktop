import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================
Rectangle{
  id: zrtp
  property var call
  property alias localSas: localSasText.text
  property alias remoteSas : remoteSasText.text
  
  signal close()
  color:"transparent"
  
  implicitWidth: columnLayout.implicitWidth
  implicitHeight: columnLayout.implicitHeight+CallStyle.container.margins
  
  radius: 10
  Component.onCompleted: if( !localSas || !remoteSas) zrtp.close()
    
  ColumnLayout {
    id:columnLayout
  // ---------------------------------------------------------------------------

    Layout.fillWidth: true
    anchors.bottom: parent.bottom
    
    Icon{
		Layout.alignment: Qt.AlignHCenter
		Layout.bottomMargin: 5
		visible: SettingsModel.isPostQuantumAvailable
		icon: CallStyle.zrtpArea.pqIcon
		iconSize: CallStyle.zrtpArea.iconSize
	}

  // ---------------------------------------------------------------------------
  // Main text.
  // ---------------------------------------------------------------------------

    Text {
      Layout.fillWidth: true

      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      text: qsTr('confirmSas')

      color: CallStyle.zrtpArea.text.colorA
      elide: Text.ElideRight

      font {
        bold: true
        pointSize: CallStyle.zrtpArea.text.pointSize
      }
    }

  // ---------------------------------------------------------------------------
  // Rules.
  // ---------------------------------------------------------------------------

    Row {
      Layout.alignment: Qt.AlignHCenter

      spacing: CallStyle.zrtpArea.text.wordsSpacing

      Text {
        color: CallStyle.zrtpArea.text.colorA
        font.pointSize: CallStyle.zrtpArea.text.pointSize
        text: qsTr('codeA')
      }

      Text {
		id: localSasText
        color: CallStyle.zrtpArea.text.colorB

        font {
          bold: true
          pointSize: CallStyle.zrtpArea.text.pointSize
        }

        text: zrtp.call?zrtp.call.localSas:''
      }

      Text {
        color: CallStyle.zrtpArea.text.colorA
        font.pointSize: CallStyle.zrtpArea.text.pointSize
        text: '-'
      }

      Text {
        color: CallStyle.zrtpArea.text.colorA
        font.pointSize: CallStyle.zrtpArea.text.pointSize
        text: qsTr('codeB')
      }

      Text {
		id: remoteSasText
        color: CallStyle.zrtpArea.text.colorB

        font {
          bold: true
          pointSize: CallStyle.zrtpArea.text.pointSize
        }

        text: zrtp.call?zrtp.call.remoteSas:''
      }
    }

  // ---------------------------------------------------------------------------
  // Buttons.
  // ---------------------------------------------------------------------------

    Row {
      Layout.alignment: Qt.AlignHCenter

      spacing: CallStyle.zrtpArea.buttons.spacing

      TextButtonA {
        text: qsTr('deny')
        onClicked: {
          zrtp.call.verifyAuthenticationToken(false)
          zrtp.close()
        }
      }

      TextButtonB {
        text: qsTr('accept')
        onClicked: {
          zrtp.call.verifyAuthenticationToken(true)
          zrtp.close()
        }
      }
    }
  }
}
