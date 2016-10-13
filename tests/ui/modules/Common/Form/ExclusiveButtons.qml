import QtQuick 2.7

import Common.Styles 1.0

// ===================================================================

Row {
  id: item

  property var texts

  property int _selectedButton: 0

  signal clicked (int button)

  spacing: ExclusiveButtonsStyle.buttonsSpacing

  Repeater {
    model: texts

    SmallButton {
      anchors.verticalCenter: parent.verticalCenter
      backgroundColor: _selectedButton === index
        ? ExclusiveButtonsStyle.button.color.selected
        : (down
           ? ExclusiveButtonsStyle.button.color.pressed
           : (hovered
              ? ExclusiveButtonsStyle.button.color.hovered
              : ExclusiveButtonsStyle.button.color.normal
             )
          )
      text: modelData

      onClicked: {
        if (_selectedButton !== index) {
          _selectedButton = index
          item.clicked(index)
        }
      }
    }
  }
}
