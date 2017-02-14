import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================
// Display a form component with a legend.
// Must be used in a `FormLine`.
// =============================================================================

RowLayout {
  property alias label: label.text

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  spacing: FormGroupStyle.spacing

  Text {
    id: label

    Layout.preferredHeight: FormGroupStyle.legend.height
    Layout.preferredWidth: FormGroupStyle.legend.width

    color: FormGroupStyle.legend.color
    elide: Text.ElideRight
    font.pointSize: FormGroupStyle.legend.fontSize

    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
  }

  Item {
    id: content

    readonly property int currentHeight: _content[0] ? _content[0].height : 0

    Layout.alignment: currentHeight < FormGroupStyle.legend.height
      ? Qt.AlignVCenter
      : Qt.AlignTop

    Layout.maximumWidth: FormGroupStyle.content.width
    Layout.preferredHeight: currentHeight
    Layout.preferredWidth: FormGroupStyle.content.width
  }
}
