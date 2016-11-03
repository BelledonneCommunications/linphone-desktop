import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// ===================================================================

ColumnLayout {
  id: timeline

  property alias model: view.model

  signal contactSelected (var contact)

  // -----------------------------------------------------------------

  function resetSelectedItem () {
    view.currentIndex = -1
  }

  // -----------------------------------------------------------------

  spacing: 0

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: TimelineStyle.legend.height
    color: TimelineStyle.legend.backgroundColor

    // Legend.
    Row {
      anchors {
        fill: parent
        leftMargin: TimelineStyle.legend.leftMargin
        rightMargin: TimelineStyle.legend.rightMargin
      }
      spacing: TimelineStyle.legend.spacing

      Icon {
        anchors.verticalCenter: parent.verticalCenter
        icon: 'history'
        iconSize: TimelineStyle.legend.iconSize
      }

      Text {
        color: TimelineStyle.legend.color
        font.pointSize: TimelineStyle.legend.fontSize
        height: parent.height
        text: qsTr('timelineTitle')
        verticalAlignment: Text.AlignVCenter
      }
    }
  }

  // History.
  ScrollableListView {
    id: view

    Layout.fillHeight: true
    Layout.fillWidth: true
    currentIndex: -1

    delegate: Item {
      height: TimelineStyle.contact.height
      width: parent.width

      Contact {
        anchors.fill: parent
        color: view.currentIndex === index
          ? TimelineStyle.contact.backgroundColor.selected
          : (
            index % 2 == 0
              ? TimelineStyle.contact.backgroundColor.a
              : TimelineStyle.contact.backgroundColor.b
          )
        contact: $contact
        sipAddressColor: view.currentIndex === index
          ? TimelineStyle.contact.sipAddress.color.selected
          : TimelineStyle.contact.sipAddress.color.normal
        usernameColor: view.currentIndex === index
          ? TimelineStyle.contact.username.color.selected
          : TimelineStyle.contact.username.color.normal
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: containsMouse
          ? Qt.PointingHandCursor
          : Qt.ArrowCursor
        hoverEnabled: true

        onClicked: {
          view.currentIndex = index
          timeline.contactSelected($contact)
        }
      }
    }
  }
}
