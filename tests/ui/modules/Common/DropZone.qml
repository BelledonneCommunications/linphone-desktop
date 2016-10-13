import QtQuick 2.7
import QtQuick.Dialogs 1.2

// ===================================================================

Rectangle {
  signal dropped (var files)

  color: '#DDDDDD'
  id: dropZone

  function emitFiles (files) {
    // Filtering files, urls are forbidden.
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

  DropArea {
    anchors.fill: parent

    onDropped: {
      dropZone.state = ''
      if (drop.hasUrls) {
        emitFiles(drop.urls)
      }
    }
    onEntered: dropZone.state = 'hover'
    onExited: dropZone.state = ''
  }

  MouseArea {
    anchors.fill: parent
    onClicked: fileDialog.visible = true
  }

  Image {
    anchors.centerIn: parent
    fillMode: Image.PreserveAspectFit
    height: parent.height
    source: 'qrc:/imgs/chat_attachment.svg'
    width: parent.width
  }

  FileDialog {
    folder: shortcuts.home
    id: fileDialog
    title: qsTr('fileChooserTitle')

    onAccepted: emitFiles(fileDialog.fileUrls)
  }

  states: State {
    name: 'hover'
    PropertyChanges { target: dropZone; color: '#BBBBBB' }
  }
}
