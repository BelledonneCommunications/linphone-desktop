import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================

Column {
  property alias title: title.text

  // ---------------------------------------------------------------------------

  spacing: FormStyle.spacing

  // ---------------------------------------------------------------------------

  ColumnLayout {
    spacing: FormStyle.header.spacing
    width: parent.width

    Text {
      id: title

      color: FormStyle.header.title.color
      font {
        bold: true
        pointSize: FormStyle.header.title.fontSize
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: FormStyle.header.separator.height

      color: FormStyle.header.separator.color
    }

    Item {
      height: FormStyle.header.bottomMargin
    }
  }
}
