import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import Units 1.0
import ColorsList 1.0
import UtilsCpp 1.0

// =============================================================================
// TODO : into Loader
Row {
	id:mainRow
	
	property ChatMessageModel chatMessageModel: contentModel && contentModel.chatMessageModel
	property ContentModel contentModel
	property bool isOutgoing : chatMessageModel && ( chatMessageModel.isOutgoing  || chatMessageModel.state == LinphoneEnums.ChatMessageStateIdle);
	property int fitHeight: ChatStyle.entry.message.file.height
	property int fitWidth: ChatStyle.entry.message.file.height * 4 / 3 + 2*ChatStyle.entry.message.file.margins
	property int borderWidth : 0
	property color backgroundColor: ChatStyle.entry.message.file.extension.background.colorModel.color
	property int backgroundRadius: ChatStyle.entry.message.file.extension.radius
	/*
	property int fitWidth: visible 
								? Math.max( Math.max((thumbnailProvider.sourceComponent == extension 
																? thumbnailProvider.item.fitWidth 
																: 0)
														, thumbnailProvider.width + 3*ChatStyle.entry.message.file.margins)
											  , Math.max(ChatStyle.entry.message.file.width, ChatStyle.entry.message.outgoing.areaSize)) 
								: 0
	property int fitHeight: visible ? rectangle.height : 0
	*/
	property bool isAnimatedImage : mainRow.contentModel && mainRow.contentModel.wasDownloaded && UtilsCpp.isAnimatedImage(mainRow.contentModel.filePath)
	property bool haveThumbnail: mainRow.contentModel && mainRow.contentModel.thumbnail
	property bool isHovering: thumbnailProvider.state == 'hovered'
	
	signal copyAllDone()
	signal copySelectionDone()
	signal forwardClicked()
	height: fitHeight
	width: fitWidth
	visible: true
	// ---------------------------------------------------------------------------
	// File message.
	// ---------------------------------------------------------------------------
	
	Item{
		width: mainRow.width
		height:rectangle.height
		
		Rectangle {
			id: rectangle
			
			readonly property bool isError: chatMessageModel && Utils.includes([
																				   LinphoneEnums.ChatMessageStateFileTransferError,
																				   LinphoneEnums.ChatMessageStateNotDelivered,
																			   ], chatMessageModel.state)
			readonly property bool isUploaded: chatMessageModel && chatMessageModel.state == LinphoneEnums.ChatMessageStateDelivered
			readonly property bool isDelivered: chatMessageModel && chatMessageModel.state == LinphoneEnums.ChatMessageStateDeliveredToUser
			readonly property bool isRead: chatMessageModel && chatMessageModel.state == LinphoneEnums.ChatMessageStateDisplayed
			readonly property bool isTransferring: chatMessageModel && (chatMessageModel.state == LinphoneEnums.ChatMessageStateFileTransferInProgress || chatMessageModel.state == LinphoneEnums.ChatMessageStateInProgress )
			
			property string thumbnail :  mainRow.contentModel ? mainRow.contentModel.thumbnail : ''
			color: 'transparent'
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			height: 2*ChatStyle.entry.message.file.margins + (mainRow.isAnimatedImage 
																? ChatStyle.entry.message.file.heightbetter
																: thumbnailProvider.sourceComponent == extension
																	? ChatStyle.entry.message.file.height
																	: ChatStyle.entry.message.file.height
															)
			radius: ChatStyle.entry.message.radius
			
			// ---------------------------------------------------------------------
			// Thumbnail or extension.
			// ---------------------------------------------------------------------
			
			Component {
				id: thumbnailImage
				
				Image {
					id: thumbnailImageSource
					property real scaleAnimatorTo : ChatStyle.entry.message.file.animation.thumbnailTo
					anchors.centerIn: parent
					mipmap: SettingsModel.mipmapEnabled
					source: mainRow.contentModel.thumbnail
					autoTransform: true
					fillMode: Image.PreserveAspectFit
					height: ChatStyle.entry.message.file.height
					width: height*4/3
					
					Loader{
						anchors.fill: parent
						sourceComponent: Image{// Better quality on zoom
							mipmap: SettingsModel.mipmapEnabled
							source:'image://external/'+mainRow.contentModel.filePath
							autoTransform: true
							fillMode: Image.PreserveAspectFit
							visible: status == Image.Ready
						}
						asynchronous: true
						active: thumbnailProvider.state == 'hovered'
					}
				}
			}
			Component {
				id: animatedImage
				
				AnimatedImage {
					id: animatedImageSource
					property real scaleAnimatorTo : ChatStyle.entry.message.file.animation.to
					mipmap: SettingsModel.mipmapEnabled
					source: 'file:/'+mainRow.contentModel.filePath
					autoTransform: true
					fillMode: Image.PreserveAspectFit
					height: ChatStyle.entry.message.file.heightbetter
					width: height*4/3
				}
			}
			
			Component {
				id: extension
				
				Rectangle {
					property int fitWidth: Math.max(downloadText.implicitWidth, Math.max(fileName.visible ? fileName.implicitWidth : 0, fileIcon.iconSize)) + 20
					//property int fitHeight: fileIcon.iconSize + (fileName.visible ? fileName.implicitHeight + ChatStyle.entry.message.file.spacing : 0 ) 
//											+ (downloadText.visible? downloadText.implicitHeight + ChatStyle.entry.message.file.spacing : 0) + 2*ChatStyle.entry.message.file.margins
					property real scaleAnimatorTo : ChatStyle.entry.message.file.animation.to
					
					anchors.centerIn: parent
					height: ChatStyle.entry.message.file.height
					width: height*4/3
					color: mainRow.backgroundColor
					radius: mainRow.backgroundRadius
					border.width: mainRow.borderWidth
					border.color: ChatStyle.entry.message.file.extension.background.borderColorModel.color
					
					ColumnLayout{
						anchors.fill: parent
						anchors.topMargin: ChatStyle.entry.message.file.margins 
						anchors.bottomMargin: ChatStyle.entry.message.file.margins
						spacing: ChatStyle.entry.message.file.spacing
						Icon{
							id: fileIcon
							Layout.alignment: Qt.AlignCenter
							icon: extensionText.text != '' ?  ChatStyle.entry.message.file.extension.icon : ChatStyle.entry.message.file.extension.unknownIcon
							iconSize: ChatStyle.entry.message.file.extension.iconSize
							Layout.fillHeight: true
							Layout.fillWidth: true
							Layout.preferredHeight: iconSize
							Layout.preferredWidth: iconSize
							Text {
								id: extensionText
								anchors.bottom: parent.bottom
								anchors.horizontalCenter: parent.horizontalCenter
								anchors.bottomMargin: ChatStyle.entry.message.file.spacing
								width: parent.width - 2*ChatStyle.entry.message.file.spacing
								color: ChatStyle.entry.message.file.extension.text.colorModel.color
								font.bold: true
								font.pointSize: ChatStyle.entry.message.file.extension.text.pointSize
								clip: true
								text: (mainRow.contentModel?Utils.getExtension(mainRow.contentModel.name).toUpperCase():'')
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
							}
							RoundProgressBar {
								id: progressBar
								anchors.centerIn: parent
								property int fileSize: mainRow.contentModel ? mainRow.contentModel.fileSize : 0
								to: 100
								value: mainRow.contentModel ? (fileSize>0 ? Math.floor(100 * mainRow.contentModel.fileOffset / fileSize) : 0) : to
								visible: rectangle.isTransferring && value != 0
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
							visible: mainRow.contentModel && !mainRow.isAnimatedImage && !mainRow.haveThumbnail
							
							color: ChatStyle.entry.message.file.extension.text.colorModel.color
							font.pointSize: ChatStyle.entry.message.file.name.pointSize
							wrapMode: Text.WrapAnywhere
							horizontalAlignment: Text.AlignHCenter
							maximumLineCount: 2
							
							text: (mainRow.contentModel ? mainRow.contentModel.name : '')
						}
						Text{
							id: downloadText
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.preferredHeight: visible ? contentHeight : 0
							//: 'Cancel' : Message link to cancel a transfer (upload/download)
							text: mainRow.contentModel ? rectangle.isTransferring ? qsTr('fileTransferCancel')
							//: 'Download' : Message link to download a file
																				: qsTr('fileTransferDownload') +' ('+Utils.formatSize(mainRow.contentModel.fileSize)+')'
														: ''
							font.underline: true
							font.pointSize: ChatStyle.entry.message.file.download.pointSize
							color:ChatStyle.entry.message.file.extension.text.colorModel.color
							visible: (mainRow.contentModel? (!mainItem.isOutgoing && !mainRow.contentModel.wasDownloaded) || rectangle.isTransferring  : false)
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
						}
					}
					
				}
			}
			Loader {
				id: thumbnailProvider
				anchors.centerIn: parent
				sourceComponent: (mainRow.contentModel ? 
									  (mainRow.isAnimatedImage ? animatedImage
															   :  (mainRow.haveThumbnail ? thumbnailImage : extension )
									   ) : undefined)
				
				ScaleAnimator {
					id: thumbnailProviderAnimator
					
					target: thumbnailProvider
					
					duration: ChatStyle.entry.message.file.animation.duration
					easing.type: Easing.InOutQuad
					from: 1.0
				}
				
				states: State {
					name: 'hovered'
				}
				
				transitions: [
					Transition {
						from: ''
						to: 'hovered'
						
						ScriptAction {
							script: {
								if(thumbnailProvider.sourceComponent != extension){
									if (thumbnailProviderAnimator.running) {
										thumbnailProviderAnimator.running = false
									}
									thumbnailProvider.z = Constants.zPopup
									thumbnailProviderAnimator.to = thumbnailProvider.item.scaleAnimatorTo
									thumbnailProviderAnimator.running = true
								}
							}
						}
					},
					Transition {
						from: 'hovered'
						to: ''
						
						ScriptAction {
							script: {
								if(thumbnailProvider.sourceComponent != extension){
									if (thumbnailProviderAnimator.running) {
										thumbnailProviderAnimator.running = false
									}
									
									thumbnailProviderAnimator.to = 1.0
									thumbnailProviderAnimator.running = true
									thumbnailProvider.z = 0
								}
							}
						}
					}
				]
			}
		}
		
		
		MouseArea {
			function handleMouseMove (mouse) {
				thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
						? 'hovered'
						: ''
			}
			
			anchors.fill: parent
			visible: true
			
			onClicked: {
				if(rectangle.isTransferring)
					mainRow.contentModel.cancelDownloadFile()
				else if( !mainRow.contentModel.wasDownloaded) {
					thumbnailProvider.state = ''
					mainRow.contentModel.downloadFile()
				}else if (Utils.pointIsInItem(this, thumbnailProvider, mouse)) {
					window.attachVirtualWindow(Utils.buildCommonDialogUri('FileViewDialog'), {
													contentModel: mainRow.contentModel,
												}, function (status) {
												})
				} else if (mainRow.contentModel ) {
					thumbnailProvider.state = ''
					mainRow.contentModel.openFile(true)// Show directory
				} else  {
					thumbnailProvider.state = ''
					mainRow.contentModel.downloadFile()
					
				}
			}
			onExited: thumbnailProvider.state = ''
			onMouseXChanged: handleMouseMove.call(this, mouse)
			onMouseYChanged: handleMouseMove.call(this, mouse)
		}
	}
}
