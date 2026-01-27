import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// =============================================================================


Item {
	id: mainItem
	property ChatMessageContentGui contentGui
	property string thumbnail: contentGui && contentGui.core.thumbnail || ""
	property string name: contentGui && contentGui.core.name
	property string filePath: contentGui && contentGui.core.filePath
	property bool wasDownloaded: contentGui && contentGui.core.wasDownloaded
	property bool isAnimatedImage : contentGui && contentGui.core.wasDownloaded && UtilsCpp.isAnimatedImage(filePath)
	property bool haveThumbnail: contentGui && UtilsCpp.canHaveThumbnail(filePath) && UtilsCpp.fileExists(filePath)
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
		target: contentGui ? contentGui.core : null
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
			Image {
				id: errorImage
				anchors.fill: parent
				z: image.z + 1
				visible: image.status == Image.Error || image.status == Image.Null
				source: AppIcons.fileImage
				sourceSize.width: mainItem.width
				sourceSize.height: mainItem.height
				fillMode: Image.PreserveAspectFit
			}
			Item {
				id: loadingImageItem
				anchors.fill: parent
				visible: image.status === Image.Loading && !image.visible && !errorImage.visilbe
				Rectangle {
					anchors.fill: parent
					color: DefaultStyle.main1_200
					opacity: 0.2
				}
				BusyIndicator {
					anchors.centerIn: parent
					width: Utils.getSizeWithScreenRatio(20)
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
				// Video {
					// id: videoThumbnail
					// anchors.fill: parent
					// position: 100
					// source: mainItem.isVideo ? "file:///" + mainItem.filePath : ""
					// fillMode: playbackState === MediaPlayer.PlayingState ? VideoOutput.PreserveAspectFit : VideoOutput.PreserveAspectCrop
					EffectImage {
						anchors.centerIn: parent
						// visible: videoThumbnail.playbackState !== MediaPlayer.PlayingState
						width: Utils.getSizeWithScreenRatio(24)
						height: Utils.getSizeWithScreenRatio(24)
						imageSource: AppIcons.playFill
						colorizationColor: DefaultStyle.main2_0
					}
					// Text {
					// 	z: parent.z + 1
					// 	property int timeDisplayed: videoThumbnail.playbackState === MediaPlayer.PlayingState ? videoThumbnail.position : videoThumbnail.duration
					// 	anchors.bottom: parent.bottom
					// 	anchors.left: parent.left
					// 	anchors.bottomMargin: Utils.getSizeWithScreenRatio(6)
					// 	anchors.leftMargin: Utils.getSizeWithScreenRatio(6)
					// 	text: UtilsCpp.formatDuration(timeDisplayed)
					// 	color: DefaultStyle.grey_0
					// 	font {
					// 		pixelSize: Typography.d1.pixelSize
					// 		weight: Typography.d1.weight
					// 	}
					// }
				// }
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
			leftPadding: Utils.getSizeWithScreenRatio(4)
			rightPadding: Utils.getSizeWithScreenRatio(4)
			topPadding: Utils.getSizeWithScreenRatio(23)
			bottomPadding: Utils.getSizeWithScreenRatio(4)
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
					height: Utils.getSizeWithScreenRatio(23)
					EffectImage {
						anchors.centerIn: parent
						imageSource: mainItem.imageSource
						imageWidth: Utils.getSizeWithScreenRatio(14)
						imageHeight: Utils.getSizeWithScreenRatio(14)
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
					width: Utils.getSizeWithScreenRatio(24)
					height: Utils.getSizeWithScreenRatio(24)
					colorizationColor: DefaultStyle.main2_600
				}
			}
		}
	}
	Component {
		id: defaultView
		Control.Control {
			rightPadding: Utils.getSizeWithScreenRatio(17)

			background: Rectangle {
				id: bg
				color: DefaultStyle.grey_100
				width: mainItem.width
				height: mainItem.height
				radius: Utils.getSizeWithScreenRatio(10)
			}
			contentItem: RowLayout {
				spacing: Utils.getSizeWithScreenRatio(16)
				Rectangle {
					color: DefaultStyle.main2_200
					width: Utils.getSizeWithScreenRatio(58)
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
						imageSource: mainItem.imageSource
						width: Utils.getSizeWithScreenRatio(22)
						height: width
						colorizationColor: DefaultStyle.main2_600
					}
				}
				ColumnLayout {
					spacing: Utils.getSizeWithScreenRatio(1)
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
