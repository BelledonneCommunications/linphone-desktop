import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
  id: callControls

  // ---------------------------------------------------------------------------

  property alias signIcon: signIcon.icon
  property alias textColor: text.color

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  color: CallControlsStyle.color
  height: CallControlsStyle.height

  MouseArea {
    anchors.fill: parent

    onClicked: callControls.clicked()
  }

  Icon {
    id: signIcon

    anchors {
      left: parent.left
      top: parent.top
    }

    iconSize: CallControlsStyle.signSize
  }

  RowLayout {
    anchors {
      fill: parent
      leftMargin: CallControlsStyle.leftMargin
      rightMargin: CallControlsStyle.rightMargin
    }

    spacing: 0

    Text {
      id: text

      Layout.fillHeight: true
      Layout.fillWidth: true

      text: qsTr('conference')
    }
  }
}
