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
  id: window

  // ---------------------------------------------------------------------------

  property var call
  property var caller
  property bool hideButtons: false

  // ---------------------------------------------------------------------------

  function exit (cb) {
    DesktopTools.screenSaverStatus = true

    // `exit` is called by `Incall.qml`.
    // The `window` id can be null if the window was closed in this view.
    if (!window) {
      return
    }

    if(!window.close() && parent)
      parent.close()
    

    if (cb) {
      cb()
    }
  }

  // ---------------------------------------------------------------------------
  onCallChanged: if(!call) window.exit()
  Component.onCompleted: {
    window.call = caller.call
  }
  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: window.exit()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    id:container
    anchors.fill: parent
    color: '#000000' // Not a style.
    focus: true

    Keys.onEscapePressed: window.exit()

    Loader {
      anchors.fill: parent

      active: {
        var caller = window.caller
        return caller && !caller.cameraActivated
      }

      sourceComponent: camera

      Component {
        id: camera

        Camera {
          call: window.call
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
      propagateComposedEvents: true
      cursorShape: Qt.ArrowCursor

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

              onTriggered: Logic.updateCallQualityIcon(callQuality, window.call)
            }

            CallStatistics {
              id: callStatistics
              enabled: window.call
              call: window.call
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

            icon: window.call && window.call.isSecured ? 'call_chat_secure' : 'call_chat_unsecure'

            onClicked: zrtp.visible = (window.call.encryption === CallModel.CallEncryptionZrtp)

            TooltipArea {
              text: window.call?Logic.makeReadableSecuredString(window.call.securedString):''
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

          visible: !window.hideButtons

          // Not a customizable style.
          color: 'white'
          style: Text.Raised
          styleColor: 'black'

          Component.onCompleted: {
            var updateDuration = function () {
            if(window.caller){
                var call = window.caller.call
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

            onClicked: window.exit()
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
        call: window.call
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

            onClicked: window.exit(function () { call.videoEnabled = false })
          }

          ActionButton {
            Layout.preferredHeight: CallStyle.actionArea.iconSize
            Layout.preferredWidth: CallStyle.actionArea.iconSize

            icon: 'options'
            iconSize: CallStyle.actionArea.iconSize

            onClicked: Logic.openMediaParameters(Window.window, window)
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

            onClicked: window.exit(function () { call.pausedByUser = enabled })
          }

          ActionButton {
            icon: 'hangup'

            onClicked: window.exit(call.terminate)
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
      var caller = window.caller
      return caller && !caller.cameraActivated
    }

    sourceComponent: cameraPreview

    Component {
      id: cameraPreview

      Camera {
        id:cameraPreviewItem
        property double scale: 1.0

        function xPosition () {
          return window.width / 2 - width / 2
        }

        function yPosition () {
          return window.height - height
        }
        
        function resetPosition(){
            x = xPosition ();
            y = yPosition ();
          }

        call: window.call
        isPreview: true

        height: Math.min(window.height, (CallStyle.actionArea.userVideo.height * window.height/CallStyle.actionArea.userVideo.heightReference) * scale)
        width: Math.min(window.width, (CallStyle.actionArea.userVideo.width * window.width/CallStyle.actionArea.userVideo.widthReference) * scale )
        DragBox {
          container: window
          draggable: parent

          xPosition: parent.xPosition
          yPosition: parent.yPosition
          
          property double startTime: 0

          onWheel: {
                var acceleration = 0.1;
                if(startTime == 0){
                    startTime = new Date().getTime();
                }else{
		    var delay = new Date().getTime() - startTime;
		    if(delay>0)
		        acceleration = Math.max(0.1, Math.min(2, 10/delay));
		    else
			acceleration = 2
		}
		var newScale = Math.max(0.1 , parent.scale+acceleration*(wheel.angleDelta.y >0 ? 1 : -1) );
		if( window.height >  (CallStyle.actionArea.userVideo.height * window.height/CallStyle.actionArea.userVideo.heightReference) * newScale
		    && window.width >  (CallStyle.actionArea.userVideo.width * window.width/CallStyle.actionArea.userVideo.widthReference) * newScale){
			parent.scale = newScale
			var point = mapToItem(cameraPreviewItem.parent, wheel.x, wheel.y);
			parent.x = point.x-parent.width/2;
			parent.y = point.y-parent.height/2;
			updateBoundaries();
		}
                startTime = new Date().getTime();
          }
	  onDoubleClicked:{
		  parent.scale = 1;
		  resetPosition();
	     }
          onClicked: if(mouse.button == Qt.RightButton) {
                         if( parent.scale>1)
				 parent.scale = 1;
			 else
				 parent.scale = 2;
                         resetPosition();
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

    call: window.call
    visible: false
  }
}
