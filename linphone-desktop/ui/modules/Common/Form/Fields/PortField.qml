import QtQuick 2.7

import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  id: wrapper

  // ---------------------------------------------------------------------------

  property alias readOnly: textField.readOnly
  property bool supportsRange: false

  property string text

  // ---------------------------------------------------------------------------

  signal editingFinished (int portA, int portB)

  // ---------------------------------------------------------------------------

  function _extractPorts (text) {
    var portA = +text.split(':')[0]
    var portB = (function () {
      var port = text.split(':')[1]
      return port && port.length > 0 ? +port : -1
    })()

    if (portB < 0 || portA === portB) {
      return [ portA, -1 ]
    }

    if (portA < portB) {
      return [ portA, portB ]
    }

    return [ portB, portA ]
  }

  function _computeText (range) {
    return range[1] < 0
      ? range[0]
      : range[0] + ':' + range[1]
  }

  // ---------------------------------------------------------------------------

  implicitHeight: textField.height
  width: TextFieldStyle.background.width

  // ---------------------------------------------------------------------------

  Binding {
    property: 'text'
    target: textField
    value: _computeText(_extractPorts(wrapper.text))
  }

  TextField {
    id: textField

    validator: RegExpValidator {
      regExp: wrapper.supportsRange
        ? Utils.PORT_RANGE_REGEX
        : Utils.PORT_REGEX
    }

    width: parent.width

    // Workaround to supports empty string.
    Keys.onReturnPressed: editingFinished()
    onActiveFocusChanged: !activeFocus && editingFinished()

    onEditingFinished: {
      var range = _extractPorts(text)
      textField.text = _computeText(range)
      wrapper.editingFinished(range[0], range[1])
    }
  }
}
