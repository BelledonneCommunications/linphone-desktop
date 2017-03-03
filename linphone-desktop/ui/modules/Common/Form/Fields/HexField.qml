import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Item {
  id: wrapper

  // ---------------------------------------------------------------------------

  property alias readOnly: textField.readOnly
  property string text

  // ---------------------------------------------------------------------------

  signal editingFinished (int value)

  // ---------------------------------------------------------------------------

  function _computeText (text) {
    return (+text).toString(16).toUpperCase()
  }

  // ---------------------------------------------------------------------------

  implicitHeight: textField.height
  width: TextFieldStyle.background.width

  // ---------------------------------------------------------------------------

  Binding {
    property: 'text'
    target: textField
    value: _computeText(wrapper.text)
  }

  TextField {
    id: textField

    validator: RegExpValidator {
      regExp: /[0-9A-Fa-f]*/
    }

    width: parent.width

    onEditingFinished: {
      text = _computeText('0x' + text)
      wrapper.editingFinished(parseInt(text, 16))
    }
  }
}
