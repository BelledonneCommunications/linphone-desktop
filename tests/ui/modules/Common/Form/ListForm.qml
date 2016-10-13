import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// ===================================================================

RowLayout {
  id: listForm

  property alias model: values.model
  property alias title: text.text
  property string placeholder

  function _addValue (value) {
    if (
      model.count === 0 ||
      model.get(model.count - 1).$value.length !== 0
    ) {
      model.append({ $value: value })
    }
  }

  function _handleEditionFinished (index, text) {
    if (text.length === 0) {
      model.remove(index)
    } else {
      model.set(index, { $value: text })
    }
  }

  spacing: 0

  // Title area.
  RowLayout {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: ListFormStyle.lineHeight
    spacing: ListFormStyle.titleArea.spacing

    // Button: Add item in list.
    ActionButton {
      Layout.preferredHeight: ListFormStyle.titleArea.iconSize
      Layout.preferredWidth: ListFormStyle.titleArea.iconSize
      icon: 'add_field'

      onClicked: _addValue('')
    }

    // Title text.
    Text {
      id: text

      Layout.preferredWidth: ListFormStyle.titleArea.text.width
      color: ListFormStyle.titleArea.text.color
      font.pointSize: ListFormStyle.titleArea.text.fontSize
    }
  }

  // Values.
  ListView {
    id: values

    Layout.fillWidth: true
    Layout.preferredHeight: count * ListFormStyle.lineHeight
    interactive: false

    delegate: Item {
      implicitHeight: textEdit.height
      width: parent.width

      // Background.
      Rectangle {
        color: textEdit.activeFocus
          ? ListFormStyle.value.backgroundColor.focused
          : ListFormStyle.value.backgroundColor.normal
        implicitHeight: textEdit.height
        implicitWidth: textEdit.width
      }

      // Placeholder.
      Text {
        anchors.fill: textEdit
        color: ListFormStyle.value.placeholder.color
        font.italic: true
        font.pointSize: ListFormStyle.value.placeholder.fontSize
        padding: textEdit.padding
        text: textEdit.text.length === 0 && !textEdit.activeFocus
          ? listForm.placeholder
          : ''
        verticalAlignment: Text.AlignVCenter
      }

      // Input.
      TextEdit {
        id: textEdit

        color: activeFocus
          ? ListFormStyle.value.text.color.focused
          : ListFormStyle.value.text.color.normal
        font.bold: !activeFocus
        height: ListFormStyle.lineHeight
        padding: ListFormStyle.value.text.padding
        selectByMouse: true
        text: $value
        verticalAlignment: TextEdit.AlignVCenter
        width: !activeFocus
          ? parent.width
          : contentWidth + padding * 2

        Keys.onEscapePressed: focus = false
        Keys.onReturnPressed: focus = false

        onEditingFinished: _handleEditionFinished(index, text)
      }

      // Handle click outside `TextEdit` instance.
      InvertedMouseArea {
        enabled: textEdit.activeFocus
        height: textEdit.height
        parent: parent
        width: textEdit.width

        onPressed: textEdit.focus = false
      }
    }
  }
}
