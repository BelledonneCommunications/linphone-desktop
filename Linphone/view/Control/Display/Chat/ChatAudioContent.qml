import QtQuick
import QtQuick.Layouts

import Linphone

import UtilsCpp

// =============================================================================

Item {
	id: mainItem
	property ChatMessageContentGui chatMessageContentGui
	property var chatMessageObj
	property ChatMessageGui chatMessage: chatMessageObj && chatMessageObj.value || null
	property bool isPlaying : soudPlayerLoader.item && soudPlayerLoader.item.core.playbackState === LinphoneEnums.PlaybackState.PlayingState
	onIsPlayingChanged: isPlaying ? mediaProgressBar.resume() : mediaProgressBar.stop()
	property bool recording: false
	property RecorderGui recorderGui: recorderLoader.item || null

	signal voiceRecordingMessageCreationRequested(RecorderGui recorderGui)
	signal stopRecording()

	function createVoiceMessageInChat(chat) {
		if (recorderLoader.item) {
			mainItem.chatMessageObj = UtilsCpp.createVoiceRecordingMessage(recorderLoader.item, chat)
		} else {
			//: Error
			UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
			//: Failed to create voice message : error in recorder
			qsTr("information_popup_voice_message_error_message"), false)
		}
	}

	Loader {
		id: soudPlayerLoader
		property int duration: mainItem.chatMessageContentGui 
			? mainItem.chatMessageContentGui.core.fileDuration 
			: item
				? item.core.duration
				: 0
		property int position: item?.core.position || 0
		active: mainItem.chatMessageContentGui && mainItem.chatMessageContentGui.core.isVoiceRecording
		sourceComponent: SoundPlayerGui {
			id: soundPlayerGui
			source: mainItem.chatMessageContentGui && mainItem.chatMessageContentGui.core.filePath

			function play(){
				if(mainItem.isPlaying){// Pause the play
					soundPlayerGui.core.lPause()
				}else{// Play the audio
					soundPlayerGui.core.lPlay()
				}
			}
			onStopped: {
				mediaProgressBar.value = 101
			}
			onPositionChanged: {
				mediaProgressBar.progressPosition = soudPlayerLoader.position
				mediaProgressBar.value = 100 * ( mediaProgressBar.progressPosition / soudPlayerLoader.duration)
			}
			onSourceChanged: if (source != "") {
				core.lOpen() // Open the file and allow seeking
				mediaProgressBar.value = 0
				mediaProgressBar.refresh()
			}
			onErrorChanged: (error) => {
				//: Error
				UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"), error, false)
			}
		}
	}
	
	Loader {
		id: recorderLoader
		active: mainItem.recording && !mainItem.chatMessageContentGui
		property int duration: item?.core.duration || 0
		property int captureVolume: item?.core.captureVolume || 0
		property var state: item?.core.state

		Connections {
			target: mainItem
			function onStopRecording() {
				recorderLoader.item.core.lStop()
			}
		}

		sourceComponent: RecorderGui {
			id: recorderGui
			onReady: core.lStart()
			onStateChanged: (state) => {
				if (state === LinphoneEnums.RecorderState.Running) mediaProgressBar.start()
				if (state === LinphoneEnums.RecorderState.Closed) {
					mediaProgressBar.stop()
					mainItem.voiceRecordingMessageCreationRequested(recorderGui)
				}
			}
		}
	}

	MediaProgressBar{
		id: mediaProgressBar
		anchors.fill: parent
		progressDuration: soudPlayerLoader.active 
			? soudPlayerLoader.duration 
			: recorderLoader
				? recorderLoader.duration
				: chatMessageContentGui.core.fileDuration
		progressPosition: 0
		value: 0
		recording: recorderLoader.state === LinphoneEnums.RecorderState.Running
		function refresh(){
			if(soudPlayerLoader.item){
				soudPlayerLoader.item.core.lRefreshPosition()
			} else if (recorderLoader.item) {
				recorderLoader.item.core.lRefresh()
			}
		}
		onEndReached:{
			if(soudPlayerLoader.item)
				soudPlayerLoader.item.core.lStop()
		}
		onPlayStopButtonToggled: {
			if(soudPlayerLoader.item) {
				soudPlayerLoader.item.play()
			} else if (recorderLoader.item) {
				recorderLoader.item.core.lStop()
			}
		}
		onRefreshPositionRequested: refresh()
		onSeekRequested: (ms) => {
			if(soudPlayerLoader.active) {
				soudPlayerLoader.item.core.lSeek(ms)
			}
		}
	}
}