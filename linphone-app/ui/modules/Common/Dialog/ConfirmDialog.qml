import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0


// =============================================================================
// A dialog with OK/Cancel buttons.
// =============================================================================

DialogPlus {
	id: mainItem
	property int showButtonOnly : -1
	property var buttonTexts : [qsTr('cancel')
		, qsTr('confirm')]
	buttons: [
		TextButtonA {
			text: mainItem.buttonTexts[0]
			visible: mainItem.showButtonOnly<0 || mainItem.showButtonOnly == 0
			onClicked: exit(0)
		},
		TextButtonB {
			text: mainItem.buttonTexts[1]
			visible: mainItem.showButtonOnly<0 || mainItem.showButtonOnly == 1
			onClicked: exit(1)
		},
		TextButtonB {
			text: mainItem.buttonTexts.length > 2 ? mainItem.buttonTexts[2] : ''
			visible: mainItem.buttonTexts.length > 2 && (mainItem.showButtonOnly<0 || mainItem.showButtonOnly == 2)
			onClicked: exit(2)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	
	height: DialogStyle.confirmDialog.height + 30
	width: Math.max(DialogStyle.confirmDialog.width, buttonTexts.length * 150 + DialogStyle.buttons.leftMargin + DialogStyle.buttons.rightMargin)
}
