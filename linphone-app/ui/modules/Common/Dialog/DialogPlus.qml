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
  property bool expandHeight: flat
  property alias showCloseCross : titleBar.showCloseCross
  
  property int buttonsLeftMargin :(buttonsAlignment & Qt.AlignLeft )== Qt.AlignLeft
        ? DialogStyle.buttons.leftMargin
        : (buttonsAlignment & Qt.AlignRight) == Qt.AlignRight
			? DialogStyle.buttons.rightMargin
			: DialogStyle.buttons.leftMargin
  property int buttonsRightMargin : (buttonsAlignment & Qt.AlignRight )== Qt.AlignRight
        ? DialogStyle.buttons.rightMargin
        : (buttonsAlignment & Qt.AlignLeft) == Qt.AlignLeft
			? DialogStyle.buttons.leftMargin
			: DialogStyle.buttons.rightMargin

  default property alias _content: content.data

  readonly property bool contentIsEmpty: {
    return _content == null || !_content.length
  }

  // ---------------------------------------------------------------------------

  signal exitStatus (int status)

  // ---------------------------------------------------------------------------

  function exit (status) {
      exitStatus(status)
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
		showCloseCross:dialog.showCloseCross
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

	  Layout.fillHeight: (expandHeight ? true : !dialog.contentIsEmpty)
      Layout.fillWidth: true
	  Layout.leftMargin: (flat ? 0 : DialogStyle.content.leftMargin)
	  Layout.rightMargin: (flat ? 0 : DialogStyle.content.rightMargin)
    }

    RowLayout {
      id: buttons

      Layout.alignment: buttonsAlignment
      Layout.bottomMargin: DialogStyle.buttons.bottomMargin
      Layout.leftMargin: buttonsLeftMargin
	  Layout.rightMargin: buttonsRightMargin
      Layout.topMargin: DialogStyle.buttons.topMargin
      spacing: DialogStyle.buttons.spacing
	  visible: children.length>0
    }
  }
}
