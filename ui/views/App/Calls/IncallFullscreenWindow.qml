import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

Window {
  id: incall

  // ---------------------------------------------------------------------------

  property var call
  property var caller
  property bool hideButtons: false

  // ---------------------------------------------------------------------------

  function exit (cb) {
    // `exit` is called by `Incall.qml`.
    // The `incall` id can be null if the window was closed in this view.
    if (!incall) {
      return
    }

    // It's necessary to call `showNormal` before close on MacOs
    // because the dock will be hidden forever!
    incall.visible = false
    incall.showNormal()
    incall.close()

    if (cb) {
      cb()
    }
  }

  // ---------------------------------------------------------------------------

  Component.onCompleted: {
    incall.call = caller.call
    var show = function (visibility) {
      if (visibility === Window.Windowed) {
        incall.visibilityChanged.disconnect(show)
        incall.showFullScreen()
      }
    }

    incall.visibilityChanged.connect(show)
  }

  visible: false

  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: incall.exit()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: '#000000' // Not a style.
    focus: true

    Keys.onEscapePressed: incall.exit()

    Loader {
      anchors.fill: parent

      active: {
        var caller = incall.caller
        return caller && !caller.cameraActivated
      }

      sourceComponent: camera

      Component {
        id: camera

        Camera {
          call: incall.call
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

          Icon {
            id: callQuality

            icon: 'call_quality_0'
            iconSize: parent.iconSize

            // See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
            Timer {
              interval: 5000
              repeat: true
              running: true
              triggeredOnStart: true

              onTriggered: {
                var quality = call.quality
                callQuality.icon = 'call_quality_' + (
                  // Note: `quality` is in the [0, 5] interval.
                  // It's necessary to map in the `call_quality_` interval. ([0, 3])
                  quality >= 0 ? Math.round(quality / (5 / 3)) : 0
                )
              }
            }
          }

          ActionButton {
            icon: 'tel_keypad'

            onClicked: telKeypad.visible = !telKeypad.visible
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

          visible: !incall.hideButtons

          // Not a customizable style.
          color: 'white'
          style: Text.Raised
          styleColor: 'black'

          Component.onCompleted: {
            var updateDuration = function () {
              var call = incall.caller.call
              text = Utils.formatElapsedTime(call.duration)
              Utils.setTimeout(elapsedTime, 1000, updateDuration)
            }

            updateDuration()
          }
        }

        // ---------------------------------------------------------------------
        // Video actions.
        // ---------------------------------------------------------------------

        ActionBar {
          anchors.right: parent.right
          iconSize: CallStyle.header.iconSize
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

            enabled: call.recording
            icon: 'record'
            useStates: false

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

            onClicked: incall.exit()
          }
        }
      }

      // -----------------------------------------------------------------------
      // Action Buttons.
      // -----------------------------------------------------------------------

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

              enabled: !call.microMuted
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

              enabled: true
              icon: 'speaker'
              iconSize: CallStyle.actionArea.iconSize

              onClicked: console.log('TODO')
            }
          }

          ActionSwitch {
            enabled: true
            icon: 'camera'
            iconSize: CallStyle.actionArea.iconSize
            updating: call.updating

            onClicked: incall.exit(function () { call.videoEnabled = false })
          }

          ActionButton {
            Layout.preferredHeight: CallStyle.actionArea.iconSize
            Layout.preferredWidth: CallStyle.actionArea.iconSize
            icon: 'options'
            iconSize: CallStyle.actionArea.iconSize

            visible: false // TODO: V2
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
            updating: call.updating

            onClicked: incall.exit(function () { call.pausedByUser = enabled })
          }

          ActionButton {
            icon: 'hangup'

            onClicked: incall.exit(call.terminate)
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
      var caller = incall.caller
      return caller && !caller.cameraActivated
    }

    sourceComponent: cameraPreview

    Component {
      id: cameraPreview

      Camera {
        property bool scale: false

        function xPosition () {
          return incall.width / 2 - width / 2
        }

        function yPosition () {
          return incall.height - height
        }

        call: incall.call
        isPreview: true

        height: CallStyle.actionArea.userVideo.height * (scale ? 2 : 1)
        width: CallStyle.actionArea.userVideo.width * (scale ? 2 : 1)

        DragBox {
          container: incall
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

    call: incall.call
    visible: false
  }
}
