import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Popup {
  id: callStatistics

  property var call

  // ---------------------------------------------------------------------------

  Rectangle {
    color: CallStatisticsStyle.color
    height: CallStatisticsStyle.height
    width: callStatistics.width

    Row {
      anchors {
        fill: parent
        topMargin: CallStatisticsStyle.topMargin
        leftMargin: CallStatisticsStyle.leftMargin
        rightMargin: CallStatisticsStyle.rightMargin
      }

      Loader {
        property string $label: qsTr('audioStatsLabel')
        property var $data: callStatistics.call.audioStats

        sourceComponent: media
        width: parent.width / 2
      }

      Loader {
        property string $label: qsTr('videoStatsLabel')
        property var $data: callStatistics.call.videoStats

        sourceComponent: media
        width: parent.width / 2
      }
    }

    // -------------------------------------------------------------------------
    // Line.
    // -------------------------------------------------------------------------

    Component {
      id: line

      RowLayout {
        spacing: CallStatisticsStyle.spacing
        width: parent.width

        Text {
          Layout.preferredWidth: CallStatisticsStyle.key.width

          color: CallStatisticsStyle.key.color
          elide: Text.ElideRight

          font {
            pointSize: CallStatisticsStyle.key.pointSize
            bold: true
          }

          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter

          text: modelData.key
        }

        Text {
          Layout.fillWidth: true

          color: CallStatisticsStyle.value.color
          elide: Text.ElideRight
          font.pointSize: CallStatisticsStyle.value.pointSize

          text: modelData.value
        }
      }
    }

    // -------------------------------------------------------------------------
    // Media.
    // -------------------------------------------------------------------------

    Component {
      id: media

      Column {
        Text {
          color: CallStatisticsStyle.title.color

          font {
            bold: true
            pointSize: CallStatisticsStyle.title.pointSize
          }

          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
          text: $label

          height: contentHeight + CallStatisticsStyle.title.bottomMargin
          width: parent.width
        }

        Repeater {
          model: $data
          delegate: line
        }
      }
    }
  }
}
