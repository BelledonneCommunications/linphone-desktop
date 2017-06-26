import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle {
  id: container

  property alias proxyModel: chat.model

  // ---------------------------------------------------------------------------

  signal messageToSend (string text)

  // ---------------------------------------------------------------------------

  color: ChatStyle.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ScrollableListView {
      id: chat

      // -----------------------------------------------------------------------

      property bool bindToEnd: false
      property bool tryToLoadMoreEntries: true
      property var sipAddressObserver: SipAddressesModel.getSipAddressObserver(proxyModel.sipAddress)

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
          implicitHeight: container.height + ChatStyle.sectionHeading.bottomMargin
          width: parent.width

          Borders {
            id: container

            borderColor: ChatStyle.sectionHeading.border.color
            bottomWidth: ChatStyle.sectionHeading.border.width
            implicitHeight: text.contentHeight +
              ChatStyle.sectionHeading.padding * 2 +
              ChatStyle.sectionHeading.border.width * 2
            topWidth: ChatStyle.sectionHeading.border.width
            width: parent.width

            Text {
              id: text

              anchors.fill: parent
              color: ChatStyle.sectionHeading.text.color
              font {
                bold: true
                pointSize: ChatStyle.sectionHeading.text.pointSize
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
          leftMargin: ChatStyle.entry.leftMargin
          right: parent ? parent.right : undefined

          rightMargin: ChatStyle.entry.deleteIconSize +
            ChatStyle.entry.message.extraContent.spacing +
            ChatStyle.entry.message.extraContent.rightMargin +
            ChatStyle.entry.message.extraContent.leftMargin +
            ChatStyle.entry.message.outgoing.sendIconSize
        }

        color: ChatStyle.color
        implicitHeight: layout.height + ChatStyle.entry.bottomMargin

        // ---------------------------------------------------------------------

        MouseArea {
          id: mouseArea

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
              Layout.preferredHeight: ChatStyle.entry.lineHeight
              Layout.preferredWidth: ChatStyle.entry.time.width

              color: ChatStyle.entry.time.color
              font.pointSize: ChatStyle.entry.time.pointSize

              text: $chatEntry.timestamp.toLocaleString(
                Qt.locale(App.locale),
                'hh:mm'
              )

              verticalAlignment: Text.AlignVCenter

              TooltipArea {
                text: $chatEntry.timestamp.toLocaleString(Qt.locale(App.locale))
              }
            }

            // Display content.
            Loader {
              Layout.fillWidth: true
              source: Logic.getComponentFromEntry($chatEntry)
            }
          }
        }
      }

      footer: Text {
        color: ChatStyle.composingText.color
        font.pointSize: ChatStyle.composingText.pointSize
        height: visible ? ChatStyle.composingText.height : 0
        leftPadding: ChatStyle.composingText.leftPadding
        visible: text.length > 0

        text: Logic.getIsComposingMessage()
      }
    }

    // -------------------------------------------------------------------------
    // Send area.
    // -------------------------------------------------------------------------

    Borders {
      Layout.fillWidth: true
      Layout.preferredHeight: ChatStyle.sendArea.height + ChatStyle.sendArea.border.width

      borderColor: ChatStyle.sendArea.border.color

      topWidth: ChatStyle.sendArea.border.width

      DroppableTextArea {
        id: textArea

        anchors.fill: parent

        dropEnabled: SettingsModel.fileTransferUrl.length > 0
        dropDisabledReason: qsTr('noFileTransferUrl')
        placeholderText: qsTr('newMessagePlaceholder')

        onDropped: Logic.handleFilesDropped(files)
        onTextChanged: Logic.handleTextChanged(text)
        onValidText: Logic.sendMessage(text)
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

    onTriggered: chat.bindToEnd && chat.positionViewAtEnd()
  }
}
