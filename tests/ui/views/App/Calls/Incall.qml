import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// ===================================================================

Rectangle {
  id: call

  property bool isVideoCall: false
  property string sipAddress

  property var _contact: ContactsListModel.mapSipAddressToContact(
    sipAddress
  ) || sipAddress

  // -----------------------------------------------------------------

  color: StartingCallStyle.backgroundColor

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: StartingCallStyle.header.topMargin
    }

    spacing: 0

    // ---------------------------------------------------------------
    // Call info.
    // ---------------------------------------------------------------

    RowLayout {
      id: info

      Layout.fillWidth: true
      Layout.leftMargin: 20
      Layout.rightMargin: 20
      Layout.preferredHeight: StartingCallStyle.contactDescriptionHeight

      Icon {
        iconSize: 40
        icon: 'call_quality_' + 2
      }

      Item {
        Layout.fillWidth: true
      }

      ActionBar {
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

    ContactDescription {
      id: contactDescription

      anchors.fill: info
      username: LinphoneUtils.getContactUsername(_contact)
      sipAddress: call.sipAddress
      horizontalTextAlignment: Text.AlignHCenter
    }

    // ---------------------------------------------------------------
    // Contact visual.
    // ---------------------------------------------------------------

    Item {
      id: container

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.margins: StartingCallStyle.containerMargins

      Avatar {
        id: avatar

        function _computeAvatarSize () {
          var height = container.height
          var width = container.width

          var size = height < StartingCallStyle.avatar.maxSize && height > 0
              ? height
              : StartingCallStyle.avatar.maxSize
          return size < width ? size : width
        }

        anchors.centerIn: parent
        backgroundColor: StartingCallStyle.avatar.backgroundColor
        image: _contact.avatar
        username: contactDescription.username

        height: _computeAvatarSize()
        width: height
      }
    }

    // ---------------------------------------------------------------
    // Buttons.
    // ---------------------------------------------------------------

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: StartingCallStyle.actionAreaHeight + 10

      ActionBar {
        anchors {
          left: parent.left
          leftMargin: StartingCallStyle.leftButtonsGroupMargin
          verticalCenter: parent.verticalCenter
        }
        iconSize: StartingCallStyle.iconSize

        ActionSwitch {
          icon: 'micro'
          onClicked: enabled = !enabled
        }

        ActionSwitch {
          icon: 'speaker'
          onClicked: enabled = !enabled
        }

        ActionSwitch {
          icon: 'camera'
          onClicked: enabled = !enabled
        }

        ActionButton {
          icon: 'options'
        }
      }

      Rectangle {
        anchors.centerIn: parent
        color: 'red'
        height: StartingCallStyle.userVideo.height
        visible: true
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
        }

        ActionSwitch {
          enabled: !call.parent.parent.isClosed()
          icon: 'chat'
          onClicked: {
            var parent = call.parent.parent

            if (enabled) {
              parent.close()
            } else {
              parent.open()
            }
          }
        }
      }
    }
  }
}
