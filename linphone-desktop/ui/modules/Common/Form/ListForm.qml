import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

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

  signal changed (int index, string defaultValue, string newValue)
  signal removed (int index, string value)

  // ---------------------------------------------------------------------------

  function setInvalid (index, status) {
    Utils.assert(
      index >= 0 && index < values.model.count,
      'Index ' + index + 'not exists.'
    )

    values.model.setProperty(index, '$isInvalid', status)
  }

  function setData (data) {
    var model = values.model

    model.clear()
    data.forEach(function (data) {
      model.append({ $value: data, $isInvalid: false })
    })
  }

  function _addValue (value) {
    values.model.append({ $value: value, $isInvalid: false })

    if (value.length === 0) {
      addButton.enabled = false
    }
  }

  function _handleEditionFinished (index, text) {
    var model = values.model
    var defaultValue = model.get(index).$value

    if (text.length === 0) {
      // No changes. It must exists at least n min values.
      if (minValues != null && minValues >= model.count) {
        // Unable to set property directly. Qt uses a cache of the value.
        model.remove(index)
        model.insert(index, {
          $isInvalid: false,
          $value: defaultValue
        })
        return
      }

      model.remove(index)

      if (defaultValue.length !== 0) {
        listForm.removed(index, defaultValue)
      }
    } else if (text !== defaultValue) {
      // Update changes.
      listForm.changed(index, defaultValue, text)
    }

    addButton.enabled = true
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
      opacity: _edition ? 1 : 0

      onClicked: _edition && _addValue('')
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
      pointSize: ListFormStyle.value.placeholder.fontSize
    }

    padding: ListFormStyle.value.text.padding
    visible: values.model.count === 0
    verticalAlignment: Text.AlignVCenter

    MouseArea {
      anchors.fill: parent
      onClicked: !listForm.readOnly && _addValue('')
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

        onEditingFinished: _handleEditionFinished(index, text)

        Component.onCompleted: {
          if ($value.length === 0) {
            // FIXME: Find the source of this problem.
            //
            // Magic code. If it's the first inserted value,
            // an event or a callback steal the item focus.
            // I suppose it's an internal Qt qml event...
            //
            // So, I choose to run a callback executed after this
            // internal event.
            Utils.setTimeout(values, 0, function () {
              textInput.forceActiveFocus()
            })
          }
        }
      }
    }

    model: ListModel {}
  }
}
