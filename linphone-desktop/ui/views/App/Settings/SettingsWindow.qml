import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

ApplicationWindow {
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

    TabBar {
      id: navigationBar

      Layout.fillWidth: true

      TabButton {
        text: qsTr('sipAccountsTab')
        width: implicitWidth
      }

      TabButton {
        text: qsTr('audioTab')
        width: implicitWidth
      }

      TabButton {
        text: qsTr('videoTab')
        width: implicitWidth
      }

      TabButton {
        text: qsTr('callsAndChatTab')
        width: implicitWidth
      }

      TabButton {
        text: qsTr('networkTab')
        width: implicitWidth
      }

      TabButton {
        text: qsTr('uiTab')
        width: implicitWidth
      }
    }

    // -------------------------------------------------------------------------
    // Content.
    // -------------------------------------------------------------------------

    StackLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true
      currentIndex: navigationBar.currentIndex

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
    }
  }
}
