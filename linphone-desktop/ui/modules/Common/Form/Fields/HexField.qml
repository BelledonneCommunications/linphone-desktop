import QtQuick 2.7

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
  implicitWidth: textField.width

  // ---------------------------------------------------------------------------

  Binding {
    property: 'text'
    target: textField
    value: _computeText(wrapper.text)
  }

  TextField {
    id: textField

    validator: RegExpValidator {
      regExp: /[0-9A-F]*/
    }

    onEditingFinished: {
      text = text.length
        ? parseInt(textField.text, 16)
        : 0
      wrapper.editingFinished(text)
    }
  }
}
