import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  id: conference

  property var conferenceModel

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

  // ---------------------------------------------------------------------------

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: CallStyle.header.topMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Conference info.
    // -------------------------------------------------------------------------

    Item {
      id: info

      Layout.fillWidth: true
      Layout.leftMargin: CallStyle.header.leftMargin
      Layout.rightMargin: CallStyle.header.rightMargin
      Layout.preferredHeight: ConferenceStyle.description.height

      ActionBar {
        id: leftActions

        anchors.left: parent.left
        iconSize: CallStyle.header.iconSize
      }

      Text {
        id: conferenceDescription

        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: qsTr('conferenceTitle')

        color: ConferenceStyle.description.color

        font {
          bold: true
          pointSize: ConferenceStyle.description.pointSize
        }

        height: parent.height
        width: parent.width - rightActions.width - leftActions.width - ConferenceStyle.description.width
      }

      // -----------------------------------------------------------------------
      // Video actions.
      // -----------------------------------------------------------------------

      ActionBar {
        id: rightActions

        anchors.right: parent.right
        iconSize: CallStyle.header.iconSize

        ActionSwitch {
          enabled: conference.conferenceModel.recording
          icon: 'record'
          useStates: false

          onClicked: !enabled
            ? conference.conferenceModel.startRecording()
            : conference.conferenceModel.stopRecording()
        }
      }
    }

    // -------------------------------------------------------------------------
    // Contacts visual.
    // -------------------------------------------------------------------------

    Item {
      id: container

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.margins: CallStyle.container.margins

      GridView {
        id: grid

        anchors.fill: parent

        cellHeight: ConferenceStyle.grid.cell.height
        cellWidth: ConferenceStyle.grid.cell.width

        model: conference.conferenceModel

        delegate: Item {
          height: grid.cellHeight
          width: grid.cellWidth

          Column {
            readonly property string sipAddress: $call.sipAddress
            readonly property var sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)

            anchors {
              fill: parent
              margins: ConferenceStyle.grid.spacing
            }

            spacing: ConferenceStyle.grid.cell.spacing

            ContactDescription {
              id: contactDescription

              height: ConferenceStyle.grid.cell.contactDescription.height
              width: parent.width

              horizontalTextAlignment: Text.AlignHCenter
              sipAddress: parent.sipAddressObserver.sipAddress
              username: LinphoneUtils.getContactUsername(parent.sipAddressObserver)
            }

            IncallAvatar {
              readonly property int size: Math.min(
                parent.width,
                parent.height - contactDescription.height - parent.spacing
              )

              anchors.horizontalCenter: parent.horizontalCenter

              call: $call

              height: size
              width: size

              BusyIndicator {
                anchors {
                  horizontalCenter: parent.horizontalCenter
                  verticalCenter: parent.verticalCenter
                }

                color: CallStyle.header.busyIndicator.color
                height: CallStyle.header.busyIndicator.height
                width: CallStyle.header.busyIndicator.width

                visible: $call && $call.status === CallModel.CallStatusOutgoing
              }
            }
          }

          VuMeter {
            anchors {
              bottom: parent.bottom
              left: parent.left
              leftMargin: ConferenceStyle.grid.spacing
              bottomMargin: ConferenceStyle.grid.spacing
            }

            Timer {
              interval: 50
              repeat: true
              running: true

              onTriggered: parent.value = $call.speakerVu
            }
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Action Buttons.
    // -------------------------------------------------------------------------

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: CallStyle.actionArea.height

      GridLayout {
        anchors {
          left: parent.left
          leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }

        columns: incall.width < CallStyle.actionArea.lowWidth ? 2 : 4
        rowSpacing: ActionBarStyle.spacing

        Row {
          spacing: CallStyle.actionArea.vu.spacing

          VuMeter {
            Timer {
              interval: 50
              repeat: true
              running: micro.enabled

              onTriggered: parent.value = conference.conferenceModel.microVu
            }

            enabled: micro.enabled
          }

          ActionSwitch {
            id: micro
            enabled: !conference.conferenceModel.microMuted

            icon: 'micro'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: conference.conferenceModel.microMuted = !conference.conferenceModel.microMuted
          }
        }
      }

      ActionBar {
        anchors {
          right: parent.right
          rightMargin: CallStyle.actionArea.rightButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }

        iconSize: CallStyle.actionArea.iconSize

        ActionSwitch {
          enabled: conference.conferenceModel.isInConf
          icon: 'pause'

          onClicked: {
            var model = conference.conferenceModel
            if (model.isInConf) {
              model.leave()
            } else {
              model.join()
            }
          }
        }

        ActionButton {
          icon: 'hangup'

          onClicked: conference.conferenceModel.terminate()
        }
      }
    }
  }
}
