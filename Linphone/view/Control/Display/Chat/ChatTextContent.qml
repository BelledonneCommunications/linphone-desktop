import QtQuick
import QtQuick.Layouts

import Linphone

import UtilsCpp


// TODO : into Loader
// =============================================================================
TextEdit {
	id: message
	property ChatMessageContentGui contentGui
	property string lastTextSelected : ''
	color: DefaultStyle.main2_700
	font {
		pixelSize: (contentGui && UtilsCpp.isOnlyEmojis(contentGui.core.text)) ? Typography.h1.pixelSize : Typography.p1.pixelSize
		weight: Typography.p1.weight
	}	
	// property int removeWarningFromBindingLoop : implicitWidth	// Just a dummy variable to remove meaningless binding loop on implicitWidth
	
	visible: contentGui && contentGui.core.isText
	textMargin: 0
	readOnly: true
	selectByMouse: true
	
	text: visible ? UtilsCpp.encodeTextToQmlRichFormat(contentGui.core.utf8Text)
				  : ''
	
	textFormat: Text.RichText // To supports links and imgs.
	wrapMode: TextEdit.Wrap
	
	onLinkActivated: (link) => {
		if (link.startsWith('sip'))
			UtilsCpp.createCall(link)
		else
			Qt.openUrlExternally(link)
	}
	onSelectedTextChanged:{
		if(selectedText != '') lastTextSelected = selectedText
		// else {
		// 	if(mouseArea.keepLastSelection) {
		// 		mouseArea.keepLastSelection = false
		// 	}
		// }
	}
	onActiveFocusChanged: {
		if(activeFocus) {
			lastTextSelected = ''
		}
		else mouseArea.keepLastSelection = false
		// deselect()
	}
	MouseArea {
		id: mouseArea
		property bool keepLastSelection: false
		property int lastStartSelection:0
		property int lastEndSelection:0
		anchors.fill: parent
		propagateComposedEvents: true
		hoverEnabled: true
		scrollGestureEnabled: false
		cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
		acceptedButtons: Qt.LeftButton
		onPressed: (mouse) => {
		// 	if(!keepLastSelection) {
		// 		lastStartSelection = parent.selectionStart
		// 		lastEndSelection = parent.selectionEnd
		// 	}
			keepLastSelection = true
			mouse.accepted = false
		}
	}
}
