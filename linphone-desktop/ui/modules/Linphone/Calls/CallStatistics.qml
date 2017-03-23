import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

AbstractDropDownMenu {
  id: callStatistics

  property var call

  // ---------------------------------------------------------------------------

  function _computeHeight () {
    return callStatistics.height
  }

  // ---------------------------------------------------------------------------

  Component {
    id: line

    RowLayout {
      spacing: CallStatisticsStyle.spacing

      // ---------------------------------------------------------------------------

      Text {
        Layout.preferredWidth: CallStatisticsStyle.key.width

        color: CallStatisticsStyle.key.color
        elide: Text.ElideRight
        font {
          pointSize: CallStatisticsStyle.key.fontSize
          bold: true
        }

        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter

        text: modelData.key
      }

      // ---------------------------------------------------------------------------

      Text {
        Layout.fillWidth: true
        color: CallStatisticsStyle.value.color
        elide: Text.ElideRight
        font.pointSize: CallStatisticsStyle.value.fontSize

        text: modelData.value
      }
    }
  }

  // ---------------------------------------------------------------------------

  Component {
    id: media

    Column {
      width: parent.width

      Text {
        width: parent.width
        color: CallStatisticsStyle.title.color
        font {
          bold: true
          pointSize: CallStatisticsStyle.title.fontSize
        }
        horizontalAlignment: Text.AlignHCenter
        text: $label
      }

      Repeater {
        model: $data
        delegate: line
      }
    }
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: CallStatisticsStyle.color

    Row {
      anchors {
        fill: parent
        leftMargin: CallStatisticsStyle.leftMargin
        rightMargin: CallStatisticsStyle.rightMargin
      }

      Loader {
        property string $label: qsTr("audioStatsLabel")
        property var $data: callStatistics.call.audioStats
        sourceComponent: media
        width: parent.width / 2
      }

      Loader {
        property string $label: qsTr("videoStatsLabel")
        property var $data: callStatistics.call.videoStats
        sourceComponent: media
        width: parent.width / 2
      }
    }
  }
}
