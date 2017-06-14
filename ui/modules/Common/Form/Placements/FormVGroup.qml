import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================

ColumnLayout {
  property alias label: label.text

  default property var _content: null

  // ---------------------------------------------------------------------------

  spacing: FormVGroupStyle.spacing
  width: parent.maxItemWidth

  // ---------------------------------------------------------------------------

  Text {
    id: label

    Layout.fillWidth: true

    color: FormVGroupStyle.legend.color
    elide: Text.ElideRight
    font.pointSize: FormVGroupStyle.legend.pointSize
    verticalAlignment: Text.AlignVCenter
  }

  // ---------------------------------------------------------------------------

  Item {
    readonly property int currentHeight: _content ? _content.height : 0

    Layout.fillWidth: true
    Layout.preferredHeight: currentHeight

    Loader {
      active: !!_content
      anchors.fill: parent

      sourceComponent: Item {
        id: content

        data: [ _content ]
        width: parent.width

        Component.onCompleted: _content.width = Qt.binding(function () {
          var contentWidth = content.width
          var wishedWidth = FormVGroupStyle.content.maxWidth
          return contentWidth > wishedWidth ? wishedWidth : contentWidth
        })
      }
    }
  }

  Text {
    Layout.fillWidth: true
    Layout.preferredHeight: FormVGroupStyle.error.height

    color: FormVGroupStyle.error.color
    elide: Text.ElideRight

    font {
      italic: true
      pointSize: FormVGroupStyle.error.pointSize
    }

    text: _content && _content.error && _content.error.length ? _content.error : ''
    visible: parent.parent.dealWithErrors
  }
}
