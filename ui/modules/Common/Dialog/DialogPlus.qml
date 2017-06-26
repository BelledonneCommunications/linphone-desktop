import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// Helper to build quickly dialogs.
// =============================================================================

Rectangle {
  id: dialog

  property alias buttons: buttons.data // Optionnal.
  property alias descriptionText: description.text // Optionnal.
  property bool centeredButtons: false

  default property alias _content: content.data
  property bool _disableExitStatus

  readonly property bool contentIsEmpty: {
    return _content == null || !_content.length
  }

  // ---------------------------------------------------------------------------

  signal exitStatus (int status)

  // ---------------------------------------------------------------------------

  function exit (status) {
    if (!_disableExitStatus) {
      _disableExitStatus = true
      exitStatus(status)
    }
  }

  // ---------------------------------------------------------------------------

  color: DialogStyle.color

  layer {
    enabled: true
    effect: PopupShadow {}
  }

  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: exit(0)
  }

  // ---------------------------------------------------------------------------

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    DialogDescription {
      id: description

      Layout.fillHeight: dialog.contentIsEmpty
      Layout.fillWidth: true
    }

    Item {
      id: content

      Layout.fillHeight: !dialog.contentIsEmpty
      Layout.fillWidth: true
      Layout.leftMargin: DialogStyle.content.leftMargin
      Layout.rightMargin: DialogStyle.content.rightMargin
    }

    Row {
      id: buttons

      Layout.alignment: centeredButtons
        ? Qt.AlignHCenter
        : Qt.AlignLeft
      Layout.bottomMargin: DialogStyle.buttons.bottomMargin
      Layout.leftMargin: !centeredButtons
        ? DialogStyle.buttons.leftMargin
        : undefined
      Layout.topMargin: DialogStyle.buttons.topMargin
      spacing: DialogStyle.buttons.spacing
    }
  }
}
