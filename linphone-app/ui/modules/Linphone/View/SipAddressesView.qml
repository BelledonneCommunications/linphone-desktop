import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

ScrollableListView {
  id: sipAddressesView

  // ---------------------------------------------------------------------------

  // Contains a list of: {
  //   icon: 'string',
  //   handler: function () { ... }
  // }
  property var actions: []

  property string genSipAddress

  // Optional parameters.
  property string headerButtonDescription
  property string headerButtonIcon
  property var headerButtonAction

  readonly property string interpretableSipAddress: SipAddressesModel.interpretSipAddress(
    genSipAddress, false
  )

  // ---------------------------------------------------------------------------

  signal entryClicked (var entry)

  // ---------------------------------------------------------------------------
  // Header.
  // ---------------------------------------------------------------------------

  header: MouseArea {
    height: {
      var height = headerButton.visible ? SipAddressesViewStyle.header.button.height : 0
      if (defaultContact.visible) {
        height += SipAddressesViewStyle.entry.height
      }
      return height
    }
    width: parent.width

    // Workaround to handle mouse.
    // Without it, the mouse can be given to items list when mouse is hover header.
    hoverEnabled: true
    cursorShape: Qt.ArrowCursor

    Column {
      anchors.fill: parent

      spacing: 0

      // -----------------------------------------------------------------------
      // Default contact.
      // -----------------------------------------------------------------------

      Loader {
        id: defaultContact

        height: SipAddressesViewStyle.entry.height
        width: parent.width

        visible: sipAddressesView.interpretableSipAddress.length > 0

        sourceComponent: Rectangle {
          anchors.fill: parent
          color: SipAddressesViewStyle.entry.color.normal

          RowLayout {
            anchors {
              fill: parent
              rightMargin: SipAddressesViewStyle.entry.rightMargin
            }
            spacing: 0

            Contact {
              id: contact

              Layout.fillHeight: true
              Layout.fillWidth: true

              entry: ({
                sipAddress: sipAddressesView.interpretableSipAddress
              })
            }

            ActionBar {
              id: defaultContactActionBar

              iconSize: SipAddressesViewStyle.entry.iconSize

              Repeater {
                model: sipAddressesView.actions

                ActionButton {
                  icon: modelData.icon
                  visible: {
                    var visible = sipAddressesView.actions[index].visible
                    return visible === undefined || visible
                  }

                  onClicked: sipAddressesView.actions[index].handler({
                    sipAddress: sipAddressesView.interpretableSipAddress
                  })
                }
              }
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // Header button.
      // -----------------------------------------------------------------------

      MouseArea {
        id: headerButton

        height: SipAddressesViewStyle.header.button.height
        width: parent.width

        visible: !!sipAddressesView.headerButtonAction

        onClicked: sipAddressesView.headerButtonAction(sipAddressesView.interpretableSipAddress)

        Rectangle {
          anchors.fill: parent
          color: parent.pressed
            ? SipAddressesViewStyle.header.color.pressed
            : SipAddressesViewStyle.header.color.normal

          Text {
            anchors {
              left: parent.left
              leftMargin: SipAddressesViewStyle.header.leftMargin
              verticalCenter: parent.verticalCenter
            }

            font {
              bold: true
              pointSize: SipAddressesViewStyle.header.text.pointSize
            }

            color: headerButton.pressed
              ? SipAddressesViewStyle.header.text.color.pressed
              : SipAddressesViewStyle.header.text.color.normal
            text: sipAddressesView.headerButtonDescription
          }

          Icon {
            anchors {
              right: parent.right
              rightMargin: SipAddressesViewStyle.header.rightMargin
              verticalCenter: parent.verticalCenter
            }

            icon: sipAddressesView.headerButtonIcon
            iconSize: SipAddressesViewStyle.header.iconSize

            visible: icon.length > 0
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Entries.
  // ---------------------------------------------------------------------------

  delegate: Rectangle {
    id: sipAddressEntry

    color: SipAddressesViewStyle.entry.color.normal
    height: SipAddressesViewStyle.entry.height
    width: parent ? parent.width : 0

    Rectangle {
      id: indicator

      anchors.left: parent.left
      color: 'transparent'
      height: parent.height
      width: SipAddressesViewStyle.entry.indicator.width
    }

    MouseArea {
      id: mouseArea

      anchors.fill: parent
      cursorShape: Qt.ArrowCursor

      RowLayout {
        anchors {
          fill: parent
          rightMargin: SipAddressesViewStyle.entry.rightMargin
        }
        spacing: 0

        // ---------------------------------------------------------------------
        // Contact or address info.
        // ---------------------------------------------------------------------

        Contact {
          Layout.fillHeight: true
          Layout.fillWidth: true

          entry: $sipAddress

          MouseArea {
            anchors.fill: parent
            onClicked: sipAddressesView.entryClicked($sipAddress)
          }
        }

        // ---------------------------------------------------------------------
        // Actions
        // ---------------------------------------------------------------------

        ActionBar {
          iconSize: SipAddressesViewStyle.entry.iconSize

          Repeater {
            model: sipAddressesView.actions

            ActionButton {
              icon: modelData.icon
              visible: {
                var visible = sipAddressesView.actions[index].visible
                return visible === undefined || visible
              }

              onClicked: sipAddressesView.actions[index].handler($sipAddress)
            }
          }
        }
      }
    }

    // Separator.
    Rectangle {
      color: SipAddressesViewStyle.entry.separator.color
      height: SipAddressesViewStyle.entry.separator.height
      width: parent.width
    }

    // -------------------------------------------------------------------------

    states: State {
      when: mouseArea.containsMouse

      PropertyChanges {
        color: SipAddressesViewStyle.entry.color.hovered
        target: sipAddressEntry
      }

      PropertyChanges {
        color: SipAddressesViewStyle.entry.indicator.color
        target: indicator
      }
    }
  }
}
