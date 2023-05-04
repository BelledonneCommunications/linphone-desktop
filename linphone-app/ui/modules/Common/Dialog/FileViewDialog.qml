import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.15

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Linphone.Styles 1.0

import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

DialogPlus{
	id: mainItem
	property ContentModel contentModel
	property string filePath: tempFile.filePath
	property bool isAnimatedImage : filePath && UtilsCpp.isAnimatedImage(filePath)
	property bool isVideo: filePath && UtilsCpp.isVideo(filePath)
	property bool isImage: filePath && UtilsCpp.isImage(filePath)
	property bool isPdf: filePath && UtilsCpp.isPdf(filePath)
	property bool isSupportedForDisplay: filePath && tempFile.isReadable && UtilsCpp.isSupportedForDisplay(filePath)
	
	showCloseCross: true
	showButtons: !isVideo
	buttonsAlignment: Qt.AlignRight
	
	buttons: [/*
		ActionButton{
			Layout.preferredHeight: 3*iconSize/2
			Layout.preferredWidth: 3*iconSize/2
			isCustom: true
			backgroundRadius: width
			colorSet:  FileViewDialogStyle.exportFile
			onClicked: {
				loadAsDialog.open()
			}
		},*/
		ActionButton{
			Layout.preferredHeight: 3*iconSize/2
			Layout.preferredWidth: 3*iconSize/2
			isCustom: true
			backgroundRadius: width
			colorSet:  FileViewDialogStyle.exportFile
			onClicked: saveAsDialog.open()
		}
	]
	
	height: window.height - 20
	width: window.width - 20
	expandHeight: true
	
	radius: 10
	onContentModelChanged: if(contentModel){
		tempFile.createFileFromContentModel(contentModel, false);
	}
	onExitStatus: if(loader.sourceComponent == videoComponent) loader.item.stop();
	Component.onCompleted:{
		if(mainItem.isPdf){
			if(UtilsCpp.openWithPdfViewer(contentModel, mainItem.filePath, 800,800))
				Qt.callLater(mainItem.exit)
		}
	}
	
	TemporaryFile {
		id: tempFile
	}
	
	FileDialog {
		id: saveAsDialog
		folder: shortcuts.documents
		//: "Export As...": Title of a file dialog to export a file.
		title: qsTr('exportAsTitle')
		selectExisting: false
		defaultSuffix: Utils.getExtension(mainItem.filePath)// Doesn't seems to work on all platforms
		onAccepted: {
			var files = fileUrls.reduce(function (files, file) {
				if (file.startsWith('file:')) {
					files.push(Utils.getSystemPathFromUri(file))
				}
				return files
			}, [])
			contentModel.saveAs(files[0])
		}
	}

	FileDialog {
		id: loadAsDialog
		folder: shortcuts.documents
		//: "Load": Title of a file dialog to load a file.
		title: qsTr('loadFile')
		selectExisting: true
		//defaultSuffix: Utils.getExtension(mainItem.filePath)// Doesn't seems to work on all platforms
		onAccepted: {
			var files = fileUrls.reduce(function (files, file) {
				if (file.startsWith('file:')) {
					files.push(Utils.getSystemPathFromUri(file))
				}
				return files
			}, [])
			tempFile.createFile(files[0], false);
		}
	}

	Loader{
		id: loader
		anchors.fill: parent
	
		active: true
		sourceComponent: isSupportedForDisplay
							? isVideo
								? videoComponent
								: mainItem.isAnimatedImage
									? animatedImageComponent
									: mainItem.isImage
										? imageComponent
										: fileTextComponent
							: placeholderComponent
//--------------------------------------------------------------------------------------------------		
//						VIDEOS
//--------------------------------------------------------------------------------------------------		
		Component{
			id: videoComponent
			Video{
				id: videoItem
				property bool isPlaying: videoItem.playbackState == MediaPlayer.PlayingState
				anchors.fill: parent
				source: 'file:'+mainItem.filePath	// GStreamer doesn't know 'file://'
				autoPlay: true
				//loops: MediaPlayer.Infinite// Do not use because MediaPlayer can crash while trying to replay video.
				flushMode: VideoOutput.FirstFrame
				notifyInterval: 100
				onStatusChanged: {
					if(MediaPlayer.EndOfMedia == status){// Workaround for a Qt crash when replaying a video after reaching the End of the Video.
						console.info("Closing the popup at the end is a workaround to avoid a crash from Qt(5.15.2)")
						mainItem.exit()
					}
				}
					
				BusyIndicator{
					visible: videoItem.playbackState == MediaPlayer.StoppedState
					anchors.centerIn: parent
					height: 50
					width: 50
					color: BusyIndicatorStyle.alternateColor.color
				}
				
				HoveringMouseArea{
					id: hoveringMouseArea
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					cursorShape: Qt.ArrowCursor
					onClicked: videoControl.forceVisible = !videoControl.forceVisible
					Item{
						id: videoControl
						property bool forceVisible: false
						property bool autoHide: false
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						anchors.leftMargin: 20
						anchors.rightMargin: 20
						anchors.bottomMargin: 0
						height: 50
						visible: forceVisible || !videoControl.autoHide || hoveringMouseArea.realRunning
						Component.onCompleted: autoHideDelayer.start()
						Timer{
							id: autoHideDelayer
							interval: 1000
							onTriggered: videoControl.autoHide = true
						}
						RowLayout{
							anchors.fill: parent
							MediaProgressBar{
								id: mediaProgressBar
								Layout.fillHeight: true
								Layout.fillWidth: true
								progressDuration: videoItem.duration
								progressPosition: videoItem.position
								stopAtEnd: false
								resetAtEnd: false
								blockValueAtEnd: false
								backgroundColor: ChatAudioMessageStyle.backgroundColor.color
								progressLineBackgroundColor: FileViewDialogStyle.progression.backgroundColor.color
								colorSet: FileViewDialogStyle.progression
								durationTextColor: ChatStyle.entry.message.outgoing.text.colorModel.color
								progressSize: 10
								customActions: [
									ActionButton{
										Layout.preferredHeight: iconSize
										Layout.preferredWidth: iconSize
										Layout.leftMargin: 15
										Layout.rightMargin: 5
										isCustom: true
										backgroundRadius: width
										colorSet: FileViewDialogStyle.exportFile
										onClicked: {
											if(videoItem.isPlaying)
												videoItem.pause()
											saveAsDialog.open()
										}
									},
									ActionButton{
										id: playButton
										Layout.preferredHeight: iconSize
										Layout.preferredWidth: iconSize
										Layout.rightMargin: 5
										Layout.leftMargin: 5
										Layout.alignment: Qt.AlignVCenter
										isCustom: true
										backgroundRadius: width
										colorSet:  (videoItem.isPlaying ? FileViewDialogStyle.pauseAction
																		 : FileViewDialogStyle.playAction)
										onClicked:  videoItem.isPlaying ? videoItem.pause() : videoItem.play()
									},
									ActionButton{
										id: muteButton
										Layout.preferredHeight: iconSize
										Layout.preferredWidth: iconSize
										Layout.leftMargin: 5
										Layout.rightMargin: 15
										Layout.alignment: Qt.AlignVCenter
										isCustom: true
										backgroundRadius: width
										colorSet:  (videoItem.muted ? FileViewDialogStyle.speakerOff
																		 : FileViewDialogStyle.speakerOn)
										onClicked:  videoItem.muted = !videoItem.muted
									}
								]
								onSeekRequested: {
													videoItem.seek(ms)
												 }
							}
						}
					}
				}
			}
		}
//--------------------------------------------------------------------------------------------------		
//						ANIMATIONS
//--------------------------------------------------------------------------------------------------
		Component {
			id: animatedImageComponent
			AnimatedImage {
				id: animatedImageSource
				property real scaleAnimatorTo : 1.7
				mipmap: SettingsModel.mipmapEnabled
				source: 'file:/'+mainItem.filePath
				autoTransform: true
				fillMode: Image.PreserveAspectFit
			}
		}
//--------------------------------------------------------------------------------------------------		
//						IMAGE
//--------------------------------------------------------------------------------------------------
		Component {
			id: imageComponent
			Image {
				id: imageSource
				mipmap: SettingsModel.mipmapEnabled
				source: 'file:/'+mainItem.filePath
				autoTransform: true
				fillMode: Image.PreserveAspectFit
			}
		}
//--------------------------------------------------------------------------------------------------		
//						PLAIN TEXT
//--------------------------------------------------------------------------------------------------		
		Component{
			id: fileTextComponent
			ListView {
				id: idContentListView
				model: idContentListView.stringList
				anchors.fill: parent
				anchors.topMargin: 20
				anchors.leftMargin: 10
				anchors.rightMargin: 10
				
				clip: true
				
				delegate: Text {
					width: idContentListView.width
					text: model.modelData
					font.pointSize: FormTableStyle.entry.text.pointSize
					textFormat: Text.PlainText
					wrapMode: Text.Wrap
				}
				ScrollBar.vertical: ScrollBar {}
				
				property variant stringList: null
				function updateText() {
					stringList = UtilsCpp.getFileContent(filePath).split('\n')
					//idContentListView.positionViewAtEnd()
				}
				Component.onCompleted: updateText()
				Connections{
					target: tempFile
					onFilePathChanged: idContentListView.updateText()
				}
			}
		}
//--------------------------------------------------------------------------------------------------
//						NO DISPLAY
//--------------------------------------------------------------------------------------------------
		Component {
			id: placeholderComponent
			Item{
				Layout.alignment: Qt.AlignCenter
				Icon{
					id: fileIcon
					anchors.centerIn: parent
					icon: FileViewDialogStyle.extension.icon
					iconSize: FileViewDialogStyle.extension.iconSize
				}
			}
		}
	}
}



