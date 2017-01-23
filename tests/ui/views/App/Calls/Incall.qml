import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  id: incall

  // ---------------------------------------------------------------------------

  property var call

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
      Layout.preferredHeight: CallStyle.header.contactDescriptionHeight

      Icon {
        id: callQuality

        anchors.left: parent.left
        icon: 'call_quality_0'
        iconSize: CallStyle.header.iconSize
        onIconChanged: console.log(icon)
        // See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
        Timer {
          interval: 5000
          repeat: true
          running: true
          triggeredOnStart: true

          onTriggered: {
            var quality = call.getQuality()
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
        sipAddress: call.sipAddress
        username: LinphoneUtils.getContactUsername(_contactObserver.contact || call.sipAddress)

        height: parent.height
        width: parent.width - cameraActions.width - callQuality.width - 150
      }

      ActionBar {
        id: cameraActions

        anchors.right: parent.right
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
          image: _contactObserver.contact ? _contactObserver.contact.vcard.avatar : ''
          username: contactDescription.username

          height: _computeAvatarSize()
          width: height
        }
      }

      Component {
        id: camera

        Camera {
          height: container.height
          width: container.width
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
        visible: incall.width >= CallStyle.actionArea.lowWidth && call.videoOutputEnabled
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
