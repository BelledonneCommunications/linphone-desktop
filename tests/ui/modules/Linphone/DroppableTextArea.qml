import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

RowLayout {
  property alias placeholderText: textArea.placeholderText

  Flickable {
    Layout.preferredHeight: parent.height
    Layout.fillWidth: true
    ScrollBar.vertical: ScrollBar { }
    TextArea.flickable: TextArea {
      id: textArea

      wrapMode: TextArea.Wrap
    }
  }

  DropZone {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 40
  }
}
