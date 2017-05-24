import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
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
      Layout.preferredHeight: CallStyle.header.conferenceDescription.height

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

        color: CallStyle.header.conferenceDescription.color

        font {
          bold: true
          pointSize: CallStyle.header.conferenceDescription.fontSize
        }

        height: parent.height
        width: parent.width - rightActions.width - leftActions.width - CallStyle.header.conferenceDescription.width
      }

      // -----------------------------------------------------------------------
      // Video actions.
      // -----------------------------------------------------------------------

      ActionBar {
        id: rightActions

        anchors.right: parent.right
        iconSize: CallStyle.header.iconSize

        ActionSwitch {
          enabled: conference.recording
          icon: 'record'
          useStates: false

          onClicked: !enabled
            ? conference.startRecording()
            : conference.stopRecording()
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

        cellHeight: 145
        cellWidth: 154

        model: ConferenceModel {
          id: conference
        }

        delegate: ColumnLayout {
          readonly property string sipAddress: $call.sipAddress
          readonly property var sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)

          height: grid.cellHeight
          width: grid.cellWidth

          ContactDescription {
            id: contactDescription

            Layout.preferredHeight: 35
            Layout.fillWidth: true

            horizontalTextAlignment: Text.AlignHCenter
            sipAddress: parent.sipAddressObserver.sipAddress
            username: LinphoneUtils.getContactUsername(parent.sipAddressObserver.contact || parent.sipAddress)
          }

          Avatar {
            height: parent.width
            width: parent.width

            backgroundColor: CallStyle.container.avatar.backgroundColor
            foregroundColor: incall.call.status === CallModel.CallStatusPaused
              ? CallStyle.container.pause.color
              : 'transparent'
            image: parent.sipAddressObserver.contact && parent.sipAddressObserver.contact.vcard.avatar
            username: contactDescription.username
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

      RowLayout {
        anchors {
          left: parent.left
          leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }

        spacing: ActionBarStyle.spacing

        Row {
          spacing: CallStyle.actionArea.vu.spacing

          VuMeter {
            Timer {
              interval: 50
              repeat: true
              running: micro.enabled

              onTriggered: parent.value = conference.microVu
            }

            enabled: micro.enabled
          }

          ActionSwitch {
            id: micro

            enabled: !conference.microMuted
            icon: 'micro'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: conference.microMuted = enabled
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

        ActionButton {
          icon: 'hangup'

          onClicked: conference.terminate()
        }
      }
    }
  }
}
