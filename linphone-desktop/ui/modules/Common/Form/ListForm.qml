import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import 'ListForm.js' as Logic

// =============================================================================

RowLayout {
  id: listForm

  // ---------------------------------------------------------------------------

  property alias placeholder: placeholder.text
  property alias title: text.text
  property bool readOnly: false
  property int inputMethodHints
  property var minValues
  readonly property int count: values.count

  // ---------------------------------------------------------------------------

  signal changed (int index, string oldValue, string newValue)
  signal removed (int index, string value)

  // ---------------------------------------------------------------------------

  function setData () {
    Logic.setData.apply(this, arguments)
  }

  function setInvalid () {
    Logic.setInvalid.apply(this, arguments)
  }

  function updateValue () {
    Logic.updateValue.apply(this, arguments)
  }

  // ---------------------------------------------------------------------------

  spacing: 0

  // ---------------------------------------------------------------------------
  // Title area.
  // ---------------------------------------------------------------------------

  RowLayout {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: ListFormStyle.lineHeight
    spacing: ListFormStyle.titleArea.spacing

    ActionButton {
      id: addButton

      icon: 'add'
      iconSize: ListFormStyle.titleArea.iconSize
      opacity: !listForm.readOnly ? 1 : 0

      onClicked: !listForm.readOnly && Logic.addValue('')
    }

    Text {
      id: text

      Layout.preferredWidth: ListFormStyle.titleArea.text.width
      color: ListFormStyle.titleArea.text.color
      elide: Text.ElideRight

      font {
        bold: true
        pointSize: ListFormStyle.titleArea.text.pointSize
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Placeholder.
  // ---------------------------------------------------------------------------

  Text {
    id: placeholder

    Layout.fillWidth: true
    Layout.preferredHeight: ListFormStyle.lineHeight
    color: ListFormStyle.value.placeholder.color

    font {
      italic: true
      pointSize: ListFormStyle.value.placeholder.pointSize
    }

    padding: ListFormStyle.value.text.padding
    visible: values.model.count === 0
    verticalAlignment: Text.AlignVCenter

    MouseArea {
      anchors.fill: parent
      onClicked: !listForm.readOnly && Logic.addValue('')
    }
  }

  // ---------------------------------------------------------------------------
  // Values.
  // ---------------------------------------------------------------------------

  ListView {
    id: values

    Layout.fillWidth: true
    Layout.preferredHeight: count * ListFormStyle.lineHeight
    interactive: false
    visible: model.count > 0

    delegate: Item {
      implicitHeight: textInput.height
      width: parent.width

      TransparentTextInput {
        id: textInput

        inputMethodHints: listForm.inputMethodHints
        isInvalid: $isInvalid
        readOnly: listForm.readOnly
        text: $value

        height: ListFormStyle.lineHeight
        width: parent.width

        Component.onCompleted: Logic.handleItemCreation.apply(this)

        onEditingFinished: Logic.handleEditionFinished(index, text)
      }
    }

    model: ListModel {}
  }
}
