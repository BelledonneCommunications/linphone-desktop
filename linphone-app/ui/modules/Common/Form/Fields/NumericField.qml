import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
import Common.Styles 1.0

// =============================================================================

TextField {
  id: numericField

  property int maxValue: 9999
  property int minValue: 0
  property int step: 1

  // ---------------------------------------------------------------------------

  function _decrease () {
    var value = +numericField.text
    if (value === minValue) {
      return
    }

    numericField.text = value - step >= minValue
      ? value - step
      : minValue
    numericField.editingFinished()
  }

  function _increase () {
    var value = +numericField.text
    if (value === maxValue) {
      return
    }

    numericField.text = value + step <= maxValue
      ? value + step
      : maxValue
    numericField.editingFinished()
  }

  // ---------------------------------------------------------------------------

  text: minValue

  tools: Item {
    height: parent.height
    width: NumericFieldStyle.tools.width

    Column {
      id: container

      anchors {
        fill: parent
        margins: TextFieldStyle.normal.background.border.width
      }

      // -----------------------------------------------------------------------

      Component {
        id: button

        Button {
          id: buttonInstance

          autoRepeat: true

          background: Rectangle {
            color: buttonInstance.down && !numericField.readOnly
              ? NumericFieldStyle.tools.button.color.pressed.color
              : NumericFieldStyle.tools.button.color.normal.color
          }

          contentItem: Text {
            color: NumericFieldStyle.tools.button.text.colorModel.color
            text: buttonInstance.text
            font.pointSize: NumericFieldStyle.tools.button.text.pointSize

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }

          text: parent.text

          height: container.height / 2
          width: container.width

          onClicked: !numericField.readOnly && handler()
        }
      }

      // -----------------------------------------------------------------------

      Loader {
        property string text: '+'
        property var handler: _increase

        sourceComponent: button
      }

      Loader {
        property string text: '-'
        property var handler: _decrease

        sourceComponent: button
      }
    }
  }

  validator: IntValidator {
    bottom: numericField.minValue
    top: numericField.maxValue
  }
}
