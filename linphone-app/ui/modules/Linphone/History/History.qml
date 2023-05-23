import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import UtilsCpp 1.0

import 'History.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle {
  id: container

  property alias proxyModel: history.model
  signal entryClicked(var entry)

  // ---------------------------------------------------------------------------

  color: HistoryStyle.colorModel.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ScrollableListView {
      id: history

      // -----------------------------------------------------------------------

      property bool bindToEnd: false
      property bool tryToLoadMoreEntries: true

      // -----------------------------------------------------------------------

      Layout.fillHeight: true
      Layout.fillWidth: true

      highlightFollowsCurrentItem: false

      section {
        criteria: ViewSection.FullString
        delegate: sectionHeading
        property: '$sectionDate'
      }

      // -----------------------------------------------------------------------

      Component.onCompleted: Logic.initView()

      onContentYChanged: Logic.loadMoreEntries()
      onMovementEnded: Logic.handleMovementEnded()
      onMovementStarted: Logic.handleMovementStarted()

      // -----------------------------------------------------------------------

      Connections {
        target: proxyModel

        // When the view is changed (for example `Calls` -> `Messages`),
        // the position is set at end and it can be possible to load
        // more entries.
        onEntryTypeFilterChanged: Logic.initView()
        onMoreEntriesLoaded: Logic.handleMoreEntriesLoaded(n)
      }

      // -----------------------------------------------------------------------
      // Heading.
      // -----------------------------------------------------------------------

      Component {
        id: sectionHeading

        Item {
          implicitHeight: container.height + HistoryStyle.sectionHeading.bottomMargin
          width: parent.width

          Borders {
            id: container

            borderColor: HistoryStyle.sectionHeading.border.colorModel.color
            bottomWidth: HistoryStyle.sectionHeading.border.width
            implicitHeight: text.contentHeight +
              HistoryStyle.sectionHeading.padding * 2 +
              HistoryStyle.sectionHeading.border.width * 2
            topWidth: HistoryStyle.sectionHeading.border.width
            width: parent.width

            Text {
              id: text

              anchors.fill: parent
              color: HistoryStyle.sectionHeading.text.colorModel.color
              font {
                bold: true
                pointSize: HistoryStyle.sectionHeading.text.pointSize
                capitalization: Font.Capitalize
              }
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter

              text: UtilsCpp.toDateString(section)
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // Message/Event renderer.
      // -----------------------------------------------------------------------

      delegate: Rectangle {
        id: entry

        function isHoverEntry () {
          return mouseArea.containsMouse
        }

        function removeEntry () {
          proxyModel.removeEntry(index)
        }

        anchors {
          left: parent ? parent.left : undefined
          leftMargin: HistoryStyle.entry.leftMargin
          right: parent ? parent.right : undefined

          rightMargin: HistoryStyle.entry.deleteAction.iconSize +
            HistoryStyle.entry.message.extraContent.spacing +
            HistoryStyle.entry.message.extraContent.rightMargin +
            HistoryStyle.entry.message.extraContent.leftMargin
        }

        color: HistoryStyle.colorModel.color
        implicitHeight: layout.height + HistoryStyle.entry.bottomMargin

        // ---------------------------------------------------------------------

        MouseArea {
          id: mouseArea

          cursorShape: Qt.ArrowCursor
          hoverEnabled: true
          implicitHeight: layout.height
          width: parent.width + parent.anchors.rightMargin

          RowLayout {
            id: layout

            spacing: 0
            width: entry.width

            // Display time.
            Text {
              Layout.alignment: Qt.AlignTop
              Layout.preferredHeight: HistoryStyle.entry.lineHeight
              Layout.preferredWidth: HistoryStyle.entry.time.width

              color: HistoryStyle.entry.time.colorModel.color
              font.pointSize: HistoryStyle.entry.time.pointSize

              text: UtilsCpp.toTimeString($historyEntry.timestamp, 'hh:mm')

              verticalAlignment: Text.AlignVCenter

              TooltipArea {
                text: UtilsCpp.toDateTimeString($historyEntry.timestamp)
              }
            }

            // Display content.
            Loader {
              id:entryLoader
              Layout.fillWidth: true
              source: Logic.getComponentFromEntry($historyEntry)
            }
             Connections{
                target:entryLoader.item
                onEntryClicked:{entryClicked(entry)}
              }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Scroll at end if necessary.
  // ---------------------------------------------------------------------------

  Timer {
    interval: 100
    repeat: true
    running: true

    onTriggered: history.bindToEnd && history.positionViewAtEnd()
  }
}
