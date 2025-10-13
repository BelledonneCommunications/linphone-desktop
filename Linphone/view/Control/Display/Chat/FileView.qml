import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import QtMultimedia

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// =============================================================================


Item {
	id: mainItem
	property ChatMessageContentGui contentGui
	property string thumbnail: contentGui && contentGui.core.thumbnail
	property string name: contentGui && contentGui.core.name
	property string filePath: contentGui && contentGui.core.filePath
	property bool wasDownloaded: contentGui && contentGui.core.wasDownloaded
	property bool isAnimatedImage : contentGui && contentGui.core.wasDownloaded && UtilsCpp.isAnimatedImage(filePath)
	property bool haveThumbnail: contentGui && UtilsCpp.canHaveThumbnail(filePath)
	property int fileSize: contentGui ? contentGui.core.fileSize : 0
	property bool isTransferring
	property bool isVideo: UtilsCpp.isVideo(filePath)
	property bool isImage: UtilsCpp.isImage(filePath)
	property bool isPdf: UtilsCpp.isPdf(filePath)
	property bool isThumbnail: isVideo || isImage || isPdf
	// property to change default view display
	property bool showAsSquare: true
	// default image
	property var imageSource: mainItem.contentGui
		? UtilsCpp.isImage(mainItem.filePath)
			? AppIcons.fileImage
			:  UtilsCpp.isPdf(mainItem.filePath)
				? AppIcons.filePdf
				: UtilsCpp.isText(mainItem.filePath)
					? AppIcons.fileText
					: AppIcons.file
		: ''
	property var thumbnailFillMode: Image.PreserveAspectCrop
	
	Connections {
		enabled: contentGui
		target: contentGui.core
		function onMsgStateChanged(state) {
			mainItem.isTransferring = state === LinphoneEnums.ChatMessageState.StateFileTransferInProgress 
			|| state === LinphoneEnums.ChatMessageState.StateInProgress
		}
	}

	// property bool isHovering: thumbnailProvider.state == 'hovered'
	property bool isOutgoing: false
	
	// ---------------------------------------------------------------------
	// Thumbnail
	// ---------------------------------------------------------------------
	Component {
		id: thumbnailImage
		Item {
			id: thumbnailSource
			Image {
				anchors.fill: parent
				visible: mainItem.isPdf
				source: AppIcons.filePdf
				sourceSize.width: mainItem.width
				sourceSize.height: mainItem.height
				fillMode: Image.PreserveAspectFit
			}
			Rectangle {
				anchors.fill: parent
				color: DefaultStyle.main1_200
				opacity: 0.5
				Image {
					anchors.fill: parent
					z: parent.z + 1
					visible: image.status == Image.Error || image.status == Image.Null || !UtilsCpp.fileExists(mainItem.filePath)
					source: AppIcons.fileImage
					sourceSize.width: mainItem.width
					sourceSize.height: mainItem.height
					fillMode: Image.PreserveAspectFit
				}
			}
			Image {
				id: image
				visible: mainItem.isImage && status !== Image.Loading
				mipmap: false//SettingsModel.mipmapEnabled
				source: mainItem.thumbnail
				sourceSize.width: mainItem.width
				sourceSize.height: mainItem.height
				autoTransform: true
				anchors.fill: parent
				fillMode: mainItem.thumbnailFillMode
			}
			Rectangle {
				visible: mainItem.isVideo
				color: DefaultStyle.grey_1000
				anchors.fill: parent
				Video {
					id: videoThumbnail
					anchors.fill: parent
					position: 100
					source: mainItem.isVideo ? "file:///" + mainItem.filePath : ""
					fillMode: playbackState === MediaPlayer.PlayingState ? VideoOutput.PreserveAspectFit : VideoOutput.PreserveAspectCrop
					MouseArea {
						propagateComposedEvents: false
						enabled: videoThumbnail.visible
						anchors.fill: parent
						hoverEnabled: false
						acceptedButtons: Qt.LeftButton
						onClicked: (mouse) => {
							mouse.accepted = true
							videoThumbnail.playbackState === MediaPlayer.PlayingState ? videoThumbnail.pause() : videoThumbnail.play()
						}
					}
					EffectImage {
						anchors.centerIn: parent
						visible: videoThumbnail.playbackState !== MediaPlayer.PlayingState
						width: Math.round(24 * DefaultStyle.dp)
						height: Math.round(24 * DefaultStyle.dp)
						imageSource: AppIcons.playFill
						colorizationColor: DefaultStyle.main2_0
					}
					Text {
						z: parent.z + 1
						property int timeDisplayed: videoThumbnail.playbackState === MediaPlayer.PlayingState ? videoThumbnail.position : videoThumbnail.duration
						anchors.bottom: parent.bottom
						anchors.left: parent.left
						anchors.bottomMargin: Math.round(6 * DefaultStyle.dp)
						anchors.leftMargin: Math.round(6 * DefaultStyle.dp)
						text: UtilsCpp.formatDuration(timeDisplayed)
						color: DefaultStyle.grey_0
						font {
							pixelSize: Typography.d1.pixelSize
							weight: Typography.d1.weight
						}
					}
				}
			}
		}
	}
	Component {
		id: animatedImage
		AnimatedImage {
			id: animatedImageSource
			mipmap: false//SettingsModel.mipmapEnabled
			source: 'file:/'+ mainItem.filePath
			autoTransform: true
			fillMode: Image.PreserveAspectFit
		}
	}

	// ---------------------------------------------------------------------
	// Default view
	// ---------------------------------------------------------------------
	Component {
		id: defaultSquareView
		Control.Control {
			leftPadding: Math.round(4 * DefaultStyle.dp)
			rightPadding: Math.round(4 * DefaultStyle.dp)
			topPadding: Math.round(23 * DefaultStyle.dp)
			bottomPadding: Math.round(4 * DefaultStyle.dp)
			hoverEnabled: false

			background: Rectangle {
				anchors.fill: parent
				color: FileViewStyle.extension.background.color
				radius: FileViewStyle.extension.radius
				
				Rectangle {
					color: DefaultStyle.main2_200
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					height: Math.round(23 * DefaultStyle.dp)
					EffectImage {
						anchors.centerIn: parent
						imageSource: mainItem.imageSource
						imageWidth: Math.round(14 * DefaultStyle.dp)
						imageHeight: Math.round(14 * DefaultStyle.dp)
						colorizationColor: DefaultStyle.main2_600
					}
				}
			}
						
			contentItem: Item {
				Text {
					id: fileName
					visible: !progressBar.visible
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					// visible: mainItem.contentGui && !mainItem.isAnimatedImage
					font.pixelSize: Typography.f1.pixelSize
					font.weight: Typography.f1l.weight
					wrapMode: Text.WrapAnywhere
					maximumLineCount: 2
					text: mainItem.name
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
					id: fileSizeText
					visible: !progressBar.visible
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					text: Utils.formatSize(mainItem.fileSize)
					font.pixelSize: Typography.f1l.pixelSize
					font.weight: Typography.f1l.weight
				}
				RoundProgressBar {
					id: progressBar
					anchors.centerIn: parent
					to: 100
					value: mainItem.contentGui ? (mainItem.fileSize>0 ? Math.floor(100 * mainItem.contentGui.core.fileOffset / mainItem.fileSize) : 0) : to
					visible: mainItem.isTransferring && value != 0
					/* Change format? Current is %
					text: if(mainRow.contentGui){
								var mainItem.fileSize = Utils.formatSize(mainRow.contentGui.core.mainItem.fileSize)
								return progressBar.visible
											? Utils.formatSize(mainRow.contentGui.core.fileOffset) + '/' + mainItem.fileSize
											: mainItem.fileSize
							}else
								return ''
					*/
				}
				Rectangle {
					visible: thumbnailProvider.state === 'hovered' && mainItem.contentGui && (/*!mainItem.isOutgoing &&*/ !mainItem.contentGui.core.wasDownloaded)
					color: DefaultStyle.grey_0
					opacity: 0.5
					anchors.fill: parent
				}
				EffectImage {
					visible: thumbnailProvider.state === 'hovered' && mainItem.contentGui && (/*!mainItem.isOutgoing &&*/ !mainItem.contentGui.core.wasDownloaded)
					anchors.centerIn: parent
					imageSource: AppIcons.download
					width: Math.round(24 * DefaultStyle.dp)
					height: Math.round(24 * DefaultStyle.dp)
					colorizationColor: DefaultStyle.main2_600
				}
			}
		}
	}
	Component {
		id: defaultView
		Control.Control {
			rightPadding: Math.round(17*DefaultStyle.dp)

			background: Rectangle {
				id: bg
				color: DefaultStyle.grey_100
				width: mainItem.width
				height: mainItem.height
				radius: Math.round(10 * DefaultStyle.dp)
			}
			contentItem: RowLayout {
				spacing: Math.round(16 * DefaultStyle.dp)
				Rectangle {
					color: DefaultStyle.main2_200
					width: Math.round(58 * DefaultStyle.dp)
					height: bg.height
					radius: bg.radius
					Rectangle {
						anchors.right: parent.right
						color: DefaultStyle.main2_200
						width: parent.width / 2
						height: parent.height
						radius: parent.radius
						
					}
					EffectImage {
						z: parent.z + 1
						anchors.centerIn: parent
						imageSource: defaultViewStack.imageSource
						width: Math.round(22 * DefaultStyle.dp)
						height: width
						colorizationColor: DefaultStyle.main2_600
					}
				}
				ColumnLayout {
					spacing: Math.round(1 * DefaultStyle.dp)
					Text {
						text: mainItem.name
						Layout.fillWidth: true
						font {
							pixelSize: Typography.p2.pixelSize
							weight: Typography.p2.weight
						}
					}
					Text {
						text: mainItem.fileSize
						Layout.fillWidth: true
						font {
							pixelSize: Typography.p4.pixelSize
							weight: Typography.p4.weight
						}
					}
				}
			}
		}
	}

	Loader {
		id: thumbnailProvider
		anchors.fill: parent
		sourceComponent: mainItem.contentGui 
			? mainItem.isAnimatedImage
				? animatedImage
				:  mainItem.haveThumbnail
					? thumbnailImage
					: mainItem.showAsSquare 
						? defaultSquareView 
						: defaultView
			: undefined

		states: State {
			name: 'hovered'
		}

		MouseArea {
			anchors.fill: thumbnailProvider.item
			hoverEnabled: true
			propagateComposedEvents: true
			cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			// Changing cursor in MouseArea seems not to work with the Loader
			// Use override cursor for this case
			onContainsMouseChanged: {
				if (containsMouse) UtilsCpp.setGlobalCursor(Qt.PointingHandCursor)
				else UtilsCpp.restoreGlobalCursor()
				thumbnailProvider.state = containsMouse ? 'hovered' : ''
			}
			onPressed: (mouse) => {
				mouse.accepted = false
				if(mainItem.isTransferring) {
					mainItem.contentGui.core.lCancelDownloadFile()
					mouse.accepted = true
				}
				else if(!mainItem.contentGui.core.wasDownloaded) {
					mouse.accepted = true
					mainItem.contentGui.core.lDownloadFile()
				} else if (Utils.pointIsInItem(this, thumbnailProvider, mouse)) {
					mouse.accepted = true
					// if(SettingsModel.isVfsEncrypted){
					//     window.attachVirtualWindow(Utils.buildCommonDialogUri('FileViewDialog'), {
					//                                 contentGui: mainItem.contentGui,
					//                             }, function (status) {
					//                             })
					// }else
					mainItem.contentGui.core.lOpenFile()
				} else if (mainItem.contentGui) {
					mouse.accepted = true
					mainItem.contentGui.core.lOpenFile(true)// Show directory
				}
			}
		}
	}
}