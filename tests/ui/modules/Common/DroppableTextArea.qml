import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import Common.Styles 1.0

// =============================================================================

Item {
  property alias placeholderText: textArea.placeholderText

  // ---------------------------------------------------------------------------

  signal dropped (var files)

  // ---------------------------------------------------------------------------

  function _emitFiles (files) {
    // Filtering files, other urls are forbidden.
    files = files.reduce(function (files, file) {
      var result = file.match(/^file:\/\/(.*)/)

      if (result) {
        files.push(result[1])
      }

      return files
    }, [])

    if (files.length > 0) {
      dropped(files)
    }
  }

  // ---------------------------------------------------------------------------

  // Text area.
  Flickable {
    ScrollBar.vertical: ForceScrollBar {
      id: scrollBar
    }
    TextArea.flickable: TextArea {
      id: textArea

      background: Rectangle {
        color: DroppableTextAreaStyle.backgroundColor
      }

      rightPadding: fileChooserButton.width +
        fileChooserButton.anchors.rightMargin +
        DroppableTextAreaStyle.fileChooserButton.margins
      wrapMode: TextArea.Wrap
    }
    anchors.fill: parent

    // Necessary, else `placeHolderText` can get out of the component.
    clip: true
  }

  // Handle click to select files.
  ActionButton {
    id: fileChooserButton

    anchors {
      right: parent.right
      rightMargin: scrollBar.width +
        DroppableTextAreaStyle.fileChooserButton.margins
      verticalCenter: parent.verticalCenter
    }
    icon: 'attachment'
    iconSize: DroppableTextAreaStyle.fileChooserButton.size

    onClicked: fileDialog.open()

    FileDialog {
      id: fileDialog

      folder: shortcuts.home
      title: qsTr('fileChooserTitle')

      onAccepted: _emitFiles(fileDialog.fileUrls)
    }

    TooltipArea {
      text: qsTr('attachmentTooltip')
    }
  }

  // Hovered style.
  Rectangle {
    id: hoverContent

    anchors.fill: parent
    color: DroppableTextAreaStyle.hoverContent.backgroundColor
    visible: false

    Text {
      anchors.centerIn: parent
      color: DroppableTextAreaStyle.hoverContent.text.color
      font.pointSize: DroppableTextAreaStyle.hoverContent.text.fontSize
      text: qsTr('dropYourAttachment')
    }
  }

  DropArea {
    anchors.fill: parent
    keys: [ 'text/uri-list' ]

    onDropped: {
      state = ''
      if (drop.hasUrls) {
        _emitFiles(drop.urls)
      }
    }
    onEntered: state = 'hover'
    onExited: state = ''

    states: State {
      name: 'hover'
      PropertyChanges { target: hoverContent; visible: true }
    }
  }
}
