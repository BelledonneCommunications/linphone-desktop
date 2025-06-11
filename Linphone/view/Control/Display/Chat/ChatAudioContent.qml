import QtQuick
import QtQuick.Layouts

import Linphone

import UtilsCpp

// =============================================================================

Loader{
	id: mainItem
	property ChatMessageContentGui chatMessageContentGui
	property int availableWidth : parent.width
	
	// property string filePath : tempFile.filePath
	
	active: chatMessageContentGui && chatMessageContentGui.core.isVoiceRecording
	
	// onChatMessageContentGuiChanged: if(chatMessageContentGui){
	// 	tempFile.createFileFromContentModel(chatMessageContentGui, false);
	// }
	
	// TemporaryFile {
	// 	id: tempFile
	// }
	
	sourceComponent: Item {
		id: loadedItem
		property bool isPlaying : soundPlayerGui && soundPlayerGui.core.playbackState === LinphoneEnums.PlaybackState.PlayingState
		onIsPlayingChanged: isPlaying ? mediaProgressBar.resume() : mediaProgressBar.stop()
		
		width: mainItem.width
		height: mainItem.height
		
		clip: false

		SoundPlayerGui {
			id: soundPlayerGui
			property int duration: mainItem.chatMessageContentGui ? mainItem.chatMessageContentGui.core.fileDuration : core.duration
			property int position: core.position
			source: mainItem.chatMessageContentGui && mainItem.chatMessageContentGui.core.filePath

			function play(){
				if(loadedItem.isPlaying){// Pause the play
					soundPlayerGui.core.lPause()
				}else{// Play the audio
					soundPlayerGui.core.lPlay()
				}
			}
			onStopped: {
				mediaProgressBar.value = 101
			}
			onPositionChanged: {
				mediaProgressBar.progressPosition = position
				mediaProgressBar.value = 100 * ( mediaProgressBar.progressPosition / duration)
			}
			onSourceChanged: if (source != "") {
				// core.lPlay()// This will open the file and allow seeking
				// core.lPause()
				core.lOpen()
				mediaProgressBar.value = 0
				mediaProgressBar.refresh()
			}
		}
		

		MediaProgressBar{
			id: mediaProgressBar
			anchors.fill: parent
			progressDuration: soundPlayerGui ? soundPlayerGui.duration : chatMessageContentGui.core.fileDuration
			progressPosition: 0
			value: 0
			function refresh(){
				if(soundPlayerGui){
					soundPlayerGui.core.lRefreshPosition()
				}
			}
			onEndReached:{
				if(soundPlayerGui)
					soundPlayerGui.core.lStop()
			}
			onPlayStopButtonToggled: soundPlayerGui.play()
			onRefreshPositionRequested: refresh()
			onSeekRequested: (ms) => {
				if(soundPlayerGui) {
					soundPlayerGui.core.lSeek(ms)
				}
			}
		}
	}
}
