import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

// =============================================================================

ColumnLayout {
  property alias model: view.model

  // ---------------------------------------------------------------------------

  height: 350

  // ---------------------------------------------------------------------------
  // Header.
  // ---------------------------------------------------------------------------

  Row {
    Layout.fillWidth: true
    height: 50
  }

  // ---------------------------------------------------------------------------
  // Codecs.
  // ---------------------------------------------------------------------------

  ScrollableListView {
    id: view

    Layout.fillWidth: true
    Layout.fillHeight: true

    delegate: Rectangle {
      color: 'red'
      height: 30
      width: view.width

      Row {
        anchors.fill: parent

        Text {
          text: $codec.mime
        }

        Text {
          text: $codec.description
        }

        Text {
          text: $codec.channels
        }

        Text {
          text: $codec.bitrate
        }
      }
    }
  }
}
