import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle{
	id: audioPreviewBlock
	property bool haveRecorder: RecorderManager.haveVocalRecorder
	property RecorderModel vocalRecorder : (haveRecorder ? RecorderManager.getVocalRecorder() : null)
	property bool isRecording : (vocalRecorder ? vocalRecorder.state != LinphoneEnums.RecorderStateClosed : false)
	property bool isPlaying : vocalPlayer.item && vocalPlayer.item.playbackState === SoundPlayer.PlayingState
	
	onVocalRecorderChanged: if(haveRecorder)
								audioPreviewBlock.state = 'showed'
	onIsRecordingChanged: if(isRecording) {
								mediaProgressBar.start()
							}else
								mediaProgressBar.stop()
	onIsPlayingChanged: isPlaying ? mediaProgressBar.resume() : mediaProgressBar.stop()
	
	Layout.preferredHeight: 70
	
	color: ChatAudioPreviewStyle.backgroundColor
	radius: 0
	state: "hidden"
	visible: haveRecorder
	onVisibleChanged: if(!visible) hide()
	clip: false
	function hide(){
		state = 'hidden'
	}
	Loader {
		id: vocalPlayer
		
		active: false
		sourceComponent: SoundPlayer {
			source: (haveRecorder && vocalRecorder? vocalRecorder.file : '')
			onStopped:{
				mediaProgressBar.value = 100
			}
			Component.onCompleted: {
				play()// This will open the file and allow seeking
				pause()
			}
		}
	}
	RowLayout{
		id: lineLayout
		anchors.fill: parent
		spacing: 10
		ActionButton{
			Layout.preferredHeight: iconSize
			Layout.preferredWidth: iconSize
			Layout.leftMargin: 10
			Layout.alignment: Qt.AlignVCenter
			isCustom: true
			colorSet: ChatAudioPreviewStyle.deleteAction
			onClicked: audioPreviewBlock.hide()
		}
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignVCenter
			Layout.topMargin: 5
			Layout.bottomMargin: 5
			MediaProgressBar{
				id: mediaProgressBar
				anchors.fill: parent
				progressDuration: 0
				progressPosition: 0
				stopAtEnd: !audioPreviewBlock.isRecording 
				resetAtEnd: false
				colorSet: isRecording ? ChatAudioPreviewStyle.recordingProgressionWave : ChatAudioPreviewStyle.progressionWave
				onEndReached:{
					if(vocalPlayer.item)
						vocalPlayer.item.stop()
				}
				onRefreshPositionRequested: if( vocalPlayer.item){
												progressPosition = vocalPlayer.item.getPosition()
												value = 100 * ( progressPosition / vocalPlayer.item.duration)
											}else{// Recording
												progressDuration = vocalRecorder.getDuration()
												progressPosition = progressDuration
												value = value + 0.01
											}
				onSeekRequested: if(  vocalPlayer.item){
					vocalPlayer.item.seek(ms)
					progressPosition = vocalPlayer.item.getPosition()
					value = 100 * (progressPosition / vocalPlayer.item.duration)
				}
			}
		}
		ActionButton{
			Layout.preferredHeight: iconSize
			Layout.preferredWidth: iconSize
			Layout.rightMargin: 15
			Layout.leftMargin: 5
			Layout.alignment: Qt.AlignVCenter
			isCustom: true
			colorSet: audioPreviewBlock.isRecording ? ChatAudioPreviewStyle.stopAction
						: (audioPreviewBlock.isPlaying ? ChatAudioPreviewStyle.pauseAction
							: ChatAudioPreviewStyle.playAction)
			onClicked:{
				if(audioPreviewBlock.isRecording){// Stop the record and save the file
					audioPreviewBlock.vocalRecorder.stop()
					mediaProgressBar.value = 100
					vocalPlayer.active = true
				}else if(audioPreviewBlock.isPlaying){// Pause the play
					vocalPlayer.item.pause()
				}else{// Play the audio
					vocalPlayer.item.play()
				}
			}
		}
	}
	states: [
		 State {
			 name: "hidden"
			 PropertyChanges { target: audioPreviewBlock; opacity: 0 }
		 },
		 State {
			 name: "showed"
			 PropertyChanges { target: audioPreviewBlock; opacity: 1 }
		 }
	 ]
	 transitions: [
		 Transition {
			 from: "*"; to: "showed"
			 SequentialAnimation{
				ScriptAction{ script: audioPreviewBlock.vocalRecorder.start() }
				NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 250 }
			}
		 },
		 Transition {
		 from: "*"; to: "hidden"
			SequentialAnimation{
				ScriptAction{ script: RecorderManager.clearVocalRecorder()}
				ScriptAction{ script: vocalPlayer.active = false }
				NumberAnimation{ properties: "opacity"; duration: 250 }
			}
		}
	]
}	