import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================
// Like a `FormGroup` but without label.
// Must be used in a `FormLine`.
// =============================================================================

Item {
  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  implicitHeight: content.height
  width: FormGroupStyle.content.width

  Item {
    id: content

    readonly property int currentHeight: _content[0] ? _content[0].height : 0
    readonly property int currentWidth: _content[0] ? _content[0].width : 0

    anchors {
      horizontalCenter: parent.horizontalCenter

      top: width > FormGroupStyle.legend.width
        ? parent.top
        : undefined

      verticalCenter: width > FormGroupStyle.legend.width
        ? undefined
        : parent.verticalCenter
    }

    height: currentHeight
    width: currentWidth > FormGroupStyle.content.width
      ? FormGroupStyle.content.width
      : currentWidth
  }
}
