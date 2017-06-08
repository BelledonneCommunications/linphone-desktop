import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

Item {
  id: view

  // ---------------------------------------------------------------------------

  property alias mainActionEnabled: mainActionButton.enabled
  property alias mainActionLabel: mainActionButton.text
  property var mainAction

  property alias description: description.text
  property alias title: title.text

  property bool backEnabled: true

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  height: stack.height
  width: stack.width

  // ---------------------------------------------------------------------------
  // Info.
  // ---------------------------------------------------------------------------

  Column {
    anchors.centerIn: parent

    spacing: AssistantAbstractViewStyle.info.spacing
    width: parent.width

    Text {
      id: title

      color: AssistantAbstractViewStyle.info.title.color
      elide: Text.ElideRight

      font {
        pointSize: AssistantAbstractViewStyle.info.title.pointSize
        bold: true
      }

      horizontalAlignment: Text.AlignHCenter
      width: parent.width
    }

    Text {
      id: description

      color: AssistantAbstractViewStyle.info.description.color
      elide: Text.ElideRight

      font.pointSize: AssistantAbstractViewStyle.info.description.pointSize

      horizontalAlignment: Text.AlignHCenter
      width: parent.width

      visible: text.length > 0
    }

    // -------------------------------------------------------------------------
    // Content.
    // -------------------------------------------------------------------------

    Item {
      id: content

      anchors.horizontalCenter: parent.horizontalCenter
      height: AssistantAbstractViewStyle.content.height
      width: AssistantAbstractViewStyle.content.width
    }
  }

  // ---------------------------------------------------------------------------
  // Nav buttons.
  // ---------------------------------------------------------------------------

  Row {
    id: buttons

    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
    }

    spacing: AssistantAbstractViewStyle.buttons.spacing

    TextButtonA {
      text: qsTr('back')
      visible: view.backEnabled

      onClicked: assistant.popView()
    }

    TextButtonB {
      id: mainActionButton

      visible: !!view.mainAction

      onClicked: view.mainAction()
    }
  }
}
