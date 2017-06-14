import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
  id: callControls

  // ---------------------------------------------------------------------------

  default property alias _content: content.data

  property alias signIcon: signIcon.icon
  property alias sipAddressColor: contact.sipAddressColor
  property alias usernameColor: contact.usernameColor
  property string sipAddress

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  color: CallControlsStyle.color
  height: CallControlsStyle.height

  MouseArea {
    anchors.fill: parent

    onClicked: callControls.clicked()
  }

  Icon {
    id: signIcon

    anchors {
      left: parent.left
      top: parent.top
    }

    iconSize: CallControlsStyle.signSize
  }

  RowLayout {
    anchors {
      fill: parent
      leftMargin: CallControlsStyle.leftMargin
      rightMargin: CallControlsStyle.rightMargin
    }

    spacing: 0

    Contact {
      id: contact

      Layout.fillHeight: true
      Layout.fillWidth: true

      displayUnreadMessagesCount: true

      entry: SipAddressesModel.getSipAddressObserver(sipAddress)
    }

    Item {
      id: content

      Layout.fillHeight: true
      Layout.preferredWidth: callControls._content[0].width
    }
  }
}
