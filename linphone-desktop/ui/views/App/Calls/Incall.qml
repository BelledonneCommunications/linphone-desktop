import QtQuick 2.7
import QtQuick.Controls 2.1
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

  property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)
  property var _fullscreen: null

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

  // ---------------------------------------------------------------------------

  Connections {
    target: call

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

          onClicked: callStatistics.open()

          // See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
          Timer {
            interval: 5000
            repeat: true
            running: true
            triggeredOnStart: true

            onTriggered: Logic.updateCallQualityIcon()
          }

          CallStatistics {
            id: callStatistics

            call: incall.call
            width: container.width

            relativeTo: callQuality
            relativeY: CallStyle.header.stats.relativeY
          }
        }

        ActionButton {
          icon: 'tel_keypad'

          onClicked: telKeypad.visible = !telKeypad.visible
        }

        ActionButton {
          id: callSecure

          icon: incall.call.isSecured ? 'call_chat_secure' : 'call_chat_unsecure'
          onClicked: zrtp.visible = (incall.call.encryption === CallModel.CallEncryptionZRTP)
        }
      }

      ContactDescription {
        id: contactDescription

        anchors.centerIn: parent
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: _sipAddressObserver.sipAddress
        username: LinphoneUtils.getContactUsername(_sipAddressObserver.contact || sipAddress)

        height: parent.height
        width: parent.width - rightActions.width - leftActions.width - CallStyle.header.contactDescription.width
      }

      // -----------------------------------------------------------------------
      // Video actions.
      // -----------------------------------------------------------------------

      ActionBar {
        id: rightActions

        anchors.right: parent.right
        iconSize: CallStyle.header.iconSize

        ActionButton {
          icon: 'screenshot'
          visible: incall.call.videoEnabled

          onClicked: incall.call.takeSnapshot()
        }

        ActionSwitch {
          enabled: incall.call.recording
          icon: 'record'
          useStates: false

          onClicked: {
            var call = incall.call
            return !enabled
              ? call.startRecording()
              : call.stopRecording()
          }
        }

        ActionButton {
          icon: 'fullscreen'
          visible: incall.call.videoEnabled

          onClicked: Logic.showFullscreen()
        }
      }
    }

    Text {
      id: elapsedTime

      Layout.fillWidth: true
      color: CallStyle.header.elapsedTime.color
      font.pointSize: CallStyle.header.elapsedTime.fontSize
      horizontalAlignment: Text.AlignHCenter

      Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: elapsedTime.text = Utils.formatElapsedTime(call.duration)
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

        Avatar {
          backgroundColor: CallStyle.container.avatar.backgroundColor
          foregroundColor: incall.call.status === CallModel.CallStatusPaused
            ? CallStyle.container.pause.color
            : 'transparent'
          image: _sipAddressObserver.contact && _sipAddressObserver.contact.vcard.avatar
          username: contactDescription.username

          height: Logic.computeAvatarSize(CallStyle.container.avatar.maxSize)
          width: height

          Text {
            anchors.fill: parent
            color: CallStyle.container.pause.text.color

            // `|| 1` => `pointSize` must be greater than 0.
            font.pointSize: (width / CallStyle.container.pause.text.fontSizeFactor) || 1

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: '&#9616;&nbsp;&#9612;'
            textFormat: Text.RichText
            visible: incall.call.status === CallModel.CallStatusPaused
          }
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

    ZrtpTokenAuthentication {
      id: zrtp
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

            enabled: true
            icon: 'speaker'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: console.log('TODO')
          }
        }

        ActionSwitch {
          enabled: incall.call.videoEnabled
          icon: 'camera'
          iconSize: CallStyle.actionArea.iconSize
          updating: incall.call.updating

          onClicked: incall.call.videoEnabled = !enabled

          TooltipArea {
            text: qsTr('pendingRequestLabel')
            visible: parent.updating
          }
        }

        ActionButton {
          Layout.preferredHeight: CallStyle.actionArea.iconSize
          Layout.preferredWidth: CallStyle.actionArea.iconSize
          icon: 'options' // TODO: display options.
          iconSize: CallStyle.actionArea.iconSize
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
          icon: 'chat'

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
    visible: false
  }
}
