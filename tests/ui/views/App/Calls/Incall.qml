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

  color: StartingCallStyle.backgroundColor

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: StartingCallStyle.header.topMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Call info.
    // -------------------------------------------------------------------------

    Item {
      id: info

      Layout.fillWidth: true
      Layout.leftMargin: 20
      Layout.rightMargin: 20
      Layout.preferredHeight: StartingCallStyle.contactDescriptionHeight

      Icon {
        id: callQuality

        anchors.left: parent.left
        icon: 'call_quality_' + 2
        iconSize: 40
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
        iconSize: 40

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
      Layout.margins: StartingCallStyle.containerMargins

      Component {
        id: avatar

        Avatar {
          function _computeAvatarSize () {
            var height = container.height
            var width = container.width

            var size = height < StartingCallStyle.avatar.maxSize && height > 0
            ? height
            : StartingCallStyle.avatar.maxSize
            return size < width ? size : width
          }

          backgroundColor: StartingCallStyle.avatar.backgroundColor
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
        sourceComponent: isVideoCall ? camera : avatar
      }
    }

    // ---------------------------------------------------------------
    // Buttons.
    // ---------------------------------------------------------------

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: StartingCallStyle.actionAreaHeight

      GridLayout {
        anchors {
          left: parent.left
          leftMargin: StartingCallStyle.leftButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }

        rowSpacing: ActionBarStyle.spacing
        columns: call.width < 645 && isVideoCall ? 2 : 4

        ActionSwitch {
          icon: 'micro'
          iconSize: StartingCallStyle.iconSize
          onClicked: enabled = !enabled
        }

        ActionSwitch {
          icon: 'speaker'
          iconSize: StartingCallStyle.iconSize
          onClicked: enabled = !enabled
        }

        ActionSwitch {
          icon: 'camera'
          iconSize: StartingCallStyle.iconSize
          onClicked: enabled = !enabled
        }

        ActionButton {
          Layout.preferredHeight: StartingCallStyle.iconSize
          Layout.preferredWidth: StartingCallStyle.iconSize
          icon: 'options'
          iconSize: StartingCallStyle.iconSize
        }
      }

      Rectangle {
        anchors.centerIn: parent
        color: 'red'
        height: StartingCallStyle.userVideo.height
        visible: call.width >= 550
        width: StartingCallStyle.userVideo.width
      }

      ActionBar {
        anchors {
          right: parent.right
          rightMargin: StartingCallStyle.rightButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }
        iconSize: StartingCallStyle.iconSize

        ActionSwitch {
          icon: 'pause'
          onClicked: enabled = !enabled
        }

        ActionButton {
          icon: 'hangup'

          onClicked: Call.terminate()
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
