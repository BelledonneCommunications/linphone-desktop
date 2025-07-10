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
	property ChatGui chatGui: null
	
	signal isFileHoveringChanged(bool isFileHovering)
	signal lastSelectedTextChanged(string selectedText)
	// signal conferenceIcsCopied()
	signal mouseEvent(MouseEvent event)
	signal endOfVoiceRecordingReached()
	signal requestAutoPlayVoiceRecording()
	property string selectedText
	
	property color textColor
	property string searchedTextPart
	
	property int fileBorderWidth : 0
	
	spacing: Math.round(5 * DefaultStyle.dp)
	property int padding: Math.round(10 * DefaultStyle.dp)

	// VOICE MESSAGES
	Repeater {
		id: messagesVoicesList
		visible: count > 0
		model: ChatMessageContentProxy{
			filterType: ChatMessageContentProxy.FilterContentType.Voice
			chatMessageGui: mainItem.chatMessageGui
		}
		delegate: ChatAudioContent {
			id: audioContent
			// Layout.fillWidth: true
			width: Math.round(269 * DefaultStyle.dp)
			height: Math.round(48 * DefaultStyle.dp)
			Layout.preferredHeight: height
			chatMessageContentGui: modelData
			onEndOfFileReached: mainItem.endOfVoiceRecordingReached()
			Connections {
				target: mainItem
				function onRequestAutoPlayVoiceRecording() {
					audioContent.requestPlaying()
				}
			}
			// width: conferenceList.width
			// onMouseEvent: (event) => mainItem.mouseEvent(event)
		}
	}
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
			chatGui: mainItem.chatGui
			searchedTextPart: mainItem.searchedTextPart
			onLastTextSelectedChanged: mainItem.selectedText = selectedText
			// onRightClicked: mainItem.rightClicked()
		}
	}
}
