import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.10

import App 1.0
import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import ColorsList 1.0
import Units 1.0


import App.Styles 1.0

// =============================================================================

Item {
	Item{
		id: mainItem
		anchors.fill: parent
		anchors.topMargin : 15
		anchors.bottomMargin : 15
		anchors.leftMargin : 15
		anchors.rightMargin : 0
		Text {
			id: noRec
			anchors.centerIn: parent
			//: 'No recordings' : Title of an empty list of records.
			text: qsTr('titleNoRecordings')
			visible : recordingsProxyModel.count === 0
			color: RecordingsStyle.title.colorModel.color
			font.pointSize: RecordingsStyle.title.pointSize
		}
		Component {
			id: sectionHeading
			Form {
				anchors.rightMargin : 10
				//required property string section	// Only for > Qt 5.15
				title: section
				width: parent.width
				height: 30
			}
		}
		ScrollableListView {
			anchors.fill: parent
			id: recordingsList
			spacing: 0
			model: RecordingProxyModel {
				id: recordingsProxyModel
			}
			section.property: '$sectionDate'
			section.criteria: ViewSection.FullString
			section.delegate: sectionHeading
			delegate: Loader{
				id: lineLoader
				property bool isMedia: $modelData && ($modelData.type != FileMediaModel.IS_UNKNOWN && $modelData.type != FileMediaModel.IS_SNAPSHOT)  	// Test only extension because file can be encrypted.
				property string title: ($modelData.type == FileMediaModel.IS_CALL_RECORD || $modelData.type == FileMediaModel.IS_SNAPSHOT
										   ? $modelData.from + ' => ' +$modelData.to 
										   : $modelData.type == FileMediaModel.IS_VOICE_RECORD
										   //: 'Vocal' : Label for recording type that is a vocal message.
											 ? qsTr('recordingsVocalLabel')
											 : $modelData.baseName)
										  + ' - ' +UtilsCpp.toTimeString($modelData.creationDateTime)
				sourceComponent: isMedia ? mediaComponent : fileComponent
//--------------------------------------------------------------------------
//					MEDIA
//--------------------------------------------------------------------------
				Component{
					id: mediaComponent
					RowLayout {
						id: lineItem
						width: recordingsList.width
						property bool isPlaying : vocalPlayer.item && vocalPlayer.item.playbackState === SoundPlayer.PlayingState
						onIsPlayingChanged: {
							if (isPlaying) {
								if(mediaProgressBar.value >= 100)
									mediaProgressBar.value = 0
								timer.start()
							} else {
								timer.stop()
							}
						}
						Loader{
							id: vocalPlayer
							active: false
							sourceComponent: SoundPlayer {
								id: player
								source: $modelData.filePath
								onStopped: {
									mediaProgressBar.value = 101
									videoView.linphonePlayer = null
								}
								Component.onCompleted: {
									mediaProgressBar.value = 0
									play()
									videoView.linphonePlayer = null
									if( player.hasVideo())
										videoView.linphonePlayer = player
								}
							}
						}
						ActionButton {
							Layout.alignment: Qt.AlignRight
							isCustom: true
							colorSet: lineItem.isPlaying ? RecordingsStyle.buttons.pause : RecordingsStyle.buttons.play
							onClicked: {
								if(!vocalPlayer.active)
									vocalPlayer.active = true
								else if(lineItem.isPlaying){// Pause the play
									vocalPlayer.item.pause()
								}else{// Play the audio
									vocalPlayer.item.play()
									videoView.linphonePlayer = null
									if(vocalPlayer.item.hasVideo())
										videoView.linphonePlayer = vocalPlayer.item
								}
							}
						}
						ColumnLayout {
							Layout.rightMargin : 15
							Layout.leftMargin : 30
							Layout.fillWidth: true
							spacing:0
							RowLayout {
								Layout.fillWidth: true
								Layout.topMargin: 10
								Text {
									Layout.fillWidth: true
									Layout.alignment: Qt.AlignLeft
									text: lineLoader.title
									horizontalAlignment: Text.AlignLeft
									font.pointSize: RecordingsStyle.filename.pointSize
									color: RecordingsStyle.filename.colorModel.color
								}
								Text {
									id: durationText
									Layout.fillWidth: true
									Layout.alignment: Qt.AlignRight
									text: (vocalPlayer.item ? Utils.formatElapsedTime(vocalPlayer.item.getPosition()/1000) + "/" : '')
										  +Utils.formatElapsedTime($modelData.duration/1000)
									horizontalAlignment: Text.AlignRight
									font.pointSize: RecordingsStyle.filename.pointSize
									color: RecordingsStyle.filename.colorModel.color
								}
							}
							Slider {
								id: mediaProgressBar
								Layout.fillWidth: true
								Layout.leftMargin: 20
								enabled: true
								to: 101
								value: vocalPlayer.item ? 0.01 * progressDuration / 5 : 0
								Timer{
									id: timer
									repeat: true
									onTriggered: {
										if( vocalPlayer.item){
											mediaProgressBar.value = 100 * ( vocalPlayer.item.getPosition() / vocalPlayer.item.duration)
											durationText.text = Utils.formatElapsedTime(vocalPlayer.item.getPosition()/1000) + "/" + Utils.formatElapsedTime(vocalPlayer.item.duration/1000)
										}
									}
									interval: 5
								}
								onValueChanged:{
									if(value > 100){
										timer.stop()
										durationText.text = Utils.formatElapsedTime(0) + "/" + Utils.formatElapsedTime(vocalPlayer.item.duration/1000)
										if(vocalPlayer.item)
											vocalPlayer.item.stop()
										value = 0
									}
								}
								onMoved: if(vocalPlayer.item){
											 vocalPlayer.item.seek(vocalPlayer.item.duration*value / 100)
											 value = 100 * (vocalPlayer.item.getPosition() / vocalPlayer.item.duration)
										 }
							}
						}
						
						ActionButton {
							Layout.rightMargin : 30
							Layout.leftMargin : 15
							isCustom: true
							backgroundRadius: width/2
							colorSet: RecordingsStyle.buttons.remove
							onClicked: {
								window.detachVirtualWindow()
								window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
															//: 'Are you sure you want to delete this item?' : Confirmation message for removing a record.
															   descriptionText: qsTr('recordingsDelete'),
														   }, function (status) {
															   if (status) {
																	if(vocalPlayer.item)
																		vocalPlayer.item.stop()
																	if(vocalPlayer.active)
																		vocalPlayer.active = false
																	recordingsProxyModel.remove($modelData)
															   }
														   })
								
							}
						}
					}
				}
//--------------------------------------------------------------------------
//					FILE
//--------------------------------------------------------------------------
				Component{
					id: fileComponent
					RowLayout{
						width: recordingsList.width
						Item{
							height: RecordingsStyle.buttons.size
							width: height
							ActionButton{
								anchors.centerIn: parent
								isCustom: true
								backgroundRadius: width/2
								colorSet: $modelData.type == FileMediaModel.IS_SNAPSHOT ? RecordingsStyle.buttons.openImage : RecordingsStyle.buttons.openFile
								onClicked: {
									Qt.openUrlExternally(Utils.getUriFromSystemPath($modelData.filePath))
								}
							}
						}
						Text{
							Layout.fillWidth: true
							Layout.leftMargin : 30
							text: lineLoader.title
							font.pointSize: RecordingsStyle.filename.pointSize
							color: RecordingsStyle.filename.colorModel.color
						}
						ActionButton {
							Layout.rightMargin : 30
							Layout.leftMargin : 15
							isCustom: true
							backgroundRadius: width/2
							colorSet: RecordingsStyle.buttons.remove
							onClicked: {
								window.detachVirtualWindow()
								window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
															//: 'Are you sure you want to delete this item?' : Confirmation message for removing a record.
															   descriptionText: qsTr('recordingsDelete'),
														   }, function (status) {
															   if (status) {
																   recordingsProxyModel.remove($modelData)
															   }
														   })
								
							}
						}
					}
				}
			}// Loader
		}
		Item{
			id: videoViewItem
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			height: 200
			width: height * 16/9
			visible: videoView.active
			Loader{
				id: videoView
				property SoundPlayer linphonePlayer
				anchors.fill: parent
				active: linphonePlayer
				sourceComponent: Component{
					CameraView{
						qmlName: 'RecordingItem'
						isPreview: false
						linphonePlayer: videoView.linphonePlayer
					}
				}
			}
			
			MovableMouseArea{
				id: dragger
				anchors.fill: parent
				function resetPosition(){
					videoViewItem.anchors.bottom = mainItem.bottom
					videoViewItem.anchors.horizontalCenter = mainItem.horizontalCenter
				}
				onVisibleChanged: if(!visible){
					resetPosition()
				}
				drag.target: videoViewItem
				onDraggingChanged: if(dragging){
					videoViewItem.anchors.bottom = undefined
					videoViewItem.anchors.horizontalCenter = undefined
				}
				onRequestResetPosition: resetPosition()
			}
		}
	}
}
