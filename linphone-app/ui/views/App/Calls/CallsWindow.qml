import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'CallsWindow.js' as Logic

// =============================================================================

Window {
  id: window

  // ---------------------------------------------------------------------------

  // `{}` is a workaround to avoid `TypeError: Cannot read property...` when calls list is empty
  readonly property var call: ( calls.selectedCall?calls.selectedCall:{
    callError: '',
    isOutgoing: true,
    recording: false,
    localSas: '',
    peerAddress: '',
    localAddress: '',
    type: false,
    updating: true,
    videoEnabled: false
  });

  readonly property bool chatIsOpened: !rightPaned.isClosed()

  // ---------------------------------------------------------------------------

  function openChat () {
    rightPaned.open()
  }

  function closeChat () {
    rightPaned.close()
  }

  function openConferenceManager () {
    Logic.openConferenceManager()
  }

  function setHeight (height) {
    window.height = (Window.screen && height > Window.screen.desktopAvailableHeight)
      ? Window.screen.desktopAvailableHeight
      : height
  }

  // ---------------------------------------------------------------------------

  minimumHeight: CallsWindowStyle.minimumHeight
  minimumWidth: CallsWindowStyle.minimumWidth
  title: qsTr('callsTitle')

  // ---------------------------------------------------------------------------

  onClosing: Logic.handleClosing(close)
  onDetachedVirtualWindow: Logic.tryToCloseWindow()

  // ---------------------------------------------------------------------------

  Paned {
    anchors.fill: parent
    defaultChildAWidth: CallsWindowStyle.callsList.defaultWidth
    maximumLeftLimit: CallsWindowStyle.callsList.maximumWidth
    minimumLeftLimit: CallsWindowStyle.callsList.minimumWidth

    // -------------------------------------------------------------------------
    // Calls list.
    // -------------------------------------------------------------------------

    childA: Rectangle {
      anchors.fill: parent
      color: CallsWindowStyle.callsList.color

      ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: CallsWindowStyle.callsList.header.height

          visible: SettingsModel.outgoingCallsEnabled || SettingsModel.conferenceEnabled

          LinearGradient {
            anchors.fill: parent

            start: Qt.point(0, 0)
            end: Qt.point(0, height)

            gradient: Gradient {
              GradientStop { position: 0.0; color: CallsWindowStyle.callsList.header.color1 }
              GradientStop { position: 1.0; color: CallsWindowStyle.callsList.header.color2 }
            }
          }

          ActionBar {
            anchors {
              left: parent.left
              leftMargin: CallsWindowStyle.callsList.header.leftMargin
              verticalCenter: parent.verticalCenter
            }

            iconSize: CallsWindowStyle.callsList.header.iconSize

            ActionButton {
              icon: 'new_call'
              visible: SettingsModel.outgoingCallsEnabled

              onClicked: Logic.openCallSipAddress()
            }

            ActionButton {
              icon: 'new_conference'
              visible: SettingsModel.conferenceEnabled

              onClicked: Logic.openConferenceManager()
            }
          }
        }

        Calls {
          id: calls

          Layout.fillHeight: true
          Layout.fillWidth: true

          conferenceModel: ConferenceModel {}
          model: CallsListProxyModel {}
        }
      }
    }

    // -------------------------------------------------------------------------
    // Content.
    // -------------------------------------------------------------------------

    childB: Paned {
      id: rightPaned

      anchors.fill: parent
      closingEdge: Qt.RightEdge
      defaultClosed: true
      minimumLeftLimit: CallsWindowStyle.call.minimumWidth
      minimumRightLimit: CallsWindowStyle.chat.minimumWidth
      resizeAInPriority: true

      // -----------------------------------------------------------------------

      Component {
        id: incomingCall

        IncomingCall {
          call: window.call
        }
      }

      Component {
        id: outgoingCall

        OutgoingCall {
          call: window.call
        }
      }

      Component {
        id: incall

        Incall {
          call: window.call
        }
      }

      Component {
        id: endedCall

        EndedCall {
          call: window.call
        }
      }

      Component {
        id: chat

        Chat {
          proxyModel: ChatProxyModel {
            Component.onCompleted: {
              if (!SettingsModel.chatEnabled) {
                setEntryTypeFilter(ChatModel.CallEntry)
              }
            }

            peerAddress: (call?call.peerAddress:'')
            localAddress: (call?call.localAddress:'')
            fullPeerAddress: (call?call.fullPeerAddress:peerAddress)
            fullLocalAddress: (call?call.fullLocalAddress:localAddress)

          }

          Connections {
            target: SettingsModel
            onChatEnabledChanged: proxyModel.setEntryTypeFilter(status ? ChatModel.GenericEntry : ChatModel.CallEntry)
          }
        }
      }

      Component {
        id: conference

        Conference {
          conferenceModel: calls.conferenceModel
        }
      }

      // -----------------------------------------------------------------------

      childA: Loader {
        anchors.fill: parent
        sourceComponent: Logic.getContent()
        onSourceComponentChanged: {rightPaned.childAItem.update()}// Force update when loading a new Content. It's just to be sure
      }

      childB: Loader {
        anchors.fill: parent
        sourceComponent: window.call && window.call.peerAddress && window.call.localAddress ? chat : null
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Handle transfer.
  // Handle count changed. Not on proxy model!!!
  // ---------------------------------------------------------------------------

  Connections {
    target: CallsListModel
    onCallTransferAsked: Logic.handleCallTransferAsked(callModel)
    onRowsRemoved: Logic.tryToCloseWindow()
  }
}
