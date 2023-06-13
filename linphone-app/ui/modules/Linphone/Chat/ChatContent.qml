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

// =============================================================================
// Simple content display without reply and forward. These modules need to be splitted because of cyclic dependencies.
// See ChatFullContent

Loader{// Use of Loader because of Repeater (items cannot be loaded dynamically)
	id: mainItem
	property ChatMessageModel chatMessageModel: null
	property int availableWidth	//const
	property int fileWidth: FileViewStyle.height * 4 / 3 + 2*ChatStyle.entry.message.file.margins
	
	// Readonly
	property int bestWidth: Math.min(availableWidth, Math.max(filesCount*filesBestWidth, conferencesBestWidth, textsBestWidth, voicesBestWidth))
	property int filesBestWidth: 0
	property int filesCount: 0
	property int conferencesCount: 0
	property int conferencesBestWidth: 0
	property int textsBestWidth: 0
	property int textsCount: 0
	property int voicesBestWidth: 0
	property int voicesCount: 0
	
	signal isFileHoveringChanged(bool isFileHovering)
	signal lastTextSelectedChanged(string lastTextSelected)
	signal rightClicked()
	signal conferenceIcsCopied()
	
	property bool useTextColor: false
	property color textColor
	
	property int fileBorderWidth : 0
	property color fileBackgroundColor: ChatStyle.entry.message.file.extension.background.colorModel.color
	property int fileBackgroundRadius: ChatStyle.entry.message.file.extension.radius
	
	active: chatMessageModel
		
	sourceComponent: Component{
		Column{
			id: mainComponent
			spacing: 5
			padding: 10
			function updateFilesBestWidth(){
				var newBestWidth = 0
				var count = 0
				for(var child in messageFilesList.children) {
					var item = messageFilesList.children[child]
					if(item){
						var a = item.fitWidth
						if(a) {
							++count
							newBestWidth = Math.max(newBestWidth,a+2*ChatStyle.entry.message.file.margins)
						}
					}
				}
				mainItem.filesCount = count
				mainItem.filesBestWidth = newBestWidth
			}
			function updateListBestWidth(listView){
				var newBestWidth = 0
				var count = 0
				for(var child in listView.contentItem.children) {
					var a = listView.contentItem.children[child].fitWidth
					if(a) {
						++count
						newBestWidth = Math.max(newBestWidth,a)
					}
				}
				return [count, newBestWidth];
			}
			ListView {
				id: messagesVoicesList
				width: parent.width-2*mainComponent.padding
				visible: count > 0
				spacing: 0
				clip: false
				model: ContentProxyModel{
					filter: ContentProxyModel.ContentType.Voice
					chatMessageModel: mainItem.chatMessageModel
				}
				height: contentHeight
				boundsBehavior: Flickable.StopAtBounds
				interactive: false
				function updateBestWidth(){
					var newWidth = mainComponent.updateListBestWidth(messagesVoicesList)
					mainItem.voicesCount = newWidth[0]
					mainItem.voicesBestWidth = newWidth[1]
				}
				delegate: ChatAudioMessage{
					id: audioMessage
					contentModel: $modelData
					visible: contentModel
					z: 1
					Component.onCompleted: messagesVoicesList.updateBestWidth()
				}
				Component.onCompleted: messagesVoicesList.updateBestWidth
			}
// CONFERENCE
			ListView {
				id: messagesConferencesList
				width: parent.width-2*mainComponent.padding
				visible: count > 0
				spacing: 0
				clip: false
				model: ContentProxyModel{
					filter: ContentProxyModel.ContentType.Conference
					chatMessageModel: mainItem.chatMessageModel
				}
				height: contentHeight
				boundsBehavior: Flickable.StopAtBounds
				interactive: false
				function updateBestWidth(){
					var newWidth = mainComponent.updateListBestWidth(messagesConferencesList)
					mainItem.conferencesCount = newWidth[0]
					mainItem.conferencesBestWidth = newWidth[1]
				}
				Component.onCompleted: messagesConferencesList.updateBestWidth()
				delegate: ChatConferenceInvitationMessage{
					id: calendarMessage
					contentModel: $modelData
					width: parent && parent.width
					availableWidth: mainItem.availableWidth
					gotoButtonMode: 1
					onExpandToggle: isExpanded=!isExpanded
					height: fitHeight
					z: 1
					onConferenceIcsCopied:mainItem.conferenceIcsCopied()
					onFitWidthChanged: messagesConferencesList.updateBestWidth()
					Component.onCompleted: messagesConferencesList.updateBestWidth()
				}
			}
// FILES
			GridLayout {
				id: messageFilesList
				property alias count: repeater.count
				visible: count > 0
				clip: false
				width: parent.width-2*mainComponent.padding
				
				property int availableSection: mainItem.availableWidth / mainItem.filesBestWidth
				property int bestFitSection: mainItem.bestWidth / mainItem.filesBestWidth
				columns: Math.max(1, Math.min(availableSection , bestFitSection))
				columnSpacing: 0
				rowSpacing: ChatStyle.entry.message.file.spacing
				Repeater{
					id: repeater
					model: ContentProxyModel{
						filter: ContentProxyModel.ContentType.File
						chatMessageModel: mainItem.chatMessageModel
					}
					ChatFileMessage{
						id: fileMessage
						Layout.fillHeight: true
						Layout.fillWidth: true
						Layout.preferredHeight: fitHeight
						Layout.preferredWidth: fitWidth
						Layout.maximumWidth: fitWidth
						Layout.maximumHeight: fitHeight
						Layout.alignment: Qt.AlignHCenter
						contentModel: $modelData
						onIsHoveringChanged: mainItem.isFileHoveringChanged(isHovering)
						borderWidth: mainItem.fileBorderWidth
						backgroundColor: mainItem.fileBackgroundColor
						backgroundRadius: mainItem.fileBackgroundRadius
						Component.onCompleted: mainComponent.updateFilesBestWidth()
					}
				}
			}
// TEXTS
			ListView {
				id: messagesTextsList
				width: parent.width-2*mainComponent.padding
				visible: count > 0
				spacing: 0
				clip: false
				model: ContentProxyModel{
					filter: ContentProxyModel.ContentType.Text
					chatMessageModel: mainItem.chatMessageModel
				}
				height: contentHeight
				boundsBehavior: Flickable.StopAtBounds
				interactive: false
				function updateBestWidth(){
					var newWidth = mainComponent.updateListBestWidth(messagesTextsList)
					mainItem.textsCount = newWidth[0]
					// Padding is takken account because it is used for the whole bubble.
					// We add 1 pixel to avoid implicit new line computation (Guess : float computation from Qt)
					mainItem.textsBestWidth = newWidth[1] + 2*mainComponent.padding + 1
				}
				Component.onCompleted: messagesTextsList.updateBestWidth()
				delegate: 
					ChatTextMessage {
					width: parent ? parent.width : 0
					contentModel: $modelData
					onLastTextSelectedChanged: mainItem.lastTextSelectedChanged(lastTextSelected)
					color: mainItem.useTextColor
								? mainItem.textColor
								: $modelData.isOutgoing
									? ChatStyle.entry.message.outgoing.text.colorModel.color
									: ChatStyle.entry.message.incoming.text.colorModel.color
					onRightClicked: mainItem.rightClicked()
					onFitWidthChanged: messagesTextsList.updateBestWidth()
					Component.onCompleted: messagesTextsList.updateBestWidth()
				}
			}
		}
	}
}
