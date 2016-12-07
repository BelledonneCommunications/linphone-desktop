import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// ===================================================================

RowLayout {
  id: listForm

  property alias model: values.model
  property alias placeholder: placeholder.text
  property alias title: text.text

  // -----------------------------------------------------------------

  function _addValue (value) {
    model.append({ $value: value })

    if (value.length === 0) {
      addButton.enabled = false
    }
  }

  function _handleEditionFinished (index, text) {
    if (text.length === 0) {
      model.remove(index)
    } else {
      model.set(index, { $value: text })
    }

    addButton.enabled = true
  }

  // -----------------------------------------------------------------

  spacing: 0

  // -----------------------------------------------------------------
  // Title area.
  // -----------------------------------------------------------------

  RowLayout {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: ListFormStyle.lineHeight
    spacing: ListFormStyle.titleArea.spacing

    ActionButton {
      id: addButton

      icon: 'add'
      iconSize: ListFormStyle.titleArea.iconSize

      onClicked: _addValue('')
    }

    Text {
      id: text

      Layout.preferredWidth: ListFormStyle.titleArea.text.width
      color: ListFormStyle.titleArea.text.color
      elide: Text.ElideRight

      font {
        bold: true
        pointSize: ListFormStyle.titleArea.text.fontSize
      }
    }
  }

  // -----------------------------------------------------------------
  // Placeholder.
  // -----------------------------------------------------------------

  Text {
    id: placeholder

    Layout.fillWidth: true
    Layout.preferredHeight: ListFormStyle.lineHeight
    color: ListFormStyle.value.placeholder.color

    font {
      italic: true
      pointSize: ListFormStyle.value.placeholder.fontSize
    }

    padding:  ListFormStyle.value.text.padding
    visible: model.count === 0
    verticalAlignment: Text.AlignVCenter
  }

  // -----------------------------------------------------------------
  // Values.
  // -----------------------------------------------------------------

  ListView {
    id: values

    Layout.fillWidth: true
    Layout.preferredHeight: count * ListFormStyle.lineHeight
    interactive: false
    visible: count > 0

    delegate: Item {
      implicitHeight: textEdit.height
      width: parent.width

      Rectangle {
        color: textEdit.activeFocus
          ? ListFormStyle.value.backgroundColor.focused
          : ListFormStyle.value.backgroundColor.normal
        anchors.fill: textEdit
      }

      TextEdit {
        id: textEdit

        color: activeFocus
          ? ListFormStyle.value.text.color.focused
          : ListFormStyle.value.text.color.normal
        padding: ListFormStyle.value.text.padding
        selectByMouse: true
        text: $value
        verticalAlignment: TextEdit.AlignVCenter

        height: ListFormStyle.lineHeight
        width: !activeFocus
          ? parent.width
          : contentWidth + padding * 2

        Keys.onEscapePressed: focus = false
        Keys.onReturnPressed: focus = false

        onEditingFinished: _handleEditionFinished(index, text)

        InvertedMouseArea {
          anchors.fill: parent
          enabled: textEdit.activeFocus
          onPressed: textEdit.focus = false
        }
      }

      Component.onCompleted: {
        if ($value.length === 0) {
          textEdit.forceActiveFocus()
        }
      }
    }
  }
}
