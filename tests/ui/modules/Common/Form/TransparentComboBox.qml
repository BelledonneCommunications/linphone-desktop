import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// ===================================================================
// Discrete ComboBox that can be integrated in text.
// ===================================================================

ComboBox {
  id: comboBox

  background: Rectangle {
    // No Style constant, see component name.
    // It's a `transparent` ComboBox.
    color: 'transparent'
  }
  delegate: ItemDelegate {
    id: item

    background: Rectangle {
      color: item.down
        ? TransparentComboBoxStyle.item.color.pressed
        : (comboBox.currentIndex === index
           ? TransparentComboBoxStyle.item.color.selected
           : TransparentComboBoxStyle.item.color.normal
          )
    }
    font.bold: comboBox.currentIndex === index
    text: key || modelData
    width: comboBox.width
  }
}
