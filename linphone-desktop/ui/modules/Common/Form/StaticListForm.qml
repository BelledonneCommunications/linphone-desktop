import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================

RowLayout {
  id: form

  property alias title: text.text
  property bool readOnly: false
  property var fields

  signal changed (int index, string value)

  // ---------------------------------------------------------------------------

  function _handleEditionFinished (index, text) {
    if (text !== fields[index].text) {
      form.changed(index, text)
    }
  }

  // ---------------------------------------------------------------------------

  spacing: 0

  Text {
    id: text

    Layout.alignment: Qt.AlignTop
    Layout.leftMargin: ListFormStyle.titleArea.iconSize + ListFormStyle.titleArea.spacing
    Layout.preferredHeight: ListFormStyle.lineHeight
    Layout.preferredWidth: ListFormStyle.titleArea.text.width

    color: ListFormStyle.titleArea.text.color
    elide: Text.ElideRight

    font {
      bold: true
      pointSize: ListFormStyle.titleArea.text.pointSize
    }

    verticalAlignment: Text.AlignVCenter
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: 0

    Repeater {
      model: form.fields

      TransparentTextInput {
        Layout.fillWidth: true
        Layout.preferredHeight: ListFormStyle.lineHeight
        placeholder: modelData.placeholder || ''
        readOnly: form.readOnly
        text: modelData.text || ''

        onEditingFinished: _handleEditionFinished(index, text)
      }
    }
  }
}
