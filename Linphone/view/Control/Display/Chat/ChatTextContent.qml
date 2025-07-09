import QtQuick
import QtQuick.Layouts

import Linphone

import UtilsCpp


// TODO : into Loader
// =============================================================================
TextEdit {
	id: mainItem
	property ChatMessageContentGui contentGui
	property ChatGui chatGui: null
	property string lastTextSelected : ''
	property string searchedTextPart
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
	
	property var encodeTextObj: visible ? UtilsCpp.encodeTextToQmlRichFormat(contentGui.core.utf8Text, {}, mainItem.chatGui)
				  : ''
	text: encodeTextObj 
		&& (searchedTextPart !== "" 
			? UtilsCpp.boldTextPart(encodeTextObj.value, searchedTextPart)
			:  encodeTextObj.value) 
		|| ""	
	textFormat: Text.RichText // To supports links and imgs.
	wrapMode: TextEdit.Wrap
	
	onLinkActivated: (link) => {
		if (link.startsWith('sip'))
			UtilsCpp.createCall(link)
		else if (link.startsWith('mention:')) {
			var mentionAddress = link.substring(8) // remove "mention:"
			UtilsCpp.openContactAtAddress(mentionAddress);
		}
		else
			Qt.openUrlExternally(link)
	}
	onSelectedTextChanged:{
		if(selectedText != '') lastTextSelected = selectedText
	}
	onLinkHovered: {
		if (hoveredLink !== "") UtilsCpp.setGlobalCursor(Qt.PointingHandCursor)
		else UtilsCpp.restoreGlobalCursor()
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
