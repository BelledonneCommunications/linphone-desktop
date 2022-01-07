import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle {
	id: container
	
	property alias proxyModel: chat.model	// ChatRoomProxyModel
	property alias tryingToLoadMoreEntries : chat.tryToLoadMoreEntries
	
	property string noticeBannerText : ''	// When set, show a banner with text and hide after some time
	onNoticeBannerTextChanged: if(noticeBannerText!='') messageBlock.state = "showed"
	
	// ---------------------------------------------------------------------------
	
	signal messageToSend (string text)
	
	// ---------------------------------------------------------------------------
	
	color: ChatStyle.color
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		ScrollableListView {
			id: chat
			
			// -----------------------------------------------------------------------
			
			property bool bindToEnd: false
			property bool tryToLoadMoreEntries: true
			//property var sipAddressObserver: SipAddressesModel.getSipAddressObserver(proxyModel.fullPeerAddress, proxyModel.fullLocalAddress)
			
			// -----------------------------------------------------------------------
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			highlightFollowsCurrentItem: false
			
			section {
				criteria: ViewSection.FullString
				delegate: sectionHeading
				property: '$sectionDate'
			}
			
			Timer {
				id: loadMoreEntriesDelayer
				interval: 1
				repeat: false
				running: false
				
				onTriggered: {
					chat.positionViewAtBeginning()
					container.proxyModel.loadMoreEntries()
				}
			}
			Timer {
				// Delay each search by 100ms
				id: endOfLoadMoreEntriesDelayer
				interval: 100
				repeat: false
				running: false
				
				onTriggered: {
					if(chat.atYBeginning){// We are still at the beginning. Try to continue searching
						loadMoreEntriesDelayer.start()
					}else// We are not at the begining. New search can be done by moving to the top.
						chat.tryToLoadMoreEntries = false
				}
			}
			
			// -----------------------------------------------------------------------
			
			Component.onCompleted: Logic.initView()
			
			onContentYChanged: {
				if (chat.atYBeginning && !chat.tryToLoadMoreEntries) {
					chat.tryToLoadMoreEntries = true// Show busy indicator
					loadMoreEntriesDelayer.start()// Let GUI time to the busy indicator to be shown
				}
			}
			onMovementEnded: Logic.handleMovementEnded()
			onMovementStarted: Logic.handleMovementStarted()
			
			// -----------------------------------------------------------------------
			
			Connections {
				target: proxyModel
				
				// When the view is changed (for example `Calls` -> `Messages`),
				// the position is set at end and it can be possible to load
				// more entries.
				onEntryTypeFilterChanged: Logic.initView()
				onMoreEntriesLoaded: {
					Logic.handleMoreEntriesLoaded(n)
					if(n>1)// New entries : delay the end
						endOfLoadMoreEntriesDelayer.start()
					else// No new entries, we can stop without waiting
						chat.tryToLoadMoreEntries = false
				}
			}
			
			// -----------------------------------------------------------------------
			// Heading.
			// -----------------------------------------------------------------------
			
			Component {
				id: sectionHeading
				
				Item {
					implicitHeight: container.height + ChatStyle.sectionHeading.bottomMargin
					width: parent.width
					
					Borders {
						id: container
						
						borderColor: ChatStyle.sectionHeading.border.color
						bottomWidth: ChatStyle.sectionHeading.border.width
						implicitHeight: text.contentHeight +
										ChatStyle.sectionHeading.padding * 2 +
										ChatStyle.sectionHeading.border.width * 2
						topWidth: ChatStyle.sectionHeading.border.width
						width: parent.width
						
						Text {
							id: text
							
							anchors.fill: parent
							color: ChatStyle.sectionHeading.text.color
							font {
								bold: true
								pointSize: ChatStyle.sectionHeading.text.pointSize
							}
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							
							// Cast section to integer because Qt converts the
							// sectionDate in string!!!
							text: new Date(section).toLocaleDateString(
									  Qt.locale(App.locale)
									  )
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// Message/Event renderer.
			// -----------------------------------------------------------------------
			
			delegate: Rectangle {
				id: entry
				property bool isNotice : $chatEntry.type === ChatRoomModel.NoticeEntry
				property bool isCall : $chatEntry.type === ChatRoomModel.CallEntry
				property bool isMessage : $chatEntry.type === ChatRoomModel.MessageEntry
				
				function isHoverEntry () {
					return mouseArea.containsMouse
				}
				
				function removeEntry () {
					proxyModel.removeRow(index)
				}
				
				anchors {
					left: parent ? parent.left : undefined
					leftMargin: isNotice?0:ChatStyle.entry.leftMargin
					right: parent ? parent.right : undefined
					
					rightMargin: isNotice?0:ChatStyle.entry.deleteIconSize +
										   ChatStyle.entry.message.extraContent.spacing +
										   ChatStyle.entry.message.extraContent.rightMargin +
										   ChatStyle.entry.message.extraContent.leftMargin +
										   ChatStyle.entry.message.outgoing.areaSize
				}
				
				color: ChatStyle.color
				implicitHeight: layout.height + ChatStyle.entry.bottomMargin
				
				// ---------------------------------------------------------------------
				
				MouseArea {
					id: mouseArea
					
					cursorShape: Qt.ArrowCursor
					hoverEnabled: true
					implicitHeight: layout.height
					width: parent.width + parent.anchors.rightMargin
					acceptedButtons: Qt.NoButton
					ColumnLayout{
						id: layout
						spacing: 0
						width: entry.width
						Text{
							id:authorName
							Layout.leftMargin: timeDisplay.width + 10
							Layout.fillWidth: true
							text : $chatEntry.fromDisplayName ? $chatEntry.fromDisplayName : ''
							property var previousItem : {
								if(index >0)
									return proxyModel.getAt(index-1)
								else 
									return null
							}
							
							color: ChatStyle.entry.event.text.color
							font.pointSize: ChatStyle.entry.event.text.pointSize
							visible: isMessage 
									 && $chatEntry != undefined
									 && !$chatEntry.isOutgoing // Only outgoing
									 && (!previousItem  //No previous entry
										 || previousItem.type != ChatRoomModel.MessageEntry // Previous entry is a message
										 || previousItem.fromSipAddress != $chatEntry.fromSipAddress // Different user
										 || (new Date(previousItem.timestamp)).setHours(0, 0, 0, 0) != (new Date($chatEntry.timestamp)).setHours(0, 0, 0, 0) // Same day == section
										 )
						}
						RowLayout {
							
							spacing: 0
							width: entry.width
							
							// Display time.
							Text {
								id:timeDisplay
								Layout.alignment: Qt.AlignTop
								Layout.preferredHeight: ChatStyle.entry.lineHeight
								Layout.preferredWidth: ChatStyle.entry.time.width
								
								color: ChatStyle.entry.event.text.color
								font.pointSize: ChatStyle.entry.time.pointSize
								
								text: $chatEntry.timestamp.toLocaleString(
										  Qt.locale(App.locale),
										  'hh:mm'
										  )
								
								verticalAlignment: Text.AlignVCenter
								
								TooltipArea {
									text: $chatEntry.timestamp.toLocaleString(Qt.locale(App.locale))
								}
								visible:!isNotice
							}
							
							// Display content.
							Loader {
								id: loader
								Layout.fillWidth: true
								source: Logic.getComponentFromEntry($chatEntry)
							}
							Connections{
								target: loader.item
								ignoreUnknownSignals: true
								//: "Copied to clipboard" : when a user copy a text from the menu, this message show up.
								onCopyAllDone: container.noticeBannerText = qsTr("allTextCopied")
								//: "Selection copied to clipboard" : when a user copy a text from the menu, this message show up.
								onCopySelectionDone: container.noticeBannerText = qsTr("selectedTextCopied")
								onReplyClicked: {
									proxyModel.chatRoomModel.reply = $chatEntry
								}
								onForwardClicked:{
									window.attachVirtualWindow(Qt.resolvedUrl('../Dialog/SipAddressDialog.qml')
										//: 'Choose where to forward the message' : Dialog title for choosing where to forward the current message.
										, {title: qsTr('forwardDialogTitle'),
											addressSelectedCallback: function (sipAddress) {
																		var chat = CallsListModel.createChat(sipAddress)
																		if(chat){
																			chat.forwardMessage($chatEntry)
																			TimelineListModel.select(chat)
																		}
																	},
											chatRoomSelectedCallback: function (chatRoomModel){
																		if(chatRoomModel){
																			chatRoomModel.forwardMessage($chatEntry)
																			TimelineListModel.select(chatRoomModel)
																		}
										}
									})
								}
							}
						}
					}
				}
			}
			footer: Item{
				implicitHeight: composersItem.implicitHeight
				width: parent.width
				Text {
					id: composersItem
					property var composers : container.proxyModel.chatRoomModel.composers
					onComposersChanged: console.log(composers)
					onVisibleChanged: console.log(visible)
					color: ChatStyle.composingText.color
					font.pointSize: ChatStyle.composingText.pointSize
					height: visible ? undefined : 0
					leftPadding: ChatStyle.composingText.leftPadding
					visible: composers.length > 0 && ( (!proxyModel.chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled)
														 || (proxyModel.chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled) )
					wrapMode: Text.Wrap
					//: '%1 is typing...' indicate that someone is composing in chat
					text:(composers.length==0?'': qsTr('chatTyping','',composers.length).arg(container.proxyModel.getDisplayNameComposers()))
				}
			}
			
			ChatMessagePreview{
				id: chatMessagePreview
				replyChatRoomModel: proxyModel.chatRoomModel
			}
			Rectangle{
				id: messageBlock
				height: opacity > 0 ? 32 : 0
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				anchors.leftMargin: ChatStyle.entry.leftMargin
				anchors.rightMargin: ChatStyle.entry.leftMargin
				anchors.bottomMargin: ChatStyle.entry.bottomMargin
				color: ChatStyle.messageBanner.color
				radius: 10
				state: "hidden"
				Timer{
					id: hideNoticeBanner
					interval: 4000
					repeat: false
					onTriggered: messageBlock.state = "hidden"
				}
				RowLayout{
					anchors.centerIn: parent
					spacing: 5
					Icon{
						icon: ChatStyle.copyTextIcon
						overwriteColor: ChatStyle.messageBanner.textColor
						iconSize: 20
					}
					Text{
						Layout.fillHeight: true
						Layout.fillWidth: true
						text: container.noticeBannerText
						font {
							pointSize: ChatStyle.messageBanner.pointSize
						}
						color: ChatStyle.messageBanner.textColor
					}
				}
				states: [
					State {
						name: "hidden"
						PropertyChanges { target: messageBlock; opacity: 0 }
					},
					State {
						name: "showed"
						PropertyChanges { target: messageBlock; opacity: 1 }
					}
				]
				transitions: [
					Transition {
						from: "*"; to: "showed"
						SequentialAnimation{
							NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 500 }
							ScriptAction{ script: hideNoticeBanner.start()}	
						}
					},
					Transition {
						SequentialAnimation{
							NumberAnimation{ properties: "opacity"; duration: 1000 }
							ScriptAction{ script: container.noticeBannerText = '' }
						}
					}
				]
			}
			
			ActionButton{
				anchors.bottom: messageBlock.top
				anchors.bottomMargin: 10
				anchors.right: parent.right
				anchors.rightMargin: 40
				visible: chat.isIndexAfter(chat.count-1)
				onVisibleChanged: container.proxyModel.markAsReadEnabled = !visible
				
				isCustom: true
				backgroundRadius: width/2
				colorSet: ChatStyle.gotToBottom
				onClicked: {
						chat.bindToEnd = true
					}
				MessageCounter{
					anchors.left: parent.right
					anchors.bottom: parent.top
					anchors.bottomMargin: -5
					anchors.leftMargin: -5
					count: container.proxyModel.chatRoomModel.unreadMessagesCount
				}
			}
			
			
		}
		
		// -------------------------------------------------------------------------
		// Send area.
		// -------------------------------------------------------------------------
		
		Borders {
			id: textAreaBorders
			Layout.fillWidth: true
			Layout.preferredHeight: textArea.height
			
			borderColor: ChatStyle.sendArea.border.color
			topWidth: ChatStyle.sendArea.border.width
			visible: proxyModel.chatRoomModel && !proxyModel.chatRoomModel.hasBeenLeft && (!proxyModel.chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled || proxyModel.chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled)
			
			
			DroppableTextArea {
				id: textArea
				
				enabled:proxyModel && proxyModel.chatRoomModel ? !proxyModel.chatRoomModel.hasBeenLeft:false
				isEphemeral : proxyModel && proxyModel.chatRoomModel ? proxyModel.chatRoomModel.ephemeralEnabled:false
				
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				
				height:ChatStyle.sendArea.height + ChatStyle.sendArea.border.width
				minimumHeight:ChatStyle.sendArea.height + ChatStyle.sendArea.border.width
				maximumHeight:container.height/2
				
				dropEnabled: SettingsModel.fileTransferUrl.length > 0
				dropDisabledReason: qsTr('noFileTransferUrl')
				placeholderText: qsTr('newMessagePlaceholder')
				
				onDropped: Logic.handleFilesDropped(files)
				onTextChanged: Logic.handleTextChanged(text)
				onValidText: {
					textArea.text = ''
					chat.bindToEnd = true
					if(proxyModel.chatRoomModel) {
						proxyModel.sendMessage(text)
					}else{
						console.log("Peer : " +proxyModel.peerAddress+ "/"+chat.model.peerAddress)
						proxyModel.chatRoomModel = CallsListModel.createChat(proxyModel.peerAddress)
						proxyModel.sendMessage(text)
					}
				}
				onAudioRecordRequest: RecorderManager.resetVocalRecorder()
				Component.onCompleted: {text = proxyModel.cachedText; cursorPosition=text.length}
				Rectangle{
					anchors.fill:parent
					color:'white'
					opacity: 0.5
					visible:!textArea.enabled
				}
			}
		}
	}
	
	
	
	// ---------------------------------------------------------------------------
	// Scroll at end if necessary.
	// ---------------------------------------------------------------------------
	
	Timer {
		interval: 100
		repeat: true
		running: true
		
		onTriggered: chat.bindToEnd && chat.positionViewAtEnd()
	}
	
}
