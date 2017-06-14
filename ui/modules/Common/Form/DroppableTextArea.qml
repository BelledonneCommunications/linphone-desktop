import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  id: droppableTextArea

  property alias placeholderText: textArea.placeholderText
  property alias text: textArea.text

  property bool dropEnabled: true
  property string dropDisabledReason

  // ---------------------------------------------------------------------------

  signal dropped (var files)
  signal validText (string text)

  // ---------------------------------------------------------------------------

  function _emitFiles (files) {
    // Filtering files, other urls are forbidden.
    files = files.reduce(function (files, file) {
      if (file.startsWith('file:')) {
        files.push(Utils.getSystemPathFromUri(file))
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
    anchors.fill: parent
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ForceScrollBar {
      id: scrollBar
    }

    TextArea.flickable: TextArea {
      id: textArea

      function handleValidation () {
        if (text.length !== 0) {
          validText(text)
        }
      }

      background: Rectangle {
        color: DroppableTextAreaStyle.backgroundColor
      }

      color: DroppableTextAreaStyle.text.color
      font.pointSize: DroppableTextAreaStyle.text.pointSize
      rightPadding: fileChooserButton.width +
        fileChooserButton.anchors.rightMargin +
        DroppableTextAreaStyle.fileChooserButton.margins
      selectByMouse: true
      wrapMode: TextArea.Wrap

      // Workaround. Without this line, the scrollbar is not linked correctly
      // to the text area.
      width: parent.width

      Component.onCompleted: forceActiveFocus()

      Keys.onPressed: {
        if (event.matches(StandardKey.InsertLineSeparator)) {
          insert(cursorPosition, '')
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          handleValidation()
          event.accepted = true
        }
      }
    }
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
    enabled: droppableTextArea.dropEnabled
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
      text: droppableTextArea.dropEnabled
        ? qsTr('attachmentTooltip')
        : droppableTextArea.dropDisabledReason
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
      font.pointSize: DroppableTextAreaStyle.hoverContent.text.pointSize
      text: qsTr('dropYourAttachment')
    }
  }

  DropArea {
    anchors.fill: parent
    keys: [ 'text/uri-list' ]
    visible: droppableTextArea.dropEnabled

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
