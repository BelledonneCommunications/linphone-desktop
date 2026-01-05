import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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
	property int maxWidth
	
	spacing: Utils.getSizeWithScreenRatio(5)

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
			width: Utils.getSizeWithScreenRatio(269)
			height: Utils.getSizeWithScreenRatio(48)
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
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(490)
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
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignHCenter
		fillMode: Image.PreserveAspectFit
	}
	AnimatedImageFileView {
		id: singleAnimatedImageFile
		visible: mainItem.filescontentProxy.count === 1 && source !== "" && UtilsCpp.isAnimatedImage(contentGui.core.filePath)
		contentGui: mainItem.filescontentProxy.count === 1
			? mainItem.filescontentProxy.getChatMessageContentAtIndex(0)
			: null
		Layout.fillWidth: true
		Layout.preferredHeight: paintedHeight
		Layout.alignment: Qt.AlignHCenter
		fillMode: Image.PreserveAspectFit
	}
	VideoFileView {
		id: singleVideoFile
		visible: mainItem.filescontentProxy.count === 1 && UtilsCpp.isVideo(contentGui.core.filePath)
		contentGui: mainItem.filescontentProxy.count === 1
			? mainItem.filescontentProxy.getChatMessageContentAtIndex(0)
			: null
		Layout.fillWidth: true
		width: Math.min(Utils.getSizeWithScreenRatio(285), mainItem.maxWidth)
		height: Math.min(Utils.getSizeWithScreenRatio(285), mainItem.maxWidth)
		Layout.preferredWidth: videoOutput.contentRect.width
		Layout.preferredHeight: videoOutput.contentRect.height
		Layout.alignment: Qt.AlignHCenter
		fillMode: VideoOutput.PreserveAspectFit
	}

	// FILES
	ChatFilesGridLayout {
		id: messageFilesList
		visible: mainItem.filescontentProxy.count > 0 
		&& !singleImageFile.visible 
		&& !singleAnimatedImageFile.visible
		&& !singleVideoFile.visible
		Layout.fillWidth: visible
		Layout.fillHeight: visible
		maxWidth: Utils.getSizeWithScreenRatio(115*3)
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
