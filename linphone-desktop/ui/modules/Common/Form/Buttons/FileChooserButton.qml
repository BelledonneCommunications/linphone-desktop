import QtQuick 2.7
import QtQuick.Dialogs 1.2

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================

TextField {
  id: textField

  // ---------------------------------------------------------------------------

  property alias selectExisting: fileDialog.selectExisting
  property alias selectFolder: fileDialog.selectFolder
  property alias title: fileDialog.title

  property string selectedFile: ''

  // ---------------------------------------------------------------------------

  signal accepted (var selectedFile)
  signal rejected

  // ---------------------------------------------------------------------------

  text: {
    var path = textField.selectedFile
    return path.length ? Utils.basename(path) : ''
  }

  tools: Item {
    height: parent.height
    width: FileChooserButtonStyle.tools.width

    Rectangle {
      anchors {
        fill: parent
        margins: TextFieldStyle.background.border.width
      }

      color: mouseArea.pressed
        ? FileChooserButtonStyle.tools.button.color.pressed
        : (
          mouseArea.containsMouse
            ? FileChooserButtonStyle.tools.button.color.hovered
            : FileChooserButtonStyle.tools.button.color.normal
        )

      Icon {
        anchors.centerIn: parent

        icon: (textField.selectFolder ? 'folder' : 'file') + (mouseArea.pressed
          ? '_pressed'
          : (
            mouseArea.containsMouse
              ? '_hovered'
              : '_normal'
          )
        )

        iconSize: FileChooserButtonStyle.tools.button.iconSize
      }
    }
  }

  // ---------------------------------------------------------------------------

  FileDialog {
    id: fileDialog

    folder: {
      var selectedFile = textField.selectedFile

      if (!selectedFile.length) {
        return ''
      }

      return Utils.getUriFromSystemPath(
        textField.selectFolder
          ? selectedFile
          : Utils.dirname(selectedFile)
      )
    }

    onAccepted: {
      var selectedFile = Utils.getSystemPathFromUri(fileUrl)

      textField.selectedFile = selectedFile
      textField.accepted(selectedFile)
    }

    onRejected: textField.rejected()
  }

  // ---------------------------------------------------------------------------

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    hoverEnabled: true

    onClicked: fileDialog.open()
  }
}
