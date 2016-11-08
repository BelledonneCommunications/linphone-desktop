import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

ColumnLayout {
  property var contact

  spacing: 0

  ScrollableListView {
    Layout.fillHeight: true
    Layout.fillWidth: true

    section {
      criteria: ViewSection.FullString
      delegate: sectionHeading
      property: '$dateSection'
    }

    // ---------------------------------------------------------------
    // Heading.
    // ---------------------------------------------------------------

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
            // $dateSection in string!!!
            text: new Date(+section).toLocaleDateString(
              Qt.locale()
            )
          }
        }
      }
    }

    // ---------------------------------------------------------------
    // Message/Event renderer.
    // ---------------------------------------------------------------

    delegate: Rectangle {
      id: entry

      function isHoverEntry () {
        return mouseArea.containsMouse
      }

      function deleteEntry () {
        console.log('delete entry', index)
      }

      anchors {
        left: parent.left
        leftMargin: ChatStyle.entry.leftMargin
        right: parent.right

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
      implicitHeight: layout.height + ChatStyle.entry.bottomMargin
      width: parent.width

      // -------------------------------------------------------------

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

      // -------------------------------------------------------------

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
            text: new Date($timestamp).toLocaleString(
              Qt.locale(),
              'hh:mm'
            )
            verticalAlignment: Text.AlignVCenter
          }

          // Display content.
          Loader {
            Layout.fillWidth: true
            sourceComponent: $type === 'message'
              ? ($outgoing ? outgoingMessage : incomingMessage)
            : event
          }
        }

      }
    }

    // TMP
    model: ListModel {
      ListElement { $dateSection: 1465389121000; $outgoing: true; $timestamp: 1465389121000; $type: 'message'; $content: "<img src='http://html.com/wp-content/uploads/html-com-1.png' width='50%' height='50%' />www.google.fr" }
      ListElement { $dateSection: 1465389121000; $outgoing: true; $timestamp: 1465389121000; $type: 'message'; $content: "<a href='mailto:qq1@qqpart.com'>Contact mail</a>" }
      ListElement { $dateSection: 1465389121000; $timestamp: 1465389133000; $type: 'event'; $content: 'incoming_call' }
      ListElement { $dateSection: 1465389121000; $timestamp: 1465389439000; $type: 'message'; $content: '<blink>Perfect!</blink> bg  g vg gv v g v hgv gv gv   jhb jh b  jb jh hg vg    cfcy f  v u  uyg   f tf tf  ft f tf t  t  fy ft f tu  ty f  rd rd  d d   uu gu y  gg y f  r dr   ' }
      ListElement { $dateSection: 1465389121000; $timestamp: 1465389500000; $type: 'event'; $content: 'end_call' }
      ListElement { $dateSection: 1465994221000; $outgoing: true; $timestamp: 1465924321000; $type: 'message'; $content: 'You\'ve heard the expression, "Just believe it and it will come." Well, technically, that is true, however, \'believing\' is not just thinking that you can have it...' }
      ListElement { $dateSection: 1465994221000; $timestamp: 1465924391000; $type: 'event'; $content: 'lost_incoming_call' }
    }
  }

  // -----------------------------------------------------------------
  // Send area.
  // -----------------------------------------------------------------

  Borders {
    Layout.fillWidth: true
    Layout.preferredHeight: ChatStyle.sendArea.height +
      ChatStyle.sendArea.border.width
    borderColor: ChatStyle.sendArea.border.color
    topWidth: ChatStyle.sendArea.border.width

    DroppableTextArea {
      anchors.fill: parent
      placeholderText: qsTr('newMessagePlaceholder')
    }
  }
}
