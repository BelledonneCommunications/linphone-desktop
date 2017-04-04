import QtQml.Models 2.2
import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Column {
  property alias model: visualModel.model

  // ---------------------------------------------------------------------------
  // Header.
  // ---------------------------------------------------------------------------

  Row {
    anchors {
      left: parent.left
      leftMargin: CodecsViewerStyle.leftMargin
      right: parent.right
    }

    height: CodecsViewerStyle.legend.height
    spacing: CodecsViewerStyle.column.spacing

    CodecLegend {
      Layout.preferredWidth: CodecsViewerStyle.column.mimeWidth
      text: qsTr('codecMime')
    }

    CodecLegend {
      Layout.preferredWidth: CodecsViewerStyle.column.encoderDescriptionWidth
      text: qsTr('codecEncoderDescription')
    }

    CodecLegend {
      Layout.preferredWidth: CodecsViewerStyle.column.clockRateWidth
      text: qsTr('codecEncoderClockRate')
    }

    CodecLegend {
      Layout.preferredWidth: CodecsViewerStyle.column.bitrateWidth
      text: qsTr('codecBitrate')
    }

    CodecLegend {
      Layout.preferredWidth: CodecsViewerStyle.column.recvFmtpWidth
      text: qsTr('codecRecvFmtp')
    }

    CodecLegend {
      text: qsTr('codecStatus')
    }
  }

  // ---------------------------------------------------------------------------
  // Codecs.
  // ---------------------------------------------------------------------------

  ListView {
    id: view

    boundsBehavior: Flickable.StopAtBounds
    clip: true
    spacing: 0

    anchors {
      left: parent.left
      leftMargin: CodecsViewerStyle.leftMargin
      right: parent.right
    }

    height: count * CodecsViewerStyle.attribute.height

    model: DelegateModel {
      id: visualModel

      delegate: MouseArea {
        id: dragArea

        property bool held: false

        anchors {
          left: parent.left
          right: parent.right
        }

        drag {
          axis: Drag.YAxis
          target: held ? content : undefined
        }

        height: CodecsViewerStyle.attribute.height

        onPressAndHold: held = true
        onReleased: held = false

        RowLayout {
          id: content

          Drag.active: dragArea.held
          Drag.source: dragArea
          Drag.hotSpot.x: width / 2
          Drag.hotSpot.y: height / 2

          height: dragArea.height
          width: dragArea.width

          spacing: CodecsViewerStyle.column.spacing

          CodecAttribute {
            Layout.preferredWidth: CodecsViewerStyle.column.mimeWidth
            text: $codec.mime
          }

          CodecAttribute {
            Layout.preferredWidth: CodecsViewerStyle.column.encoderDescriptionWidth
            text: $codec.encoderDescription
          }

          CodecAttribute {
            Layout.preferredWidth: CodecsViewerStyle.column.clockRateWidth
            text: $codec.clockRate
          }

          CodecAttribute {
            Layout.preferredWidth: CodecsViewerStyle.column.bitrateWidth
            text: $codec.bitrate
          }

          TextField {
            Layout.preferredWidth: CodecsViewerStyle.column.recvFmtpWidth
            text: $codec.recvFmtp
          }

          Switch {
            checked: $codec.enabled

            onClicked: view.model.enableCodec(index, !checked)
          }
        }

        DropArea {
          anchors.fill: parent

          onEntered: {
            visualModel.items.move(
              drag.source.DelegateModel.itemsIndex,
              dragArea.DelegateModel.itemsIndex
            )
          }
        }
      }
    }
  }
}
