import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// Helper to build quickly dialogs.
// =============================================================================

Rectangle {
  id: dialog

  property alias buttons: buttonsView.data // Optionnal.
  property alias title : titleBar.text	//Optionnal. Show a title bar with a close button.
  property alias descriptionText: description.text // Optionnal.
  property int buttonsAlignment : Qt.AlignLeft  
  property bool flat : false
	
  property bool showMargins: !flat
  property bool expandHeight: flat
  property alias showCloseCross : titleBar.showCloseCross
  property alias showTitleBar: titleBar.showBar
  property alias showButtons: buttonsView.visible
  
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
  property alias foregroundItem: foregroundItemData.data

  readonly property bool contentIsEmpty: {
    return _content == null || !_content.length
  }

  // ---------------------------------------------------------------------------

  signal exitStatus (var status)

  // ---------------------------------------------------------------------------

  function exit (status) {
      exitStatus(status)
  }

  // ---------------------------------------------------------------------------

  color: DialogStyle.colorModel.color

  layer {
	enabled: !dialog.flat
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
		flat: dialog.flat
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
      Layout.topMargin: (showMargins ? titleBar.showBar ? 1 : 2 : 0) * DialogStyle.content.topMargin
      Layout.bottomMargin: (showMargins ? DialogStyle.content.bottomMargin : 0)
	  Layout.leftMargin: (showMargins ? DialogStyle.content.leftMargin : 0)
	  Layout.rightMargin: (showMargins ? DialogStyle.content.rightMargin : 0)
    }

    RowLayout {
      id: buttonsView

      Layout.alignment: buttonsAlignment
      Layout.bottomMargin: DialogStyle.buttons.bottomMargin
      Layout.leftMargin: buttonsLeftMargin
	  Layout.rightMargin: buttonsRightMargin
      Layout.topMargin: DialogStyle.buttons.topMargin
      spacing: DialogStyle.buttons.spacing
	  visible: children.length>0
    }
  }
  Item{
	id: foregroundItemData
	anchors.fill: parent
  }
}
