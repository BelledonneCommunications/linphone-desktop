import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

import 'Incall.js' as Logic

// =============================================================================

Rectangle {
  id: incall

  // ---------------------------------------------------------------------------

  // Used by `IncallFullscreenWindow.qml`.
  readonly property bool cameraActivated:
    cameraLoader.status !== Loader.Null ||
    cameraPreviewLoader.status !== Loader.Null

  property var call

  property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(call.fullPeerAddress, call.fullLocalAddress)
  property var _fullscreen: null

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor
  anchors.fill:parent

  // ---------------------------------------------------------------------------

  Connections {
    target: call

    onCameraFirstFrameReceived: Logic.handleCameraFirstFrameReceived(width, height)
    onStatusChanged: Logic.handleStatusChanged (status)
    onVideoRequested: Logic.handleVideoRequested()
  }

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: CallStyle.header.topMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Call info.
    // -------------------------------------------------------------------------

    Item {
      id: info

      Layout.fillWidth: true
      Layout.leftMargin: CallStyle.header.leftMargin
      Layout.rightMargin: CallStyle.header.rightMargin
      Layout.preferredHeight: CallStyle.header.contactDescription.height

      ActionBar {
        id: leftActions

        anchors.left: parent.left
        iconSize: CallStyle.header.iconSize

        ActionButton {
          id: callQuality

          icon: 'call_quality_0'
          useStates: false

          onClicked: Logic.openCallStatistics()

          // See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
          Timer {
            interval: 500
            repeat: true
            running: true
            triggeredOnStart: true

            onTriggered: Logic.updateCallQualityIcon(callQuality, call)
          }

          CallStatistics {
            id: callStatistics

            call: incall.call
            width: container.width

            relativeTo: callQuality
            relativeY: CallStyle.header.stats.relativeY

            onClosed: Logic.handleCallStatisticsClosed()
          }
        }

        ActionButton {
          icon: 'tel_keypad'

          onClicked: telKeypad.visible = !telKeypad.visible
        }

        ActionButton {
          id: callSecure

          icon: incall.call.isSecured ? 'call_chat_secure' : 'call_chat_unsecure'

          onClicked: zrtp.visible = (incall.call.encryption === CallModel.CallEncryptionZrtp)

          TooltipArea {
            text: Logic.makeReadableSecuredString(incall.call.securedString)
          }
        }
      }

      ContactDescription {
        id: contactDescription

        anchors.centerIn: parent
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: _sipAddressObserver.peerAddress
        username: LinphoneUtils.getContactUsername(_sipAddressObserver)

        height: parent.height
        width: parent.width - rightActions.width - leftActions.width
        Text {
        id: elapsedTime
        color: CallStyle.header.elapsedTime.color
        font.pointSize: CallStyle.header.elapsedTime.pointSize
        horizontalAlignment: Text.AlignHCenter
        width: parent.width

        Timer {
          interval: 1000
          repeat: true
          running: true
          triggeredOnStart: true

          onTriggered: {elapsedTime.text = Utils.formatElapsedTime(call.duration);}
        }
      }
      }

      // -----------------------------------------------------------------------
      // Video actions.
      // -----------------------------------------------------------------------

      ActionBar {
        id: rightActions

        anchors.right: parent.right
        iconSize: CallStyle.header.buttonIconSize

        ActionButton {
          icon: 'screenshot'
          visible: incall.call.videoEnabled

          onClicked: incall.call.takeSnapshot()

          TooltipArea {
            text: qsTr('takeSnapshotLabel')
          }
        }

        ActionSwitch {
          id: recordingSwitch

          enabled: incall.call.recording
          icon: 'record'
          useStates: false
          visible: SettingsModel.callRecorderEnabled

          onClicked: {
            var call = incall.call
            return !enabled
              ? call.startRecording()
              : call.stopRecording()
          }

          onVisibleChanged: {
            if (!visible) {
              call.stopRecording()
            }
          }

          TooltipArea {
            text: !recordingSwitch.enabled
              ? qsTr('startRecordingLabel')
              : qsTr('stopRecordingLabel')
          }
        }

        ActionButton {
          icon: 'fullscreen'
          visible: incall.call.videoEnabled

          onClicked: Logic.showFullscreen(contactDescription.mapToGlobal(0,0))
        }
      }
    }

    // -------------------------------------------------------------------------
    // Contact visual.
    // -------------------------------------------------------------------------

    Item {
      id: container

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.margins: CallStyle.container.margins

      Component {
        id: avatar

        IncallAvatar {
          call: incall.call
          height: Logic.computeAvatarSize(CallStyle.container.avatar.maxSize)
          width: height
        }
      }

      Loader {
        id: cameraLoader

        anchors.centerIn: parent

        active: incall.call.videoEnabled && !_fullscreen
        sourceComponent: camera

        Component {
          id: camera

          Camera {
            call: incall.call
            height: container.height
            width: container.width
          }
        }
      }

      Loader {
        anchors.centerIn: parent

        active: !call.videoEnabled || _fullscreen
        sourceComponent: avatar
      }
    }

    // -------------------------------------------------------------------------
    // Zrtp.
    // -------------------------------------------------------------------------

    ZrtpTokenAuthentication {
      id: zrtp

      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
      Layout.margins: CallStyle.container.margins

      call: incall.call
      visible: !call.isSecured && call.encryption !== CallModel.CallEncryptionNone
      z: Constants.zPopup
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
          visible: SettingsModel.muteMicrophoneEnabled

          VuMeter {
            Timer {
              interval: 50
              repeat: true
              running: micro.enabled

              onTriggered: parent.value = incall.call.microVu
            }

            enabled: micro.enabled
          }

          ActionSwitch {
            id: micro

            enabled: !call.microMuted
            icon: 'micro'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: incall.call.microMuted = enabled
          }
        }

        Row {
          spacing: CallStyle.actionArea.vu.spacing

          VuMeter {
            Timer {
              interval: 50
              repeat: true
              running: speaker.enabled

              onTriggered: parent.value = incall.call.speakerVu
            }

            enabled: speaker.enabled
          }

          ActionSwitch {
            id: speaker

            enabled: !call.speakerMuted
            icon: 'speaker'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: incall.call.speakerMuted = enabled
          }
        }

        ActionSwitch {
          enabled: incall.call.videoEnabled
          icon: 'camera'
          iconSize: CallStyle.actionArea.iconSize
          updating: incall.call.updating
          visible: SettingsModel.videoSupported

          onClicked: incall.call.videoEnabled = !enabled

          TooltipArea {
            text: qsTr('pendingRequestLabel')
            visible: parent.updating
          }
        }

        ActionButton {
          Layout.preferredHeight: CallStyle.actionArea.iconSize
          Layout.preferredWidth: CallStyle.actionArea.iconSize

          icon: 'options'
          iconSize: CallStyle.actionArea.iconSize

          onClicked: Logic.openMediaParameters(window, incall)
        }
      }

      // -----------------------------------------------------------------------
      // Preview.
      // -----------------------------------------------------------------------

      Loader {
        id: cameraPreviewLoader

        anchors.centerIn: parent
        height: CallStyle.actionArea.userVideo.height
        width: CallStyle.actionArea.userVideo.width
        active: incall.width >= CallStyle.actionArea.lowWidth && incall.call.videoEnabled && !_fullscreen
        sourceComponent: cameraPreview
        Component {
          id: cameraPreview

          Camera {
            anchors.fill: parent
            call: incall.call
            isPreview: true
          }
        }
      }

      ActionBar {
        id: bottomActions

        anchors {
          right: parent.right
          rightMargin: CallStyle.actionArea.rightButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }
        iconSize: CallStyle.actionArea.iconSize

        ActionSwitch {
          enabled: !call.pausedByUser
          icon: 'pause'
          updating: incall.call.updating
          visible: SettingsModel.callPauseEnabled

          onClicked: incall.call.pausedByUser = enabled

          TooltipArea {
            text: qsTr('pendingRequestLabel')
            visible: parent.updating
          }
        }

        ActionButton {
          icon: 'hangup'

          onClicked: incall.call.terminate()
        }

        ActionButton {
          icon: SettingsModel.chatEnabled && SettingsModel.showStartChatButton ? 'chat' : 'history'

          onClicked: {
            if (window.chatIsOpened) {
              window.closeChat()
            } else {
              window.openChat()
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // TelKeypad.
  // ---------------------------------------------------------------------------

  TelKeypad {
    id: telKeypad

    call: incall.call
    visible: SettingsModel.showTelKeypadAutomatically
  }
}
