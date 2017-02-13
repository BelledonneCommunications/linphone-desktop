import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

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

    Layout.alignment: {
      var height = _content[0].height
      return height < label.height ? Qt.AlignVCenter : Qt.AlignTop
    }

    Layout.maximumWidth: FormGroupStyle.content.width
    Layout.preferredHeight: _content[0].height
    Layout.preferredWidth: FormGroupStyle.content.width
  }
}
