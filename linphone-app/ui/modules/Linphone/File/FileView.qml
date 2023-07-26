import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0
import Units 1.0
import ColorsList 1.0

// =============================================================================


Item {
	id: mainItem
	property ContentModel contentModel
	property string thumbnail: contentModel && contentModel.thumbnail
	property string name: contentModel && contentModel.name
	property string filePath: contentModel && contentModel.filePath
	property int fileHeight: FileViewStyle.height
	property bool active: true
	property real animationScale : FileViewStyle.animation.to
	property alias imageScale: thumbnailProvider.scale
	property int fitHeight: mainItem.isAnimatedImage  ? FileViewStyle.heightbetter : FileViewStyle.height
	property int fitWidth: fitHeight*4/3
	property bool isAnimatedImage : contentModel && contentModel.wasDownloaded && UtilsCpp.isAnimatedImage(filePath)
	property bool haveThumbnail: contentModel && UtilsCpp.canHaveThumbnail(filePath)
	property int borderWidth : 0
	property color backgroundColor: FileViewStyle.extension.background.colorModel.color
	property int backgroundRadius: FileViewStyle.extension.radius
	
	property bool isTransferring
	property bool isHovering: thumbnailProvider.state == 'hovered'
	property bool isOutgoing: false
	
	signal clickOnFile()
	
	MouseArea {
			function handleMouseMove (mouse) {
				thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
						? 'hovered'
						: ''
			}
			
			anchors.fill: parent
			visible: true
			
			onClicked: {
				if(mainItem.isTransferring)
					mainItem.contentModel.cancelDownloadFile()
				else if( !mainItem.contentModel.wasDownloaded) {
					thumbnailProvider.state = ''
					mainItem.contentModel.downloadFile()
				}else if (Utils.pointIsInItem(this, thumbnailProvider, mouse)) {
					if(SettingsModel.isVfsEncrypted){
						window.attachVirtualWindow(Utils.buildCommonDialogUri('FileViewDialog'), {
													contentModel: mainItem.contentModel,
												}, function (status) {
												})
					}else
						mainItem.contentModel.openFile()
				} else if (mainItem.contentModel ) {
					thumbnailProvider.state = ''
					mainItem.contentModel.openFile(true)// Show directory
				} else  {
					thumbnailProvider.state = ''
					mainItem.contentModel.downloadFile()
					
				}
				mainItem.clickOnFile()
			}
			onExited: thumbnailProvider.state = ''
			onMouseXChanged: handleMouseMove.call(this, mouse)
			onMouseYChanged: handleMouseMove.call(this, mouse)
		}
	
	
	// ---------------------------------------------------------------------
	// Thumbnail
	// ---------------------------------------------------------------------
	Component {
		id: thumbnailImage
		
		Image {
			id: thumbnailImageSource
			property real scaleAnimatorTo : FileViewStyle.animation.thumbnailTo
			property bool isVideo: UtilsCpp.isVideo(mainItem.filePath)
			mipmap: SettingsModel.mipmapEnabled
			source: mainItem.thumbnail
			autoTransform: true
			fillMode: Image.PreserveAspectFit
			anchors.fill: parent
			
			Loader{
				anchors.fill: parent
				sourceComponent: Image{// Better quality on zoom
					mipmap: SettingsModel.mipmapEnabled
					source: !thumbnailImageSource.isVideo ? 'image://external/'+mainItem.filePath : ''
					autoTransform: true
					fillMode: Image.PreserveAspectFit
					visible: status == Image.Ready
				}
				asynchronous: true
				active: !thumbnailImageSource.isVideo && thumbnailProvider.state == 'hovered'
			}
			ActionButton{
				id: thumbnailVideoButton
				anchors.centerIn: parent
				visible: thumbnailImageSource.isVideo
				isCustom: true
				backgroundRadius: width
				colorSet:  FileViewStyle.thumbnailVideoIcon
				onClicked:{
					window.attachVirtualWindow(Utils.buildCommonDialogUri('FileViewDialog'), {
											contentModel: mainItem.contentModel,
										}, function (status) {
										})
				}
			}
		}
	}
	Component {
		id: animatedImage
		
		AnimatedImage {
			id: animatedImageSource
			property real scaleAnimatorTo : FileViewStyle.animation.to
			mipmap: SettingsModel.mipmapEnabled
			source: 'file:/'+mainItem.filePath
			autoTransform: true
			fillMode: Image.PreserveAspectFit
			anchors.fill: parent
		}
	}
	// ---------------------------------------------------------------------
	// Extension
	// ---------------------------------------------------------------------
	Component {
		id: extension
		
		Rectangle {
			property real scaleAnimatorTo : FileViewStyle.animation.to
			anchors.fill: parent
			color: mainItem.backgroundColor
			radius: mainItem.backgroundRadius
			border.width: mainItem.borderWidth
			border.color: FileViewStyle.extension.background.borderColorModel.color
						
			ColumnLayout{
				anchors.fill: parent
				anchors.topMargin: FileViewStyle.margins 
				anchors.bottomMargin: FileViewStyle.margins
				spacing: FileViewStyle.spacing
				Icon{
					id: fileIcon
					property bool isImage: UtilsCpp.isImage(mainItem.name)
					Layout.alignment: Qt.AlignCenter
					icon: fileIcon.isImage ? FileViewStyle.extension.imageIcon : FileViewStyle.extension.icon
					iconSize: FileViewStyle.extension.iconSize
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.preferredHeight: iconSize
					Layout.preferredWidth: iconSize
					Text {
						id: extensionText
						anchors.bottom: parent.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.bottomMargin: FileViewStyle.spacing
						width: FileViewStyle.extension.internalSize
						onWidthChanged: extensionMetrics.font.pointSize = FileViewStyle.extension.text.pointSize // reset metrics
						color: FileViewStyle.extension.text.colorModel.color
						font.bold: true
						font.pointSize: extensionMetrics.font.pointSize
						clip: true
						text: (!fileIcon.isImage && mainItem.contentModel?Utils.getExtension(mainItem.name).toUpperCase():'')
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						TextMetrics{
							id: extensionMetrics
							text: extensionText.text
							font.pointSize: FileViewStyle.extension.text.pointSize
							onWidthChanged: if(width > extensionText.width) --font.pointSize
							Component.onCompleted: if(width > extensionText.width) --font.pointSize
						}
					}
					RoundProgressBar {
						id: progressBar
						anchors.centerIn: parent
						property int fileSize: mainItem.contentModel ? mainItem.contentModel.fileSize : 0
						to: 100
						value: mainItem.contentModel ? (fileSize>0 ? Math.floor(100 * mainItem.contentModel.fileOffset / fileSize) : 0) : to
						visible: mainItem.isTransferring && value != 0
						/* Change format? Current is %
						text: if(mainRow.contentModel){
									var fileSize = Utils.formatSize(mainRow.contentModel.fileSize)
									return progressBar.visible
												? Utils.formatSize(mainRow.contentModel.fileOffset) + '/' + fileSize
												: fileSize
								}else
									return ''
						*/
					}
				}
				Text {
					id: fileName
					Layout.fillWidth: true
					Layout.fillHeight: true
					visible: mainItem.contentModel && !mainItem.isAnimatedImage
					
					color: FileViewStyle.extension.text.colorModel.color
					font.pointSize: FileViewStyle.name.pointSize
					wrapMode: Text.WrapAnywhere
					horizontalAlignment: Text.AlignHCenter
					maximumLineCount: 2
					
					text: mainItem.name
				}
				Text{
					id: downloadText
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.preferredHeight: visible ? contentHeight : 0
					//: 'Cancel' : Message link to cancel a transfer (upload/download)
					text: mainItem.contentModel ? mainItem.isTransferring ? qsTr('fileTransferCancel')
					//: 'Download' : Message link to download a file
																		: qsTr('fileTransferDownload') +' ('+Utils.formatSize(mainItem.contentModel.fileSize)+')'
												: ''
					font.underline: true
					font.pointSize: FileViewStyle.download.pointSize
					color:FileViewStyle.extension.text.colorModel.color
					visible: (mainItem.contentModel? (!mainItem.isOutgoing && !mainItem.contentModel.wasDownloaded) || mainItem.isTransferring  : false)
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
			
		}
	}
	
	Loader {
		id: thumbnailProvider
		anchors.fill: parent
		sourceComponent: (mainItem.contentModel ? 
							  (mainItem.isAnimatedImage ? animatedImage
													   :  (mainItem.haveThumbnail ? thumbnailImage : extension )
							   ) : undefined)
						
		states: State {
			name: 'hovered'
		}
	}
	Loader {
		id: waitingProvider
		
		anchors.fill: parent
		sourceComponent: thumbnailProvider.sourceComponent == thumbnailImage && (thumbnailProvider.item.status != Image.Ready || thumbnailProvider.item.sourceSize.height == 0)
							? extension 
							: undefined
		states: State {
			name: 'hovered'
		}
	}
}