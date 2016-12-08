import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// ===================================================================

TextEdit {
  id: textEdit

  color: activeFocus && !readOnly
    ? TextEditStyle.textColor.focused
    : TextEditStyle.textColor.normal
  padding: ListFormStyle.value.text.padding
  selectByMouse: true
  verticalAlignment: TextEdit.AlignVCenter
  wrapMode: Text.Wrap

  Keys.onEscapePressed: focus = false
  Keys.onReturnPressed: focus = false

  InvertedMouseArea {
    anchors.fill: parent
    enabled: textEdit.activeFocus
    onPressed: textEdit.focus = false
  }

  Rectangle {
    anchors.fill: textEdit
    color: textEdit.activeFocus && !readOnly
      ? TextEditStyle.backgroundColor.focused
      : TextEditStyle.backgroundColor.normal
    z: -1
  }
}
