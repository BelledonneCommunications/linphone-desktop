import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: block

  property var action
  readonly property alias loading: block._loading

  property bool _loading: false

  // ----------------------------------------------------------------------------

  function execute () {
    block._loading = true
    action()
  }
  function setText(txt){
    errorBlock.text = txt
  }
  

  function stop (error) {
    errorBlock.text = error
    block._loading = false
  }

  // ----------------------------------------------------------------------------

  height: RequestBlockStyle.height

  TextEdit {
    id: errorBlock
    readOnly: true
    selectByMouse: true

    color: RequestBlockStyle.error.color

    font {
      italic: true
      pointSize: RequestBlockStyle.error.pointSize
    }

    height: parent.height
    width: parent.width

    horizontalAlignment: Text.AlignHCenter
    padding: RequestBlockStyle.error.padding
    wrapMode: Text.WordWrap

    visible: !block.loading
  }

  BusyIndicator {
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
    }

    height: RequestBlockStyle.loadingIndicator.height
    width: RequestBlockStyle.loadingIndicator.width

    running: block.loading
  }
}
