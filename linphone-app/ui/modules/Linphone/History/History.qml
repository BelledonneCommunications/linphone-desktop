import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'History.js' as Logic

// =============================================================================

Rectangle {
  id: container

  property alias proxyModel: history.model
  signal entryClicked(string sipAddress)

  // ---------------------------------------------------------------------------

  color: HistoryStyle.color

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

            borderColor: HistoryStyle.sectionHeading.border.color
            bottomWidth: HistoryStyle.sectionHeading.border.width
            implicitHeight: text.contentHeight +
              HistoryStyle.sectionHeading.padding * 2 +
              HistoryStyle.sectionHeading.border.width * 2
            topWidth: HistoryStyle.sectionHeading.border.width
            width: parent.width

            Text {
              id: text

              anchors.fill: parent
              color: HistoryStyle.sectionHeading.text.color
              font {
                bold: true
                pointSize: HistoryStyle.sectionHeading.text.pointSize
              }
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter

              // Cast section to integer because Qt converts the
              // sectionDate in string!!!
              text: new Date(section).toLocaleDateString(
                Qt.locale(App.locale)
              )
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

          rightMargin: HistoryStyle.entry.deleteIconSize +
            HistoryStyle.entry.message.extraContent.spacing +
            HistoryStyle.entry.message.extraContent.rightMargin +
            HistoryStyle.entry.message.extraContent.leftMargin
        }

        color: HistoryStyle.color
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

              color: HistoryStyle.entry.time.color
              font.pointSize: HistoryStyle.entry.time.pointSize

              text: $historyEntry.timestamp.toLocaleString(
                Qt.locale(App.locale),
                'hh:mm'
              )

              verticalAlignment: Text.AlignVCenter

              TooltipArea {
                text: $historyEntry.timestamp.toLocaleString(Qt.locale(App.locale))
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
                onEntryClicked:{entryClicked(sipAddress)}
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
