import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone

// =============================================================================
// Simple content display without reply and forward. These modules need to be splitted because of cyclic dependencies.
// See ChatFullContent

ColumnLayout {
	id: mainItem
	property ChatMessageGui chatMessageGui: null
	
	signal isFileHoveringChanged(bool isFileHovering)
	signal lastSelectedTextChanged(string selectedText)
	// signal conferenceIcsCopied()
	signal mouseEvent(MouseEvent event)
	property string selectedText
	
	property color textColor
	
	property int fileBorderWidth : 0
	
	spacing: Math.round(5 * DefaultStyle.dp)
	property int padding: Math.round(10 * DefaultStyle.dp)

	// VOICE MESSAGES
	// ListView {
	// 	id: messagesVoicesList
	// 	width: parent.width-2*mainItem.padding
	// 	visible: count > 0
	// 	spacing: 0
	// 	clip: false
	// 	model: ChatMessageContentProxy {
	// 		filterType: ChatMessageContentProxy.FilterContentType.Voice
	// 		chatMessageGui: mainItem.chatMessageGui
	// 	}
	// 	height: contentHeight
	// 	boundsBehavior: Flickable.StopAtBounds
	// 	interactive: false
	// 	function updateBestWidth(){
	// 		var newWidth = mainItem.updateListBestWidth(messagesVoicesList)
	// 		mainItem.voicesCount = newWidth[0]
	// 		mainItem.voicesBestWidth = newWidth[1]
	// 	}
	// 	delegate: ChatAudioMessage{
	// 		id: audioMessage
	// 		contentModel: $modelData
	// 		visible: contentModel
	// 		z: 1
	// 		Component.onCompleted: messagesVoicesList.updateBestWidth()
	// 	}
	// 	Component.onCompleted: messagesVoicesList.updateBestWidth
	// }
	// CONFERENCE
	Repeater {
		id: conferenceList
		visible: count > 0
		model: ChatMessageContentProxy{
			filterType: ChatMessageContentProxy.FilterContentType.Conference
			chatMessageGui: mainItem.chatMessageGui
		}
		delegate: ChatMessageInvitationBubble {
			Layout.fillWidth: true
			conferenceInfoGui: modelData.core.conferenceInfo
			// width: conferenceList.width
			onMouseEvent: (event) => mainItem.mouseEvent(event)
		}
	}
	// FILES
	ChatFilesGridLayout {
		id: messageFilesList
		visible: itemCount > 0
		Layout.fillWidth: true
		maxWidth: Math.round(115*3 * DefaultStyle.dp)
		Layout.fillHeight: true
		// Layout.preferredHeight: contentHeight
		chatMessageGui: mainItem.chatMessageGui
		// onIsHoveringFileChanged: mainItem.isHoveringFile = isHoveringFile
		onIsHoveringFileChanged: mainItem.isFileHoveringChanged(isHoveringFile)
				// borderWidth: mainItem.fileBorderWidth
		// property int availableSection: mainItem.availableWidth / mainItem.filesBestWidth
		// property int bestFitSection: mainItem.bestWidth / mainItem.filesBestWidth
		// columns: Math.max(1, Math.min(availableSection , bestFitSection))
		// columnSpacing: 0
		// rowSpacing: ChatStyle.entry.message.file.spacing
	}
	// TEXTS
	Repeater {
		id: messagesTextsList
		visible: count > 0
		model: ChatMessageContentProxy {
			filterType: ChatMessageContentProxy.FilterContentType.Text
			chatMessageGui: mainItem.chatMessageGui
		}
		delegate: ChatTextContent {
			Layout.fillWidth: true
			// height: implicitHeight
			contentGui: modelData
			onLastTextSelectedChanged: mainItem.selectedText = selectedText
			// onRightClicked: mainItem.rightClicked()
		}
	}
}
