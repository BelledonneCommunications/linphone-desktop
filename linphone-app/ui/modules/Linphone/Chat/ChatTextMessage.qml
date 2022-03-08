import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import ColorsList 1.0

import 'Message.js' as Logic
// TODO : into Loader
// =============================================================================
TextEdit {
	id: message
	property ContentModel contentModel
	property string lastTextSelected : ''
	property font customFont : SettingsModel.textMessageFont
	property int fitHeight: visible ? contentHeight + padding + 8 : 0
	property int fitWidth: visible ? implicitWidth + 2: 0	// add 2 because there is a bug on border that lead to not fit text exactly
	
	signal rightClicked()
	
	
	property int removeWarningFromBindingLoop : implicitWidth	// Just a dummy variable to remove meaningless binding loop on implicitWidth
	
	height: fitHeight
	width: parent.width
	visible: contentModel && contentModel.isText()
	clip: true
	padding: ChatStyle.entry.message.padding
	textMargin: 0
	readOnly: true
	selectByMouse: true
	font.family: customFont.family
	font.pointSize: Units.dp * customFont.pointSize
	
	text: visible ? Utils.encodeTextToQmlRichFormat(contentModel.text, {
														imagesHeight: ChatStyle.entry.message.images.height,
														imagesWidth: ChatStyle.entry.message.images.width
													})
				  : ''
	
	// See http://doc.qt.io/qt-5/qml-qtquick-text.html#textFormat-prop
	// and http://doc.qt.io/qt-5/richtext-html-subset.html
	textFormat: Text.RichText // To supports links and imgs.
	wrapMode: TextEdit.Wrap
	
	//onCursorRectangleChanged: if(!readOnly) Logic.ensureVisible(cursorRectangle)
	onLinkActivated: Qt.openUrlExternally(link)
	onSelectedTextChanged:{
							if(selectedText != '') lastTextSelected = selectedText
							else {
								if( mouseArea.keepLastSelection) {
									mouseArea.keepLastSelection = false
									select(mouseArea.lastStartSelection, mouseArea.lastEndSelection)
								}
							}
						}
	onActiveFocusChanged: {
		if(activeFocus) {
			lastTextSelected = ''
			mouseArea.keepLastSelection = false
		}
		deselect()
	}
	
	MouseArea {
		id: mouseArea
		property bool keepLastSelection: false
		property int lastStartSelection:0
		property int lastEndSelection:0
		anchors.fill: parent
		propagateComposedEvents: true
		hoverEnabled: false
		scrollGestureEnabled: false
		cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
		acceptedButtons: Qt.RightButton
		onClicked: {
				if(!keepLastSelection) {
					lastStartSelection = parent.selectionStart
					lastEndSelection = parent.selectionEnd
				}
				keepLastSelection = true
				message.rightClicked()
				mouse.accepted = true
		}
	}
}
