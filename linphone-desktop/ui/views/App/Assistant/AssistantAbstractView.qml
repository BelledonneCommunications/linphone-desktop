import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
  id: view

  // ---------------------------------------------------------------------------

  property alias mainActionEnabled: mainActionButton.enabled
  property alias mainActionLabel: mainActionButton.text
  property var mainAction

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  Item {
    id: content

    Layout.fillHeight: true
    Layout.fillWidth: true
  }

  Row {
    Layout.alignment: Qt.AlignHCenter
    spacing: AssistantAbstractViewStyle.buttons.spacing

    TextButtonA {
      text: qsTr('back')
      onClicked: window.popView()
    }

    TextButtonB {
      id: mainActionButton

      onClicked: view.mainAction()
    }
  }
}
