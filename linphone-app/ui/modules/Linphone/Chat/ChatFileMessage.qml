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
	property int fitWidth: visible ? Math.max( (fileName.visible ? fileName.implicitWidth : 0)
												 + thumbnailProvider.width + 3*ChatStyle.entry.message.file.margins
											  , Math.max(ChatStyle.entry.message.file.width, ChatStyle.entry.message.outgoing.areaSize)) : 0
	property int fitHeight: visible ? rectangle.height : 0
	
	property bool isAnimatedImage : mainRow.contentModel && mainRow.contentModel.wasDownloaded && UtilsCpp.isAnimatedImage(mainRow.contentModel.filePath)
	property bool haveThumbnail: mainRow.contentModel && mainRow.contentModel.thumbnail
	
	signal copyAllDone()
	signal copySelectionDone()
	signal forwardClicked()
	height: fitHeight
	visible: contentModel && !contentModel.isIcalendar() && (contentModel.isFile() || contentModel.isFileTransfer()) && !contentModel.isVoiceRecording()
	// ---------------------------------------------------------------------------
	// File message.
	// ---------------------------------------------------------------------------
	
	Row {
		spacing: ChatStyle.entry.message.extraContent.leftMargin
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
				
				property string thumbnail :  mainRow.contentModel ? mainRow.contentModel.thumbnail : ''
				color: 'transparent'
				
				height: mainRow.isAnimatedImage ? ChatStyle.entry.message.file.heightbetter : ChatStyle.entry.message.file.height
				width: mainRow.width
				
				radius: ChatStyle.entry.message.radius
				
				RowLayout {
					anchors {
						fill: parent
						margins: ChatStyle.entry.message.file.margins
					}
					
					spacing: ChatStyle.entry.message.file.spacing
					
					
					// ---------------------------------------------------------------------
					// Thumbnail or extension.
					// ---------------------------------------------------------------------
					
					Component {
						id: thumbnailImage
						
						Image {
							id: thumbnailImageSource
							property real scaleAnimatorTo : ChatStyle.entry.message.file.animation.thumbnailTo
							mipmap: SettingsModel.mipmapEnabled
							source: mainRow.contentModel.thumbnail
							fillMode: Image.PreserveAspectFit
							Loader{
								anchors.fill: parent
								sourceComponent: Image{// Better quality on zoom
									mipmap: SettingsModel.mipmapEnabled
									source:'file:/'+mainRow.contentModel.filePath
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
							fillMode: Image.PreserveAspectFit
							//width: 200
							//height: 100
						}
					}
					
					Component {
						id: extension
						
						Rectangle {
							property real scaleAnimatorTo : ChatStyle.entry.message.file.animation.to
							color: ChatStyle.entry.message.file.extension.background.color
							
							Text {
								anchors.fill: parent
								
								color: ChatStyle.entry.message.file.extension.text.color
								font.bold: true
								elide: Text.ElideRight
								text: (mainRow.contentModel?Utils.getExtension(mainRow.contentModel.name).toUpperCase():'')
								
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
							}
						}
					}					
					Loader {
						id: thumbnailProvider
						
						Layout.fillHeight: true
						Layout.preferredWidth: parent.height*4/3
						
						
						
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
										if (thumbnailProviderAnimator.running) {
											thumbnailProviderAnimator.running = false
										}
										
										thumbnailProvider.z = Constants.zPopup
										thumbnailProviderAnimator.to = thumbnailProvider.item.scaleAnimatorTo
										thumbnailProviderAnimator.running = true
									}
								}
							},
							Transition {
								from: 'hovered'
								to: ''
								
								ScriptAction {
									script: {
										if (thumbnailProviderAnimator.running) {
											thumbnailProviderAnimator.running = false
										}
										
										thumbnailProviderAnimator.to = 1.0
										thumbnailProviderAnimator.running = true
										thumbnailProvider.z = 0
									}
								}
							}
						]
					}
					
					// ---------------------------------------------------------------------
					// Upload or file status.
					// ---------------------------------------------------------------------
					Item{
						Layout.fillWidth: true
						Layout.fillHeight: true
						Column {
							anchors.fill: parent
							
							spacing: ChatStyle.entry.message.file.status.spacing
							
							Text {
								id: fileName
								
								color: isOutgoing
									   ? ChatStyle.entry.message.outgoing.text.color
									   : ChatStyle.entry.message.incoming.text.color
								elide: Text.ElideRight
								
								font {
									bold: true
									pointSize: isOutgoing
											   ? ChatStyle.entry.message.outgoing.text.pointSize
											   : ChatStyle.entry.message.incoming.text.pointSize
								}
								
								text: (mainRow.contentModel ? mainRow.contentModel.name : '')
								width: visible ? parent.width : 0
								visible: mainRow.contentModel && !mainRow.isAnimatedImage && !mainRow.haveThumbnail
							}
							
							ProgressBar {
								id: progressBar
								
								height: ChatStyle.entry.message.file.status.bar.height
								width: visible ? parent.width : 0
								
								to: (mainRow.contentModel ? mainRow.contentModel.fileSize : 0)
								value: mainRow.contentModel ? mainRow.contentModel.fileOffset || to : to
								visible: value != to
								background: Rectangle {
									color: ChatStyle.entry.message.file.status.bar.background.color
									radius: ChatStyle.entry.message.file.status.bar.radius
								}
								
								contentItem: Item {
									Rectangle {
										color: ChatStyle.entry.message.file.status.bar.contentItem.color
										height: parent.height
										width: progressBar.visualPosition * parent.width
										
										radius: ChatStyle.entry.message.file.status.bar.radius
									}
								}
							}
							
							Text {
								visible: progressBar.value != progressBar.to
								color: fileName.color
								elide: Text.ElideRight
								font.pointSize: fileName.font.pointSize
								text: {
									if(mainRow.contentModel){
										var fileSize = Utils.formatSize(mainRow.contentModel.fileSize)
										return progressBar.visible
												? Utils.formatSize(mainRow.contentModel.fileOffset) + '/' + fileSize
												: fileSize
									}else
										return ''
								}
							}
						}
					}
				}
				
				Icon {
					id:downloadButton
					anchors {
						bottom: parent.bottom
						bottomMargin: ChatStyle.entry.message.file.margins
						right: parent.right
						rightMargin: ChatStyle.entry.message.file.margins
					}
					
					icon: ChatStyle.entry.message.file.download.icon
					iconSize: ChatStyle.entry.message.file.download.iconSize
					overwriteColor: isOutgoing ? ChatStyle.entry.message.file.download.outgoingColor : ChatStyle.entry.message.file.download.incomingColor
					visible: !progressBar.visible && (mainRow.contentModel? !mainRow.contentModel.wasDownloaded : false)
				}
				
				MouseArea {
					function handleMouseMove (mouse) {
						thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
								? 'hovered'
								: ''
					}
					
					anchors.fill: parent
					visible: true
					//downloadButton.visible || ((rectangle.isUploaded || rectangle.isRead) && !isOutgoing) || isOutgoing
					//onVisibleChanged: console.log("Mouse of "+mainRow.contentModel.name+" / "+downloadButton.visible
						//				+"/"+rectangle.isUploaded +"/"+rectangle.isRead)
					
					onClicked: {
						if (Utils.pointIsInItem(this, thumbnailProvider, mouse)) {
							mainRow.contentModel.openFile()
						} else if (mainRow.contentModel && mainRow.contentModel.wasDownloaded) {
							mainRow.contentModel.openFile(true)// Show directory
							thumbnailProvider.state = ''
						} else  {
							mainRow.contentModel.downloadFile()
							thumbnailProvider.state = ''
						}
					}
					onExited: thumbnailProvider.state = ''
					onMouseXChanged: handleMouseMove.call(this, mouse)
					onMouseYChanged: handleMouseMove.call(this, mouse)
				}
			}
		}
	}
}
