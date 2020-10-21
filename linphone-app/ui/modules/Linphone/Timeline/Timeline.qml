import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'Timeline.js' as Logic

// =============================================================================

Rectangle {
  id: timeline

  // ---------------------------------------------------------------------------

  property alias model: view.model
  property string _selectedSipAddress

  // ---------------------------------------------------------------------------

  signal entrySelected (string entry)

  // ---------------------------------------------------------------------------

  function setSelectedEntry (peerAddress, localAddress) {
    Logic.setSelectedEntry(peerAddress, localAddress)
  }

  function resetSelectedEntry () {
    Logic.resetSelectedEntry()
  }

  // ---------------------------------------------------------------------------

  color: TimelineStyle.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    // -------------------------------------------------------------------------

    Connections {
      target: model

      onDataChanged: Logic.handleDataChanged(topLeft, bottomRight, roles)
      onRowsAboutToBeRemoved: Logic.handleRowsAboutToBeRemoved(parent, first, last)
    }

    // -------------------------------------------------------------------------
    // Legend.
    // -------------------------------------------------------------------------

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: TimelineStyle.legend.height
      color: showHistory.containsMouse?TimelineStyle.legend.backgroundColor.hovered:TimelineStyle.legend.backgroundColor.normal
      
      MouseArea{
        id:showHistory
        anchors.fill:parent
        onClicked: {
          view.currentIndex = -1
          timeline.entrySelected('')
          }
      }

      Row {
        anchors {
          fill: parent
          leftMargin: TimelineStyle.legend.leftMargin
          rightMargin: TimelineStyle.legend.rightMargin
        }
        spacing: TimelineStyle.legend.spacing

        Icon {
          anchors.verticalCenter: parent.verticalCenter
          icon: 'timeline_history'
          iconSize: TimelineStyle.legend.iconSize
        }

        Text {
          color: TimelineStyle.legend.color
          font.pointSize: TimelineStyle.legend.pointSize
          height: parent.height
          text: qsTr('timelineTitle')
          verticalAlignment: Text.AlignVCenter
        }
      }
    }

    // -------------------------------------------------------------------------
    // History.
    // -------------------------------------------------------------------------

    ScrollableListView {
      id: view

      Layout.fillHeight: true
      Layout.fillWidth: true
      currentIndex: -1

      delegate: Item {
        height: TimelineStyle.contact.height
        width: parent ? parent.width : 0

        Contact {
          readonly property bool isSelected: view.currentIndex === index

          anchors.fill: parent
          color: isSelected
            ? TimelineStyle.contact.backgroundColor.selected
            : (
              index % 2 == 0
                ? TimelineStyle.contact.backgroundColor.a
                : TimelineStyle.contact.backgroundColor.b
            )
          displayUnreadMessageCount: SettingsModel.chatEnabled
          entry: $timelineEntry
          sipAddressColor: isSelected
            ? TimelineStyle.contact.sipAddress.color.selected
            : TimelineStyle.contact.sipAddress.color.normal
          usernameColor: isSelected
            ? TimelineStyle.contact.username.color.selected
            : TimelineStyle.contact.username.color.normal

          Loader {
            anchors.fill: parent
            sourceComponent: TooltipArea {
              text: $timelineEntry.timestamp.toLocaleString(
                Qt.locale(App.locale),
                Locale.ShortFormat
              )
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            view.currentIndex = index
            timeline.entrySelected($timelineEntry.sipAddress)
          }
        }
      }

      onCountChanged: Logic.handleCountChanged(count)
    }
  }
}
