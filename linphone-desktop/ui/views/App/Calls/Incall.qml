import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  id: incall

  // ---------------------------------------------------------------------------

  readonly property bool cameraActivated:
    cameraLoader.status !== Loader.Null ||
    cameraPreviewLoader.status !== Loader.Null

  property var call

  property var _contactObserver: SipAddressesModel.getContactObserver(sipAddress)
  property var _fullscreen: null

  // ---------------------------------------------------------------------------

  function _showFullscreen () {
    if (_fullscreen) {
      return
    }

    _fullscreen = Utils.openWindow('IncallFullscreenWindow', incall, {
      properties: {
        call: incall.call,
        callsWindow: incall
      }
    })
  }

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

  // ---------------------------------------------------------------------------
  // Handle video requests.
  // ---------------------------------------------------------------------------

  Connections {
    target: call

    onVideoRequested: {
      var dialog

      // Close dialog after 10s.
      var timeout = Utils.setTimeout(incall, 10000, function () {
        call.statusChanged.disconnect(endedHandler)
        dialog.close()
        call.rejectVideoRequest()
      })

      // Close dialog if call is ended.
      var endedHandler = function (status) {
        if (status === CallModel.CallStatusEnded) {
          Utils.clearTimeout(timeout)
          call.statusChanged.disconnect(endedHandler)
          dialog.close()
        }
      }

      call.statusChanged.connect(endedHandler)

      dialog = Utils.openConfirmDialog(window, {
        descriptionText: qsTr('acceptVideoDescription'),
        exitHandler: function (status) {
          Utils.clearTimeout(timeout)
          call.statusChanged.disconnect(endedHandler)

          if (status) {
            call.acceptVideoRequest()
          } else {
            call.rejectVideoRequest()
          }
        },
        title: qsTr('acceptVideoTitle')
      })
    }
  }

  // ---------------------------------------------------------------------------

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

      Icon {
        id: callQuality

        anchors.left: parent.left
        icon: 'call_quality_0'
        iconSize: CallStyle.header.iconSize
        visible: call.status !== CallModel.CallStatusEnded

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

      ContactDescription {
        id: contactDescription

        anchors.centerIn: parent
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: _contactObserver.sipAddress
        username: LinphoneUtils.getContactUsername(_contactObserver.contact || sipAddress)

        height: parent.height
        width: parent.width - cameraActions.width - callQuality.width - CallStyle.header.contactDescription.width
      }

      // -----------------------------------------------------------------------
      // Video actions.
      // -----------------------------------------------------------------------

      Loader {
        id: cameraActions

        anchors.right: parent.right
        active: call.status !== CallModel.CallStatusEnded

        sourceComponent: ActionBar {
          iconSize: CallStyle.header.iconSize

          ActionButton {
            icon: 'screenshot'
            visible: call.videoEnabled

            onClicked: call.takeSnapshot()
          }

          ActionSwitch {
            enabled: call.recording
            icon: 'record'
            useStates: false

            onClicked: !enabled ? call.startRecording() : call.stopRecording()
          }

          ActionButton {
            icon: 'fullscreen'
            visible: call.videoEnabled

            onClicked: _showFullscreen()
          }
        }
      }
    }

    Text {
      id: elapsedTime

      Layout.fillWidth: true
      color: CallStyle.header.elapsedTime.color
      font.pointSize: CallStyle.header.elapsedTime.fontSize
      horizontalAlignment: Text.AlignHCenter

      Component.onCompleted: {
        var updateDuration = function () {
          text = Utils.formatElapsedTime(call.duration)
          Utils.setTimeout(elapsedTime, 1000, updateDuration)
        }

        updateDuration()
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
          function _computeAvatarSize () {
            var height = container.height
            var width = container.width

            var size = height < CallStyle.container.avatar.maxSize && height > 0
              ? height
              : CallStyle.container.avatar.maxSize

            return size < width ? size : width
          }

          backgroundColor: CallStyle.container.avatar.backgroundColor
          foregroundColor: call.status === CallModel.CallStatusPaused
            ? CallStyle.container.pause.color
            : 'transparent'
          image: _contactObserver.contact && _contactObserver.contact.vcard.avatar
          username: contactDescription.username

          height: _computeAvatarSize()
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
            visible: call.status === CallModel.CallStatusPaused
          }
        }
      }

      Loader {
        id: cameraLoader

        anchors.centerIn: parent

        active: call.videoEnabled && !_fullscreen
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
    // Action Buttons.
    // -------------------------------------------------------------------------

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: CallStyle.actionArea.height

      visible: call.status !== CallModel.CallStatusEnded

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
          enabled: call.videoEnabled
          icon: 'camera'
          iconSize: CallStyle.actionArea.iconSize
          updating: call.updating

          onClicked: call.videoEnabled = !enabled
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

        active: incall.width >= CallStyle.actionArea.lowWidth && call.videoEnabled && !_fullscreen
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
          updating: call.updating

          onClicked: call.pausedByUser = enabled
        }

        ActionButton {
          icon: 'hangup'

          onClicked: call.terminate()
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
}
