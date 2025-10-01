import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp

// =============================================================================
// Simple content display without reply and forward. These modules need to be splitted because of cyclic dependencies.
// See ChatFullContent

ColumnLayout {
	id: mainItem
	property ChatMessageGui chatMessageGui: null
    property bool isRemoteMessage: chatMessageGui? chatMessageGui.core.isRemoteMessage : false
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

	property ChatMessageContentProxy filescontentProxy: ChatMessageContentProxy {
		filterType: ChatMessageContentProxy.FilterContentType.File
		chatMessageGui: mainItem.chatMessageGui
	}
	
	// VOICE MESSAGES
	Repeater {
		id: messagesVoicesList
		visible: count > 0
		model: ChatMessageContentProxy {
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
			Layout.preferredWidth: 490 * DefaultStyle.dp
			conferenceInfoGui: modelData.core.conferenceInfo
			onMouseEvent: (event) => mainItem.mouseEvent(event)
		}
	}
	// SINGLE FILE
	ImageFileView {
		id: singleImageFile
		visible: mainItem.filescontentProxy.count === 1 && source !== "" && UtilsCpp.isImage(contentGui.core.filePath)
		contentGui: mainItem.filescontentProxy.count === 1
			? mainItem.filescontentProxy.getChatMessageContentAtIndex(0)
			: null
		width: Math.round(285 * DefaultStyle.dp)
		Layout.alignment: Qt.AlignHCenter
		fillMode: Image.PreserveAspectFit
	}
	AnimatedImageFileView {
		id: singleAnimatedImageFile
		visible: mainItem.filescontentProxy.count === 1 && source !== "" && UtilsCpp.isAnimatedImage(contentGui.core.filePath)
		contentGui: mainItem.filescontentProxy.count === 1
			? mainItem.filescontentProxy.getChatMessageContentAtIndex(0)
			: null
		Layout.preferredWidth: Math.round(285 * DefaultStyle.dp)
		Layout.preferredHeight: paintedHeight
		Layout.alignment: Qt.AlignHCenter
		fillMode: Image.PreserveAspectFit
	}
	// FILES
	ChatFilesGridLayout {
		id: messageFilesList
		visible: mainItem.filescontentProxy.count > 0 
		&& !singleImageFile.visible 
		&& !singleAnimatedImageFile.visible
		Layout.fillWidth: visible
		Layout.fillHeight: visible
		maxWidth: Math.round(115*3 * DefaultStyle.dp)
		// Layout.fillHeight: true
		proxyModel: visible ? mainItem.filescontentProxy : null
		// onIsHoveringFileChanged: mainItem.isFileHoveringChanged(isHoveringFile)
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
			horizontalAlignment: mainItem.isRemoteMessage || implicitWidth > mainItem.width ? TextEdit.AlignLeft : TextEdit.AlignRight
			// height: implicitHeight
			contentGui: modelData
			chatGui: mainItem.chatGui
			searchedTextPart: mainItem.searchedTextPart
			onLastTextSelectedChanged: mainItem.selectedText = selectedText
			// onRightClicked: mainItem.rightClicked()
		}
	}
}
