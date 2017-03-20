import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// Helper to build quickly dialogs.
// =============================================================================

Rectangle {
  property alias buttons: buttons.data // Optionnal.
  property alias descriptionText: description.text // Optionnal.
  property bool centeredButtons: false

  default property alias _content: content.data // Required.
  property bool _disableExitStatus

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

      Layout.fillWidth: true
    }

    Item {
      id: content

      Layout.fillHeight: true
      Layout.fillWidth: true
    }

    Row {
      id: buttons

      Layout.alignment: centeredButtons
        ? Qt.AlignHCenter
        : Qt.AlignLeft
      Layout.bottomMargin: DialogStyle.buttons.bottomMargin
      Layout.leftMargin: !centeredButtons
        ? DialogStyle.leftMargin
        : undefined
      Layout.topMargin: DialogStyle.buttons.topMargin
      spacing: DialogStyle.buttons.spacing
    }
  }
}
