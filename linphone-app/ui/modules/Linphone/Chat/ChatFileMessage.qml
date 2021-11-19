import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import Units 1.0
import ColorsList 1.0

// =============================================================================
// TODO : into Loader
Row {
	id:mainRow
	
	property ChatMessageModel chatMessageModel: contentModel && contentModel.chatMessageModel
	property ContentModel contentModel
	property bool isOutgoing : contentModel && ( chatMessageModel.isOutgoing  || chatMessageModel.state == LinphoneEnums.ChatMessageStateIdle);
	property int fitWidth: visible ? Math.max(fileName.implicitWidth + 5 + thumbnailProvider.width + 3*ChatStyle.entry.message.file.margins
											  , Math.max(ChatStyle.entry.message.file.width, ChatStyle.entry.message.outgoing.areaSize)) : 0
	property int fitHeight: visible ? rectangle.height : 0
	
	signal copyAllDone()
	signal copySelectionDone()
	signal forwardClicked()
	height: fitHeight
	visible: contentModel && (contentModel.isFile() || contentModel.isFileTransfer()) && !contentModel.isVoiceRecording()
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
				
				height: ChatStyle.entry.message.file.height
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
							mipmap: SettingsModel.mipmapEnabled
							source: mainRow.contentModel.thumbnail
						}
					}
					
					Component {
						id: extension
						
						Rectangle {
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
						Layout.preferredWidth: parent.height
						
						sourceComponent: (mainRow.contentModel ? (mainRow.contentModel.thumbnail ? thumbnailImage : extension ): undefined)
						
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
										thumbnailProviderAnimator.to = ChatStyle.entry.message.file.animation.to
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
								width: parent.width
							}
							
							ProgressBar {
								id: progressBar
								
								height: ChatStyle.entry.message.file.status.bar.height
								width: parent.width
								
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
					visible: (mainRow.contentModel? !mainRow.contentModel.wasDownloaded : false)
				}
				
				MouseArea {
					function handleMouseMove (mouse) {
						thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
								? 'hovered'
								: ''
					}
					
					anchors.fill: parent
					visible: downloadButton.visible || ((rectangle.isUploaded || rectangle.isRead) && !isOutgoing) || isOutgoing
					
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
