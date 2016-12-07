import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// ===================================================================

TextEdit {
  id: textEdit

  color: activeFocus
    ? TextEditStyle.textColor.focused
    : TextEditStyle.textColor.normal
  padding: ListFormStyle.value.text.padding
  selectByMouse: true
  verticalAlignment: TextEdit.AlignVCenter

  width: !activeFocus
    ? parent.width
    : contentWidth + padding * 2

  Keys.onEscapePressed: focus = false
  Keys.onReturnPressed: focus = false

  InvertedMouseArea {
    anchors.fill: parent
    enabled: textEdit.activeFocus
    onPressed: textEdit.focus = false
  }

  Rectangle {
    color: parent.activeFocus
      ? TextEditStyle.backgroundColor.focused
      : TextEditStyle.backgroundColor.normal
    anchors.fill: parent
  }
}
