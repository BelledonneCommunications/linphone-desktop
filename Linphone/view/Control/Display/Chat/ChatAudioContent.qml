import QtQuick
import QtQuick.Layouts

import Linphone

import UtilsCpp

// =============================================================================

Loader{
	id: mainItem
	property ChatMessageContentGui chatMessageContentGui
	property int availableWidth : parent.width
	property int width: active ? Math.max(availableWidth - ChatAudioMessageStyle.emptySpace, ChatAudioMessageStyle.minWidth) : 0
	property int fitHeight: active ? 60 : 0
	
	property font customFont : SettingsModel.textMessageFont
	property bool isActive: active
	
	property string filePath : tempFile.filePath
	
	active: chatMessageContentGui && chatMessageContentGui.core.isVoiceRecording()
	
	onChatMessageContentGuiChanged: if(chatMessageContentGui){
		tempFile.createFileFromContentModel(chatMessageContentGui, false);
	}
	
	TemporaryFile {
		id: tempFile
	}
	
	sourceComponent: Item{
		id: loadedItem
		property bool isPlaying : vocalPlayer.item && vocalPlayer.item.playbackState === SoundPlayer.PlayingState
		onIsPlayingChanged: isPlaying ? mediaProgressBar.resume() : mediaProgressBar.stop()
		
		width: availableWidth < 0 || availableWidth > mainItem.width ? mainItem.width : availableWidth
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
				source: mainItem.chatMessageContentGui && mainItem.filePath
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
					progressDuration: vocalPlayer.item ? vocalPlayer.item.duration : chatMessageContentGui.core.getFileDuration()
					progressPosition: 0
					value: 0
					stopAtEnd: true 
					resetAtEnd: false
					backgroundColor: ChatAudioMessageStyle.backgroundColor.color
					colorSet: ChatAudioMessageStyle.progressionWave
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
