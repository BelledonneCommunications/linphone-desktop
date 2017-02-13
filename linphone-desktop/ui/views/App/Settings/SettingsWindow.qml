import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import App.Styles 1.0

// =============================================================================

ApplicationWindow {
  id: window

  height: SettingsWindowStyle.height
  width: SettingsWindowStyle.width

  maximumHeight: height
  maximumWidth: width

  minimumHeight: height
  minimumWidth: width

  title: qsTr('settingsTitle')
  visible: true

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
          icon: 'settings_sip_accounts'
          text: qsTr('sipAccountsTab')
          width: implicitWidth
        }

        TabButton {
          icon: 'settings_audio'
          text: qsTr('audioTab')
          width: implicitWidth
        }

        TabButton {
          icon: 'settings_video'
          text: qsTr('videoTab')
          width: implicitWidth
        }

        TabButton {
          icon: 'settings_call'
          text: qsTr('callsAndChatTab')
          width: implicitWidth
        }

        TabButton {
          icon: 'settings_network'
          text: qsTr('networkTab')
          width: implicitWidth
        }

        TabButton {
          icon: 'settings_advanced'
          text: qsTr('uiTab')
          width: implicitWidth
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: TabButtonStyle.text.height

        color: TabButtonStyle.backgroundColor.normal
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
    }

    // -------------------------------------------------------------------------
    // Buttons.
    // -------------------------------------------------------------------------

    TextButtonB {
      Layout.alignment: Qt.AlignRight
      Layout.bottomMargin: SettingsWindowStyle.validButton.bottomMargin
      Layout.rightMargin: SettingsWindowStyle.validButton.rightMargin

      text: qsTr('validButton')

      onClicked: window.hide()
    }
  }
}
