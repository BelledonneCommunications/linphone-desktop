import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Rectangle {
  property alias proxyModel: chat.model

  // Unable to use it in style file at this moment.
  // A `TypeError: Cannot read property 'XXX' of undefined` is launched for many properties
  // in the style file otherwise.
  // Seems related to: https://bugreports.qt.io/browse/QTBUG-58648
  property color _backgroundColor: 'white'

  property bool _bindToEnd: false
  property var _contactObserver: SipAddressesModel.getContactObserver(proxyModel.sipAddress)

  // ---------------------------------------------------------------------------

  signal messageToSend (string text)

  // ---------------------------------------------------------------------------

  color: _backgroundColor

  ColumnLayout {

    anchors.fill: parent
    spacing: 0


    ScrollableListView {
      id: chat

      // -----------------------------------------------------------------------

      property bool _tryToLoadMoreEntries: true

      // -----------------------------------------------------------------------

      function _loadMoreEntries () {
        if (atYBeginning && !_tryToLoadMoreEntries) {
          _tryToLoadMoreEntries = true
          positionViewAtBeginning()
          proxyModel.loadMoreEntries()
        }
      }

      function _initView () {
        _tryToLoadMoreEntries = false
        _bindToEnd = true

        positionViewAtEnd()
      }

      // -----------------------------------------------------------------------

      Layout.fillHeight: true
      Layout.fillWidth: true

      section {
        criteria: ViewSection.FullString
        delegate: sectionHeading
        property: '$sectionDate'
      }

      // -----------------------------------------------------------------------

      Component.onCompleted: {
        function goToEnd () {
          return Utils.setTimeout(chat, 100, function () {
            if (_bindToEnd) {
              positionViewAtEnd()
            }

            return goToEnd()
          })
        }
        goToEnd()

        // First render.
        _initView()
      }

      // -----------------------------------------------------------------------

      onMovementStarted: _bindToEnd = false
      onMovementEnded: {
        if (atYEnd) {
          _bindToEnd = true
        }
      }

      onContentYChanged: _loadMoreEntries()

      // -----------------------------------------------------------------------

      Connections {
        target: proxyModel

        // When the view is changed (for example `Calls` -> `Messages`),
        // the position is set at end and it can be possible to load
        // more entries.
        onEntryTypeFilterChanged: _initView()

        onMoreEntriesLoaded: {
          chat.positionViewAtIndex(n - 1, ListView.Beginning)
          chat._tryToLoadMoreEntries = false
        }
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
                pointSize: ChatStyle.sectionHeading.text.fontSize
              }
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter

              // Cast section to integer because Qt converts the
              // sectionDate in string!!!
              text: new Date(section).toLocaleDateString(
                Qt.locale(App.locale())
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

          // Ugly. I admit it, but it exists a problem, without these
          // lines the extra content message is truncated.
          // I have no other solution at this moment with `anchors`
          // properties... The messages use the `implicitWidth/Height`
          // and `width/Height` attrs and is not easy to found a fix.
          rightMargin: ChatStyle.entry.deleteIconSize +
          ChatStyle.entry.message.extraContent.spacing +
          ChatStyle.entry.message.extraContent.rightMargin +
          ChatStyle.entry.message.extraContent.leftMargin +
          ChatStyle.entry.message.outgoing.sendIconSize
        }
        color: _backgroundColor
        implicitHeight: layout.height + ChatStyle.entry.bottomMargin

        // ---------------------------------------------------------------------

        // Avoid the use of explicit qrc paths.
        Component {
          id: event
          Event {}
        }

        Component {
          id: incomingMessage
          IncomingMessage {}
        }

        Component {
          id: outgoingMessage
          OutgoingMessage {}
        }

        Component {
          id: fileMessage
          FileMessage {}
        }

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
              font.pointSize: ChatStyle.entry.time.fontSize
              text: $chatEntry.timestamp.toLocaleString(
                Qt.locale(App.locale()),
                'hh:mm'
              )
              verticalAlignment: Text.AlignVCenter
            }

            // Display content.
            Loader {
              Layout.fillWidth: true
              sourceComponent: {
                if ($chatEntry.fileName) {
                  return fileMessage
                }

                if ($chatEntry.type === ChatModel.CallEntry) {
                  return event
                }

                return $chatEntry.isOutgoing ? outgoingMessage : incomingMessage
              }
            }
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Send area.
    // -------------------------------------------------------------------------

    Borders {
      Layout.fillWidth: true
      Layout.preferredHeight: ChatStyle.sendArea.height +
      ChatStyle.sendArea.border.width
      borderColor: ChatStyle.sendArea.border.color
      topWidth: ChatStyle.sendArea.border.width

      DroppableTextArea {
        anchors.fill: parent
        dropEnabled: SettingsModel.fileTransferUrl.length > 0
        dropDisabledReason: qsTr('noFileTransferUrl')
        placeholderText: qsTr('newMessagePlaceholder')

        onDropped: {
          _bindToEnd = true
          files.forEach(proxyModel.sendFileMessage)
        }

        onValidText: {
          this.text = ''
          _bindToEnd = true
          proxyModel.sendMessage(text)
        }
      }
    }
  }
}
