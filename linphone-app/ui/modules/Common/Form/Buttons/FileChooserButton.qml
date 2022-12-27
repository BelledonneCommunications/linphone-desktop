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
    return path.length ? path : ''
  }

  tools: Item {
    height: parent.height
    width: FileChooserButtonStyle.tools.width

    Rectangle {
      anchors {
        fill: parent
        margins: TextFieldStyle.normal.background.border.width
      }

      color: mouseArea.pressed
        ? FileChooserButtonStyle.tools.button.color.pressed.color
        : (
          mouseArea.containsMouse
            ? FileChooserButtonStyle.tools.button.color.hovered.color
            : FileChooserButtonStyle.tools.button.color.normal.color
        )

      ActionButton {
        anchors.centerIn: parent
        isCustom: true
        backgroundRadius: 90
		colorSet: textField.selectFolder ? FileChooserButtonStyle.folder : FileChooserButtonStyle.file
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
    enabled: !textField.readOnly

    onClicked: fileDialog.open()
  }
}
