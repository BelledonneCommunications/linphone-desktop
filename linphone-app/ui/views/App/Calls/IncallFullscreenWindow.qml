import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import Common 1.0
import Common.Styles 1.0
import DesktopTools 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

import 'Incall.js' as Logic

// =============================================================================

Window {
  id: windowId

  // ---------------------------------------------------------------------------

  property var call
  property var caller
  property bool hideButtons: false

  // ---------------------------------------------------------------------------

  function exit (cb) {
    DesktopTools.screenSaverStatus = true

    // `exit` is called by `Incall.qml`.
    // The `windowId` id can be null if the windowId was closed in this view.
    if (!windowId) {
      return
    }

    if(!windowId.close() && parent)
      parent.close()
    

    if (cb) {
      cb()
    }
  }

  // ---------------------------------------------------------------------------
  onCallChanged: if(!call) windowId.exit()
  Component.onCompleted: {
    windowId.call = caller.call
  }
  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: windowId.exit()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    id:container
    anchors.fill: parent
    color: '#000000' // Not a style.
    focus: true

    Keys.onEscapePressed: windowId.exit()

    Loader {
      anchors.fill: parent

      active: {
        var caller = windowId.caller
        return caller && !caller.cameraActivated
      }

      sourceComponent: camera

      Component {
        id: camera

        Camera {
          call: windowId.call
        }
      }
    }
    // -------------------------------------------------------------------------
    // Handle mouse move / Hide buttons.
    // -------------------------------------------------------------------------

    MouseArea {
      Timer {
        id: hideButtonsTimer

        interval: 5000
        running: true

        onTriggered: hideButtons = true
      }

      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      hoverEnabled: true
      propagateComposedEvents: true

      onEntered: hideButtonsTimer.start()
      onExited: hideButtonsTimer.stop()

      onPositionChanged: {
        hideButtonsTimer.stop()
        hideButtons = false
        hideButtonsTimer.start()
      }
    }

    ColumnLayout {
      anchors {
        fill: parent
        topMargin: CallStyle.header.topMargin
      }

      spacing: 0

      // -----------------------------------------------------------------------
      // Call info.
      // -----------------------------------------------------------------------

      Item {
        id: info

        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.leftMargin: CallStyle.header.leftMargin
        Layout.preferredHeight: CallStyle.header.contactDescription.height
        Layout.rightMargin: CallStyle.header.rightMargin

        ActionBar {
          anchors.left: parent.left
          iconSize: CallStyle.header.iconSize
          visible: !hideButtons
          
          ActionButton {
            id: callQuality

            icon: 'call_quality_0'
            iconSize: parent.iconSize
            useStates: false

            onClicked: Logic.openCallStatistics()

          // See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
            Timer {
              interval: 5000
              repeat: true
              running: true
              triggeredOnStart: true

              onTriggered: Logic.updateCallQualityIcon(callQuality, windowId.call)
            }

            CallStatistics {
              id: callStatistics
              enabled: windowId.call
              call: windowId.call
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

            icon: windowId.call && windowId.call.isSecured ? 'call_chat_secure' : 'call_chat_unsecure'

            onClicked: zrtp.visible = (windowId.call.encryption === CallModel.CallEncryptionZrtp)

            TooltipArea {
              text: windowId.call?Logic.makeReadableSecuredString(windowId.call.securedString):''
            }
          }
      
        }

        // ---------------------------------------------------------------------
        // Timer.
        // ---------------------------------------------------------------------

        Text {
          id: elapsedTime

          anchors.fill: parent

          font.pointSize: CallStyle.header.elapsedTime.fullscreen.pointSize

          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter

          visible: !windowId.hideButtons

          // Not a customizable style.
          color: 'white'
          style: Text.Raised
          styleColor: 'black'

          Component.onCompleted: {
            var updateDuration = function () {
            if(windowId.caller){
                var call = windowId.caller.call
                  text = Utils.formatElapsedTime(call.duration)
                Utils.setTimeout(elapsedTime, 1000, updateDuration)
              }
            }

            updateDuration()
          }
        }

        // ---------------------------------------------------------------------
        // Video actions.
        // ---------------------------------------------------------------------

        ActionBar {
          anchors.right: parent.right
          iconSize: CallStyle.header.buttonIconSize
          visible: !hideButtons

          ActionButton {
            icon: 'screenshot'

            onClicked: call.takeSnapshot()

            TooltipArea {
              text: qsTr('takeSnapshotLabel')
            }
          }

          ActionSwitch {
            id: recordingSwitch

            enabled: call && call.recording
            icon: 'record'
            useStates: false
            visible: SettingsModel.callRecorderEnabled

            onClicked: !enabled
              ? call.startRecording()
              : call.stopRecording()

            TooltipArea {
              text: !recordingSwitch.enabled
                ? qsTr('startRecordingLabel')
                : qsTr('stopRecordingLabel')
            }
          }

          ActionButton {
            icon: 'fullscreen'

            onClicked: windowId.exit()
          }
        }
        
      }

      // -----------------------------------------------------------------------
      // Action Buttons.
      // -----------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // Zrtp.
    // -------------------------------------------------------------------------

      ZrtpTokenAuthentication {
        id: zrtp
        
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.margins: CallStyle.container.margins
        call: windowId.call
        visible: call && !call.isSecured && call.encryption !== CallModel.CallEncryptionNone
        z: Constants.zPopup
        color: CallStyle.backgroundColor
      }
      Item {
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        Layout.preferredHeight: CallStyle.actionArea.height
        visible: !hideButtons

        GridLayout {
          anchors {
            left: parent.left
            leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
            verticalCenter: parent.verticalCenter
          }

          rowSpacing: ActionBarStyle.spacing

          Row {
            spacing: CallStyle.actionArea.vu.spacing
            visible: SettingsModel.muteMicrophoneEnabled

            VuMeter {
              Timer {
                interval: 50
                repeat: true
                running: micro.enabled

                onTriggered: parent.value = call.microVu
              }

              enabled: micro.enabled
            }

            ActionSwitch {
              id: micro

              enabled: call && !call.microMuted
              icon: 'micro'
              iconSize: CallStyle.actionArea.iconSize

              onClicked: call.microMuted = enabled
            }
          }

          Row {
            spacing: CallStyle.actionArea.vu.spacing

            VuMeter {
              Timer {
                interval: 50
                repeat: true
                running: speaker.enabled

                onTriggered: parent.value = call.speakerVu
              }

              enabled: speaker.enabled
            }

            ActionSwitch {
              id: speaker

              enabled: call && !call.speakerMuted
              icon: 'speaker'
              iconSize: CallStyle.actionArea.iconSize

              onClicked: call.speakerMuted = enabled
            }
          }

          ActionSwitch {
            enabled: true
            icon: 'camera'
            iconSize: CallStyle.actionArea.iconSize
            updating: call && call.updating

            onClicked: windowId.exit(function () { call.videoEnabled = false })
          }

          ActionButton {
            Layout.preferredHeight: CallStyle.actionArea.iconSize
            Layout.preferredWidth: CallStyle.actionArea.iconSize

            icon: 'options'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: Logic.openMediaParameters(windowId)
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
            enabled: call && !call.pausedByUser
            icon: 'pause'
            updating: call && call.updating
            visible: SettingsModel.callPauseEnabled

            onClicked: windowId.exit(function () { call.pausedByUser = enabled })
          }

          ActionButton {
            icon: 'hangup'

            onClicked: windowId.exit(call.terminate)
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Preview.
  // ---------------------------------------------------------------------------

  Loader {
    active: {
      var caller = windowId.caller
      return caller && !caller.cameraActivated
    }

    sourceComponent: cameraPreview

    Component {
      id: cameraPreview

      Camera {
        property bool scale: false

        function xPosition () {
          return windowId.width / 2 - width / 2
        }

        function yPosition () {
          return windowId.height - height
        }

        call: windowId.call
        isPreview: true

        height: CallStyle.actionArea.userVideo.height * (scale ? 2 : 1)
        width: CallStyle.actionArea.userVideo.width * (scale ? 2 : 1)

        DragBox {
          container: windowId
          draggable: parent

          xPosition: parent.xPosition
          yPosition: parent.yPosition

          onWheel: parent.scale = wheel.angleDelta.y > 0
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // TelKeypad.
  // ---------------------------------------------------------------------------

  TelKeypad {
    id: telKeypad

    call: windowId.call
    visible: false
  }
}
