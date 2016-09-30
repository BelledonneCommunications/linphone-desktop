import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Linphone 1.0
import Utils 1.0

ApplicationWindow {
  id: window

  function setView (view) {
    loaderContent.source = 'qrc:/ui/views/MainWindow/' + view + '.qml'
  }

  function _manageAccounts () {
    Utils.openWindow('ManageAccounts', window)
  }

  maximumHeight: 70
  minimumHeight: 70
  minimumWidth: 780
  title: 'Linphone'
  visible: true

  header: ToolBar {
    background: Rectangle {
      color: '#EAEAEA'
    }
    height: 70

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 20
      anchors.rightMargin: 20
      spacing: 20

      // Collapse.
      Collapse {
        Layout.preferredWidth: 25
        Layout.fillHeight: parent.height
        id: collapse

        onCollapsed: windowStates.state = isCollapsed()
          ? 'collapsed'
          : ''
      }

      // User info.
      ContactDescription {
        id: contactDescription

        Layout.fillHeight: parent.height
        Layout.preferredWidth: 200
        sipAddress: 'e.miller@sip-linphone.org'
        username: 'Edward Miller'
      }

      MouseArea {
        anchors.fill: contactDescription
        onClicked: _manageAccounts()
      }

      // User actions.
      ActionButton {
        Layout.preferredWidth: 1
        onClicked: _manageAccounts()
      }

      ActionButton {
        Layout.preferredWidth: 16
        onClicked: Utils.openWindow('NewCall', window)
      }

      // Search.
      SearchBox {
        Layout.fillWidth: true
        maxMenuHeight: 300 // See Hick's law for good choice.
        placeholderText: qsTr('mainSearchBarPlaceholder')
        entryHeight: 50

        onMenuClosed: content.enabled = true

        onMenuOpened: {
          if (!collapse.isCollapsed()) {
            collapse.collapse()
          }
          content.enabled = false
        }

        model: model1

        delegate: Contact {
          presenceLevel: $presence
          sipAddress: $sipAddress
          username: $username
          width: parent.width

          actions: [
            ActionButton {
              icon: 'call'
              onClicked: console.log('clicked')
            },

            ActionButton {
              icon: 'cam'
              onClicked: console.log('cam clicked')
            }
          ]
        }
      }

      // Start conference.
      ActionButton {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        icon: 'conference'
      }
    }
  }

  RowLayout {
    anchors.fill: parent
    id: content
    spacing: 0

    // Main menu.
    ColumnLayout {
      Layout.fillHeight: true
      Layout.maximumWidth: 250
      Layout.preferredWidth: 250
      spacing: 0

      Menu {
        entryHeight: 50
        entryWidth: parent.width

        entries: [{
          entryName: qsTr('homeEntry'),
          icon: 'home'
        }, {
          entryName: qsTr('contactsEntry'),
          icon: 'contacts_list'
        }]

        onEntrySelected: {
          console.log('entry', entry)

          if (entry === 0) {
            setView('Home')
          } else if (entry === 1) {
            setView('Contacts')
          }
        }
      }

      // History.
      Timeline {
        Layout.fillHeight: true
        Layout.fillWidth: true

        model: ListModel {
          ListElement {
            $presence: 0
            $sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'toto.lala.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'machin.truc.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'hey.listen.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'valentin.cognito.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'charles.henri.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'yesyes.nono.sip.linphone.org'
            $username: 'Toto'
          }
          ListElement {
            $presence: 0
            $sipAddress: 'nsa.sip.linphone.org'
            $username: 'Toto'
          }
        }
      }
      // Logo.
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 70
        color: '#EAEAEA'
      }
    }

    // Main content.
    Loader {
      id: loaderContent

      Layout.fillHeight: true
      Layout.fillWidth: true
      source: 'qrc:/ui/views/MainWindow/Home.qml'
    }
  }

  StateGroup {
    id: windowStates

    states: State {
      name: 'collapsed'

      PropertyChanges {
        height: 480
        maximumHeight: 99999
        maximumWidth: 99999
        minimumHeight: 480
        target: window
      }
    }
  }

  ListModel {
    id: model1

    ListElement {
      $presence: 0
      $sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'toto.lala.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'machin.truc.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'hey.listen.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'valentin.cognito.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'charles.henri.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'yesyes.nono.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'nsa.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'toto.lala.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'machin.truc.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'hey.listen.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'valentin.cognito.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'charles.henri.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'yesyes.nono.sip.linphone.org'
      $username: 'Toto'
    }
    ListElement {
      $presence: 0
      $sipAddress: 'nsa.sip.linphone.org'
      $username: 'Toto'
    }
  }
}
