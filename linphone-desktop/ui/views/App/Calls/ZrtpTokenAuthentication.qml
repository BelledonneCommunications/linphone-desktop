import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
  id: zrtp

  // ---------------------------------------------------------------------------

  property var call

  // ---------------------------------------------------------------------------

  visible: false

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
      pointSize: CallStyle.zrtpArea.text.fontSize
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
      font.pointSize: CallStyle.zrtpArea.text.fontSize
      text: qsTr('codeA')
    }

    Text {
      color: CallStyle.zrtpArea.text.colorB

      font {
        bold: true
        pointSize: CallStyle.zrtpArea.text.fontSize
      }

      text: zrtp.call.localSas
    }

    Text {
      color: CallStyle.zrtpArea.text.colorA
      font.pointSize: CallStyle.zrtpArea.text.fontSize
      text: '-'
    }

    Text {
      color: CallStyle.zrtpArea.text.colorA
      font.pointSize: CallStyle.zrtpArea.text.fontSize
      text: qsTr('codeB')
    }

    Text {
      color: CallStyle.zrtpArea.text.colorB

      font {
        bold: true
        pointSize: CallStyle.zrtpArea.text.fontSize
      }

      text: zrtp.call.remoteSas
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
        zrtp.visible = false
        zrtp.call.verifyAuthenticationToken(false)
      }
    }

    TextButtonB {
      text: qsTr('accept')
      onClicked: {
        zrtp.visible = false
        zrtp.call.verifyAuthenticationToken(true)
      }
    }
  }
}
