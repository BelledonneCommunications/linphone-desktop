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

  RowLayout {
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
      Layout.fillWidth: true
      Layout.leftMargin: 10

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

      // -----------------------------------------------------------------------
      // One codec.
      // -----------------------------------------------------------------------

      delegate: MouseArea {
        id: dragArea

        property bool held: false

        anchors {
          left: parent.left
          right: parent.right
        }

        drag {
          axis: Drag.YAxis

          maximumY: (view.count - DelegateModel.itemsIndex) * height - height
          minimumY: -DelegateModel.itemsIndex * height

          target: held ? content : undefined
        }

        height: CodecsViewerStyle.attribute.height

        onPressed: held = true
        onReleased: {
          held = false

          content.y = 0
        }

        Rectangle {
          id: content

          Drag.active: dragArea.held
          Drag.source: dragArea
          Drag.hotSpot.x: width / 2
          Drag.hotSpot.y: height / 2

          color: CodecsViewerStyle.attribute.background.color.normal

          height: dragArea.height
          width: dragArea.width

          RowLayout {
            anchors.fill: parent

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
              Layout.fillWidth: true
              Layout.leftMargin: 10

              checked: $codec.enabled

              onClicked: visualModel.model.enableCodec(index, !checked)
            }
          }
        }

        DropArea {
          anchors {
            fill: parent
            margins: CodecsViewerStyle.attribute.dropArea.margins
          }

          onEntered: {
            visualModel.items.move(
              drag.source.DelegateModel.itemsIndex,
              dragArea.DelegateModel.itemsIndex
            )
          }
        }

        MouseArea {
          id: mouseArea

          anchors.fill: parent
          hoverEnabled: true

          onPressed: mouse.accepted = false
        }

        // ---------------------------------------------------------------------
        // Animations/States codec.
        // ---------------------------------------------------------------------

        states: State {
          when: mouseArea.containsMouse

          PropertyChanges {
            target: content
            color: CodecsViewerStyle.attribute.background.color.hovered
          }
        }
      }
    }
  }
}
