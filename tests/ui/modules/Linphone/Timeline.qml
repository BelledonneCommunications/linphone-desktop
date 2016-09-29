import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone.Styles 1.0

// ===================================================================

ColumnLayout {
  property alias model: view.model

  // Legend.
  Row {
    Layout.bottomMargin: TimelineStyle.legend.bottomMargin
    Layout.leftMargin: TimelineStyle.legend.leftMargin
    Layout.topMargin: TimelineStyle.legend.topMargin
    spacing: TimelineStyle.legend.spacing

    Icon {
      icon: 'history'
      iconSize: TimelineStyle.legend.iconSize
    }

    Text {
      color: TimelineStyle.legend.color
      font.pointSize: TimelineStyle.legend.fontSize
      height: parent.height
      text: qsTr('timelineTitle')
      verticalAlignment: Text.AlignVCenter
    }
  }

  // Separator.
  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: TimelineStyle.separator.height
    color: TimelineStyle.separator.color
  }

  // History.
  ScrollableListView {
    id: view

    Layout.fillHeight: true
    Layout.fillWidth: true

    delegate: Contact {
      presence: $presence
      sipAddress: $sipAddress
      username: $username
      width: parent.width
    }
  }
}
