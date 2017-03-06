import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
  spacing: 0

  // ---------------------------------------------------------------------------
  // Info.
  // ---------------------------------------------------------------------------

  Icon {
    Layout.alignment: Qt.AlignHCenter

    icon: 'home_account_assistant'
    iconSize: AssistantHomeStyle.info.iconSize
  }

  Text {
    Layout.fillWidth: true
    Layout.preferredHeight: AssistantHomeStyle.info.title.height

    color: AssistantHomeStyle.info.title.color
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    font {
      bold: true
      pointSize: AssistantHomeStyle.info.title.fontSize
    }

    text: qsTr('homeTitle')
  }

  Text {
    Layout.fillWidth: true
    Layout.preferredHeight: AssistantHomeStyle.info.description.height

    color: AssistantHomeStyle.info.description.color
    elide: Text.ElideRight
    font.pointSize: AssistantHomeStyle.info.description.fontSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    text: qsTr('homeDescription')
  }

  // ---------------------------------------------------------------------------
  // Buttons.
  // ---------------------------------------------------------------------------

  GridView {
    id: buttons

    Layout.fillWidth: true
    Layout.preferredHeight: AssistantHomeStyle.buttons.height

    cellHeight: height / 2
    cellWidth: width / 2

    delegate: Item {
      height: buttons.cellHeight
      width: buttons.cellWidth

      TextButtonA {
        anchors {
          fill: parent
          margins: AssistantHomeStyle.buttons.spacing
        }

        text: $text

        onClicked: window.pushView($view)
      }
    }

    model: ListModel {
      ListElement {
        $text: qsTr('createSipAccount')
        $view: 'AssistantCreateSipAccount'
      }

      ListElement {
        $text: qsTr('useLinphoneSipAccount')
        $view: 'AssistantUseLinphoneSipAccount'
      }

      ListElement {
        $text: qsTr('useOtherSipAccount')
        $view: 'AssistantUseOtherSipAccount'
      }

      ListElement {
        $text: qsTr('fetchRemoteConfiguration')
        $view: 'AssistantFetchRemoteConfiguration'
      }
    }

    interactive: false
  }
}
