import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Konami 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

ApplicationWindow {
  id: window

  minimumHeight: SettingsWindowStyle.height
  minimumWidth: SettingsWindowStyle.width

  title: qsTr('settingsTitle')

  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: window.hide()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: SettingsWindowStyle.color
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    // -------------------------------------------------------------------------
    // Navigation bar.
    // -------------------------------------------------------------------------

    RowLayout {
      Layout.fillWidth: true
      spacing: 0

      TabBar {
        id: tabBar

        TabButton {
          iconName: 'settings_sip_accounts'
          text: qsTr('sipAccountsTab')
          width: implicitWidth
        }

        TabButton {
          iconName: 'settings_audio'
          text: qsTr('audioTab')
          width: implicitWidth
        }

        TabButton {
          enabled: SettingsModel.videoSupported
          iconName: 'settings_video'
          text: qsTr('videoTab')
          width: implicitWidth
        }

        TabButton {
          iconName: 'settings_call'
          text: qsTr('callsAndChatTab')
          width: implicitWidth
        }

        TabButton {
          enabled: SettingsModel.showNetworkSettings || SettingsModel.developerSettingsEnabled
          iconName: 'settings_network'
          text: qsTr('networkTab')
          width: implicitWidth
        }

        TabButton {
          iconName: 'settings_advanced'
          text: qsTr('uiTab')
          width: implicitWidth
        }

        TabButton {
          iconName: 'settings_advanced'
          text: qsTr('uiAdvanced')
          width: implicitWidth
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: TabButtonStyle.text.height

        color: TabButtonStyle.backgroundColor.normal

        MouseArea {
          anchors.fill: parent

          onClicked: konami.forceActiveFocus()

          Konami {
            id: konami
            onTriggered: SettingsModel.developerSettingsEnabled = true
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Content.
    // -------------------------------------------------------------------------

    StackLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true

      currentIndex: tabBar.currentIndex

      SettingsSipAccounts {}
      SettingsAudio {}
      SettingsVideo {}
      SettingsCallsChat {}
      SettingsNetwork {}
      SettingsUi {}
      SettingsAdvanced {}
    }

    // -------------------------------------------------------------------------
    // Buttons.
    // -------------------------------------------------------------------------

    TextButtonB {
      Layout.alignment: Qt.AlignRight
      Layout.topMargin: SettingsWindowStyle.validButton.topMargin
      Layout.bottomMargin: SettingsWindowStyle.validButton.bottomMargin
      Layout.rightMargin: SettingsWindowStyle.validButton.rightMargin

      text: qsTr('validButton')

      onClicked: window.close()
    }
  }
}
