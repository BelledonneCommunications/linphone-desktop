import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

ColumnLayout {
  id: timeline

  // ---------------------------------------------------------------------------

  property alias model: view.model

  property string _selectedSipAddress

  // ---------------------------------------------------------------------------

  signal entrySelected (var entry)

  // ---------------------------------------------------------------------------

  function setSelectedEntry (sipAddress) {
    var n = model.rowCount()

    for (var i = 0; i < n; i++) {
      _selectedSipAddress = sipAddress

      if (sipAddress === model.data(model.index(i, 0)).sipAddress) {
        view.currentIndex = i
        return
      }
    }
  }

  function resetSelectedEntry () {
    view.currentIndex = -1
    _selectedSipAddress = ''
  }

  // ---------------------------------------------------------------------------

  spacing: 0

  // ---------------------------------------------------------------------------

  Connections {
    target: model

    // Handle if current entry was moved in timeline.
    onDataChanged: {
      var index = view.currentIndex
      if (
        index !== -1 &&
        _selectedSipAddress !== model.data(model.index(index, 0)).sipAddress
      ) {
        setSelectedEntry(_selectedSipAddress)
      }
    }

    // A timeline entry is removed from timeline if there is no history entry.
    onRowsAboutToBeRemoved: {
      var index = view.currentIndex
      if (index >= first && index <= last) {
        view.currentIndex = -1
      }
    }

    // A entry is added when history is created.
    onRowsInserted: {
      if (_selectedSipAddress.length === 0) {
        return
      }

      for (var i = first; i <= last; i++) {
        if (_selectedSipAddress === model.data(model.index(i, 0)).sipAddress) {
          view.currentIndex = i
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: TimelineStyle.color
  }

  // ---------------------------------------------------------------------------
  // Legend.
  // ---------------------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: TimelineStyle.legend.height
    color: TimelineStyle.legend.backgroundColor

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

  // ---------------------------------------------------------------------------
  // History.
  // ---------------------------------------------------------------------------

  ScrollableListView {
    id: view

    Layout.fillHeight: true
    Layout.fillWidth: true
    currentIndex: -1

    delegate: Item {
      height: TimelineStyle.contact.height
      width: parent ? parent.width : 0

      Contact {
        anchors.fill: parent
        color: view.currentIndex === index
          ? TimelineStyle.contact.backgroundColor.selected
          : (
            index % 2 == 0
              ? TimelineStyle.contact.backgroundColor.a
              : TimelineStyle.contact.backgroundColor.b
          )
        displayUnreadMessagesCount: view.currentIndex !== index
        entry: $timelineEntry
        sipAddressColor: view.currentIndex === index
          ? TimelineStyle.contact.sipAddress.color.selected
          : TimelineStyle.contact.sipAddress.color.normal
        usernameColor: view.currentIndex === index
          ? TimelineStyle.contact.username.color.selected
          : TimelineStyle.contact.username.color.normal

        Loader {
          anchors.fill: parent
          sourceComponent: TooltipArea {
            text: $timelineEntry.timestamp.toLocaleString(
              Qt.locale(App.locale()),
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
  }
}
