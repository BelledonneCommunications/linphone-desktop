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

Row {
	id:mainRow
	// ---------------------------------------------------------------------------
	// Avatar if it's an incoming message.
	// ---------------------------------------------------------------------------
	
	property bool isOutgoing : $chatEntry.isOutgoing  || $chatEntry.state == LinphoneEnums.ChatMessageStateIdle;
	
	Item {
		height: ChatStyle.entry.lineHeight
		width: ChatStyle.entry.metaWidth
		
		Component {
			id: avatar
			
			Avatar {
				height: ChatStyle.entry.message.incoming.avatarSize
				width: ChatStyle.entry.message.incoming.avatarSize
				
				image: $chatEntry.contactModel? $chatEntry.contactModel.vcard.avatar : '' //chat.sipAddressObserver.contact ? chat.sipAddressObserver.contact.vcard.avatar : ''
				username: isOutgoing? $chatEntry.toDisplayName : $chatEntry.fromDisplayName
				
				TooltipArea{
					delay:0
					text:parent.username+'\n'+ (isOutgoing ? $chatEntry.toSipAddress : $chatEntry.fromSipAddress)
					tooltipParent:mainRow
				}
			}
		}
		
		Loader {
			anchors.centerIn: parent
			sourceComponent: !isOutgoing? avatar : undefined
		}
	}
	
	// ---------------------------------------------------------------------------
	// File message.
	// ---------------------------------------------------------------------------
	
	Row {
		spacing: ChatStyle.entry.message.extraContent.leftMargin
		Item{
			width: ChatStyle.entry.message.file.width
			height:rectangle.height + deliveryLayout.height
			
			Rectangle {
				id: rectangle
				
				readonly property bool isError: Utils.includes([
																   LinphoneEnums.ChatMessageStateFileTransferError,
																   LinphoneEnums.ChatMessageStateNotDelivered,
															   ], $chatEntry.state)
				readonly property bool isUploaded: $chatEntry.state == LinphoneEnums.ChatMessageStateDelivered
				readonly property bool isDelivered: $chatEntry.state == LinphoneEnums.ChatMessageStateDeliveredToUser
				readonly property bool isRead: $chatEntry.state == LinphoneEnums.ChatMessageStateDisplayed
				
				
				//property ContentModel contentModel : ($chatEntry.getContent(0) ? $chatEntry.getContent(0) : null)
				property ContentModel contentModel : $chatEntry.fileContentModel
				property string thumbnail :  contentModel ? contentModel.thumbnail : ''
				color: isOutgoing
					   ? ChatStyle.entry.message.outgoing.backgroundColor
					   : ChatStyle.entry.message.incoming.backgroundColor
				
				height: ChatStyle.entry.message.file.height
				width: ChatStyle.entry.message.file.width
				
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
							mipmap: Qt.platform.os === 'osx'
							source: rectangle.contentModel.thumbnail
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
								text: (rectangle.contentModel?Utils.getExtension(rectangle.contentModel.name).toUpperCase():'')
								
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
							}
						}
					}
					
					Loader {
						id: thumbnailProvider
						
						Layout.fillHeight: true
						Layout.preferredWidth: parent.height
						
						sourceComponent: (rectangle.contentModel ? (rectangle.contentModel.thumbnail ? thumbnailImage : extension ): undefined)
						
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
					
					Column {
						Layout.fillWidth: true
						Layout.fillHeight: true
						
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
							
							text: (rectangle.contentModel ? rectangle.contentModel.name : '')
							width: parent.width
						}
						
						ProgressBar {
							id: progressBar
							
							height: ChatStyle.entry.message.file.status.bar.height
							width: parent.width
							
							to: (rectangle.contentModel ? rectangle.contentModel.fileSize : 0)
							value: rectangle.contentModel ? rectangle.contentModel.fileOffset || 0 : 0
							visible: $chatEntry.state == LinphoneEnums.ChatMessageStateInProgress || $chatEntry.state == LinphoneEnums.ChatMessageStateFileTransferInProgress
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
							color: fileName.color
							elide: Text.ElideRight
							font.pointSize: fileName.font.pointSize
							text: {
								if(rectangle.contentModel){
									var fileSize = Utils.formatSize(rectangle.contentModel.fileSize)
									return progressBar.visible
											? Utils.formatSize(rectangle.contentModel.fileOffset) + '/' + fileSize
											: fileSize
								}else
									return ''
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
					
					icon: 'download'
					iconSize: ChatStyle.entry.message.file.iconSize
					visible: (rectangle.contentModel?!isOutgoing && !rectangle.contentModel.wasDownloaded : false)
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
							rectangle.contentModel.openFile()
						} else if (rectangle.contentModel && rectangle.contentModel.wasDownloaded) {
							rectangle.contentModel.openFile(true)// Show directory
						} else  {
							rectangle.contentModel.downloadFile()
						}
					}
					
					onExited: thumbnailProvider.state = ''
					onMouseXChanged: handleMouseMove.call(this, mouse)
					onMouseYChanged: handleMouseMove.call(this, mouse)
				}
				ChatMenu{
					id: chatMenu
					height: parent.height
					width: rectangle.width
					
					deliveryCount: deliveryLayout.model.count
					onDeliveryStatusClicked: deliveryLayout.visible = !deliveryLayout.visible
					onRemoveEntryRequested: removeEntry()
					deliveryVisible: deliveryLayout.visible
				}
				
				Row{
					id:ephemeralTimerRow
					anchors.right:downloadButton.visible?downloadButton.left:parent.right
					anchors.bottom:parent.bottom	
					anchors.bottomMargin: 5
					anchors.rightMargin : 5
					visible:$chatEntry.isEphemeral
					spacing:5
					Text{
						text: $chatEntry.ephemeralExpireTime > 0 ? Utils.formatElapsedTime($chatEntry.ephemeralExpireTime) : Utils.formatElapsedTime($chatEntry.ephemeralLifetime)
						color: ColorsList.add("FileMessage_ephemeral_text", "ad").color 
						font.pointSize: Units.dp * 8
						Timer{
							running:parent.visible
							interval: 1000
							repeat:true
							onTriggered: if($chatEntry.getEphemeralExpireTime() > 0 ) parent.text = Utils.formatElapsedTime($chatEntry.getEphemeralExpireTime())// Use the function
						}
					}
					Icon{
						icon:'timer'
						iconSize: 15
					}
				}		
			}
			
			ChatDeliveries{
				id: deliveryLayout
				anchors.top:rectangle.bottom
				anchors.left:parent.left
				anchors.right:parent.right
				anchors.rightMargin: 50
				
				chatMessageModel: $chatEntry
			}
			
			ActionButton {
				height: ChatStyle.entry.lineHeight
				anchors.left:rectangle.right
				anchors.leftMargin: -10
				anchors.top:rectangle.top
				anchors.topMargin: 5
				
				icon: 'chat_menu'
				iconSize: ChatStyle.entry.deleteIconSize
				visible: isHoverEntry()
				
				onClicked: chatMenu.open()
			}
		}
		
		// -------------------------------------------------------------------------
		// Resend/Remove file message.
		// -------------------------------------------------------------------------
		
		Row {
			spacing: ChatStyle.entry.message.extraContent.spacing
			
			Component {
				id: icon
				
				Icon {
					anchors.centerIn: parent
					
					icon: rectangle.isError ? 'chat_error' :
											  (rectangle.isRead ? 'chat_read' : 
																  (rectangle.isDelivered ? 'chat_delivered' : ''))
					
					iconSize: ChatStyle.entry.message.outgoing.sendIconSize
					
					MouseArea {
						anchors.fill: parent
						visible: (rectangle.isError || $chatEntry.state == LinphoneEnums.ChatMessageStateIdle) && isOutgoing
						onClicked: proxyModel.resendMessage(index)
					}
				}
			}
			
			Component {
				id: indicator
				
				Item {
					anchors.fill: parent
					
					BusyIndicator {
						anchors.centerIn: parent
						
						height: ChatStyle.entry.message.outgoing.busyIndicatorSize
						width: ChatStyle.entry.message.outgoing.busyIndicatorSize
					}
				}
			}
			
			Loader {
				height: ChatStyle.entry.lineHeight
				width: ChatStyle.entry.message.outgoing.areaSize
				
				sourceComponent: isOutgoing
								 ? (
									   $chatEntry.state == LinphoneEnums.ChatMessageStateInProgress || $chatEntry.state == LinphoneEnums.ChatMessageStateFileTransferInProgress
									   ? indicator
									   : icon
									   ) : undefined
			}
		}
	}
	
}
