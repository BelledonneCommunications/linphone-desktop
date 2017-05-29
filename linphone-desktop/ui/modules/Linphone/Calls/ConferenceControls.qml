import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
  id: callControls

  // ---------------------------------------------------------------------------

  property alias textColor: text.color

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  color: ConferenceControlsStyle.color
  height: ConferenceControlsStyle.height

  MouseArea {
    anchors.fill: parent

    onClicked: callControls.clicked()
  }

  RowLayout {
    anchors {
      fill: parent
      leftMargin: ConferenceControlsStyle.leftMargin
      rightMargin: ConferenceControlsStyle.rightMargin
    }

    spacing: 0

    Text {
      id: text

      Layout.fillHeight: true
      Layout.fillWidth: true

      font.bold: true
      text: qsTr('conference')

      verticalAlignment: Text.AlignVCenter
    }
  }
}
