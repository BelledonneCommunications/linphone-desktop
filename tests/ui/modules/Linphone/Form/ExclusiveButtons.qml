import QtQuick 2.7

import Linphone.Styles 1.0

// ===================================================================

Row {
  property int _selectedButton: 0
  property variant texts

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
          clicked(index)
        }
      }
    }
  }
}
