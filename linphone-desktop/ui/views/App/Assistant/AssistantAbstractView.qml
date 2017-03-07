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

  property alias description: description.text
  property alias title: title.text

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  height: stack.height
  width: stack.width

  spacing: AssistantAbstractViewStyle.spacing

  // --------------------------------------------------------------------------
  // Info.
  // --------------------------------------------------------------------------

  Column {
    Layout.fillWidth: true
    spacing: AssistantAbstractViewStyle.info.spacing

    Text {
      id: title

      color: AssistantAbstractViewStyle.info.title.color
      elide: Text.ElideRight

      font {
        pointSize: AssistantAbstractViewStyle.info.title.fontSize
        bold: true
      }

      horizontalAlignment: Text.AlignHCenter
      width: parent.width
    }

    Text {
      id: description

      color: AssistantAbstractViewStyle.info.description.color
      elide: Text.ElideRight

      font.pointSize: AssistantAbstractViewStyle.info.description.fontSize

      horizontalAlignment: Text.AlignHCenter
      visible: text.length > 0
      width: parent.width
    }
  }

  // --------------------------------------------------------------------------
  // Content.
  // --------------------------------------------------------------------------

  Item {
    id: content

    Layout.alignment: Qt.AlignHCenter
    Layout.fillHeight: true
    Layout.preferredWidth: AssistantAbstractViewStyle.content.width
  }

  // --------------------------------------------------------------------------
  // Nav buttons.
  // --------------------------------------------------------------------------

  Row {
    Layout.alignment: Qt.AlignHCenter
    spacing: AssistantAbstractViewStyle.buttons.spacing

    TextButtonA {
      text: qsTr('back')
      onClicked: window.popView()
    }

    TextButtonB {
      id: mainActionButton

      visible: !!view.mainAction

      onClicked: view.mainAction()
    }
  }
}
