import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Row {
  id: item

  // ---------------------------------------------------------------------------

  property int selectedButton: 0
  property var texts

  // ---------------------------------------------------------------------------

  // Emitted when the selected button is changed.
  // Gives the selected button id.
  signal clicked (int button)

  // ---------------------------------------------------------------------------

  spacing: ExclusiveButtonsStyle.buttonsSpacing

  Repeater {
    model: texts

    SmallButton {
      anchors.verticalCenter: parent.verticalCenter
      backgroundColor: selectedButton === index
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
        if (selectedButton !== index) {
          selectedButton = index
          item.clicked(index)
        }
      }
    }
  }
}
