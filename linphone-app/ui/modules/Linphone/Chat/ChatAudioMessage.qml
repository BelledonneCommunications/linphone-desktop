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

// =============================================================================



Loader{
	id: mainItem
	property ContentModel contentModel
	property int availableWidth : parent.width
	property int fitWidth: active ? Math.max(availableWidth - ChatAudioMessageStyle.emptySpace, ChatAudioMessageStyle.minWidth) : 0
	property int fitHeight: active ? 60 : 0
	
	property font customFont : SettingsModel.textMessageFont
	property bool isOutgoing : contentModel && contentModel.chatMessageModel && (contentModel.chatMessageModel.isOutgoing  || contentModel.chatMessageModel.state == LinphoneEnums.ChatMessageStateIdle);
	property bool isActive: active
	
	property string filePath : tempFile.filePath
	
	active: contentModel && contentModel.isVoiceRecording()
	
	onContentModelChanged: if(contentModel){
		tempFile.createFileFromContentModel(contentModel, false);
	}
	
	TemporaryFile {
		id: tempFile
	}
	
	sourceComponent: Item{
		id: loadedItem
		property bool isPlaying : vocalPlayer.item && vocalPlayer.item.playbackState === SoundPlayer.PlayingState
		onIsPlayingChanged: isPlaying ? mediaProgressBar.resume() : mediaProgressBar.stop()
		
		width: availableWidth < 0 || availableWidth > fitWidth ? fitWidth : availableWidth
		height: mainItem.fitHeight
		
		clip: false
		Loader {
			id: vocalPlayer
			
			active: false
			function play(){
				if(!vocalPlayer.active)
					vocalPlayer.active = true
				else {
					if(loadedItem.isPlaying){// Pause the play
						vocalPlayer.item.pause()
					}else{// Play the audio
						vocalPlayer.item.play()
					}
				}
			}
			sourceComponent: SoundPlayer {
				source: mainItem.contentModel && mainItem.filePath
				onStopped:{
					mediaProgressBar.value = 101
				}
				Component.onCompleted: {
					play()// This will open the file and allow seeking
					pause()
					mediaProgressBar.value = 0
					mediaProgressBar.refresh()
				}
			}
			onStatusChanged: if (loader.status == Loader.Ready) play()
		}
		RowLayout{
			id: lineLayout
			anchors.fill: parent
			spacing: 5
			ActionButton{
				id: playButton
				Layout.preferredHeight: iconSize
				Layout.preferredWidth: iconSize
				Layout.rightMargin: 5
				Layout.leftMargin: 15
				Layout.alignment: Qt.AlignVCenter
				isCustom: true
				backgroundRadius: width
				colorSet:  (loadedItem.isPlaying ? ChatAudioMessageStyle.pauseAction
												 : ChatAudioMessageStyle.playAction)
				onClicked:{
					vocalPlayer.play()
				}
			}
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
				Layout.rightMargin: 10
				Layout.topMargin: 10
				Layout.bottomMargin: 10
				MediaProgressBar{
					id: mediaProgressBar
					anchors.fill: parent
					progressDuration: vocalPlayer.item ? vocalPlayer.item.duration : contentModel.getFileDuration()
					progressPosition: 0
					value: 0
					stopAtEnd: true 
					resetAtEnd: false
					backgroundColor: ChatAudioMessageStyle.backgroundColor.color
					colorSet: ChatAudioMessageStyle.progressionWave
					durationTextColor: mainItem.isOutgoing ? ChatStyle.entry.message.outgoing.text.colorModel.color : ChatStyle.entry.message.incoming.text.colorModel.color
					function refresh(){
						if( vocalPlayer.item){
							progressPosition = vocalPlayer.item.getPosition()
							value = 100 * ( progressPosition / vocalPlayer.item.duration)
						}
					}
					onEndReached:{
						if(vocalPlayer.item)
							vocalPlayer.item.stop()
					}
					onRefreshPositionRequested: refresh()
					onSeekRequested: if(  vocalPlayer.item){
										 vocalPlayer.item.seek(ms)
										 progressPosition = vocalPlayer.item.getPosition()
										 value = 100 * (progressPosition / vocalPlayer.item.duration)
									 }
				}
			}
			
		}
	}
}
