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

  property var _contactObserver: SipAddressesModel.getContactObserver(sipAddress)

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

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

      Loader {
        id: cameraActions

        anchors.right: parent.right
        active: Boolean(call.videoInputEnabled)

        sourceComponent: ActionBar {
          iconSize: CallStyle.header.iconSize

          ActionButton {
            icon: 'screenshot'
          }

          ActionButton {
            icon: 'record'
          }

          ActionButton {
            icon: 'fullscreen'
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
          text = Utils .formatElapsedTime(call.duration)
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

      property var _call: call

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

      Component {
        id: camera

        Camera {
          height: container.height
          width: container.width
          call: container._call
        }
      }

      Loader {
        anchors.centerIn: parent

        sourceComponent: call.videoInputEnabled ? camera : avatar
      }
    }

    // -------------------------------------------------------------------------
    // Buttons.
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

        rowSpacing: ActionBarStyle.spacing
        columns: incall.width < CallStyle.actionArea.lowWidth ? 2 : 4

        ActionSwitch {
          enabled: !call.microMuted
          icon: 'micro'
          iconSize: CallStyle.actionArea.iconSize

          onClicked: call.microMuted = enabled
        }

        ActionSwitch {
          icon: 'speaker'
          iconSize: CallStyle.actionArea.iconSize
          onClicked: enabled = !enabled
        }

        ActionSwitch {
          icon: 'camera'
          iconSize: CallStyle.actionArea.iconSize
          onClicked: enabled = !enabled
        }

        ActionButton {
          Layout.preferredHeight: CallStyle.actionArea.iconSize
          Layout.preferredWidth: CallStyle.actionArea.iconSize
          icon: 'options' // TODO: display options.
          iconSize: CallStyle.actionArea.iconSize
        }
      }

      Item {
        anchors.centerIn: parent
        height: CallStyle.actionArea.userVideo.height
        visible: Boolean(incall.width >= CallStyle.actionArea.lowWidth && call.videoOutputEnabled)
        width: CallStyle.actionArea.userVideo.width
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

          onClicked: call.pausedByUser = enabled
        }

        ActionButton {
          icon: 'hangup'

          onClicked: call.terminate()
        }

        ActionSwitch {
          enabled: CallsWindow.chatIsOpened
          icon: 'chat'

          onClicked: {
            if (enabled) {
              CallsWindow.closeChat()
            } else {
              CallsWindow.openChat()
            }
          }
        }
      }
    }
  }
}
