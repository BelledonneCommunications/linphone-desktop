import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import Common.Styles 1.0

Item {
  signal dropped (var files)

  property alias placeholderText: textArea.placeholderText

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

  // Text area.
  Flickable {
    ScrollBar.vertical: ForceScrollBar {
      id: scrollBar
    }
    TextArea.flickable: TextArea {
      id: textArea

      rightPadding: fileChooserButton.width + fileChooserButton.anchors.rightMargin + 6
      wrapMode: TextArea.Wrap
    }
    anchors.fill: parent
  }

  // Handle click to select files.
  MouseArea {
    id: fileChooserButton

    anchors {
      right: parent.right
      rightMargin: scrollBar.width + 6
    }

    height: parent.height
    width: 40

    onClicked: fileDialog.open()

    FileDialog {
      id: fileDialog

      folder: shortcuts.home
      title: qsTr('fileChooserTitle')

      onAccepted: _emitFiles(fileDialog.fileUrls)
    }

    Icon {
      anchors.fill: parent
      fillMode: Image.PreserveAspectFit
      icon: 'chat_attachment'
    }
  }

  // Hover style.
  Rectangle {
    id: hoverContent

    anchors.fill: parent
    color: '#FFFFFF'
    visible: false

    Text {
      anchors.centerIn: parent
      color: '#FE5E00'
      font.pointSize: 11
      text: qsTr('DROP YOUR ATTACHMENT')
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
