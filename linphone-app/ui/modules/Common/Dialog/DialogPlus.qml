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
  property alias title : titleBar.text	//Optionnal. Show a title bar with a close button.
  property alias descriptionText: description.text // Optionnal.
  property int buttonsAlignment : Qt.AlignLeft
  property bool flat : false	// Remove margins

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
	
	DialogTitle{
		id:titleBar
		//Layout.fillHeight: dialog.contentIsEmpty
		Layout.fillWidth: true
		onClose: exitStatus(0)
		
	}
    DialogDescription {
      id: description

      Layout.fillHeight: dialog.contentIsEmpty
      Layout.fillWidth: true
	  visible: text!=''
    }

    Item {
      id: content

	  Layout.fillHeight: (flat ? true : !dialog.contentIsEmpty)
      Layout.fillWidth: true
	  Layout.leftMargin: (flat ? 0 : DialogStyle.content.leftMargin)
	  Layout.rightMargin: (flat ? 0 : DialogStyle.content.rightMargin)
    }

    Row {
      id: buttons

      Layout.alignment: buttonsAlignment
      Layout.bottomMargin: DialogStyle.buttons.bottomMargin
      Layout.leftMargin: buttonsAlignment == Qt.AlignLeft
        ? DialogStyle.buttons.leftMargin
        : buttonsAlignment == Qt.AlignRight
			? DialogStyle.buttons.rightMargin
			: undefined
	  Layout.rightMargin: DialogStyle.buttons.rightMargin
      Layout.topMargin: DialogStyle.buttons.topMargin
      spacing: DialogStyle.buttons.spacing
	  visible: children.length>0
    }
  }
}
