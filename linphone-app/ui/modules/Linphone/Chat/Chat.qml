import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import Units 1.0

import 'Chat.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle {
	id: container
	
	property alias proxyModel: chat.model	// ChatRoomProxyModel
	property alias tryingToLoadMoreEntries : chat.tryToLoadMoreEntries
	
	property alias noticeBannerText : messageBlock.noticeBannerText	// When set, show a banner with text and hide after some time
	
	
	// ---------------------------------------------------------------------------
	
	signal messageToSend (string text)
	signal addContactClicked(string contactAddress)
	signal viewContactClicked(string contactAddress)
	
	
	// ---------------------------------------------------------------------------
	
	color: ChatStyle.colorModel.color
	clip: true
	Timer{// Let some time to have a better cell sizes
		id: repositionerDelay
		property int indexToMove
		interval: 100
		onTriggered: chat.positionViewAtIndex(indexToMove, ListView.Center)
	}
	function positionViewAtIndex(index){
		chat.bindToEnd = false
		chat.positionViewAtIndex(index, ListView.Center)
		repositionerDelay.indexToMove = index
		repositionerDelay.restart()
	}
	
	function goToMessage(message){
		positionViewAtIndex(container.proxyModel.loadTillMessage(message))
	}
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		ScrollableListView {
			id: chat
			// -----------------------------------------------------------------------
			property bool displaying: false
			property bool loadingEntries: (container.proxyModel.chatRoomModel && container.proxyModel.chatRoomModel.entriesLoading) || displaying
			property bool tryToLoadMoreEntries: loadingEntries || remainingLoadersCount>0
			property bool isMoving : false	// replace moving read-only property to allow using movement signals.
			
// Load optimizations
			property int remainingLoadersCount: 0
			property int syncLoaderBatch: 50	// batch of simultaneous loaders on synchronous mode
//------------------------------------
						
			onLoadingEntriesChanged: {
				if( loadingEntries && !displaying)
					displaying = true
			}
			onBindToEndChanged: if( bindToEnd){
				markAsReadTimer.start()
			}
			Timer{
				id: markAsReadTimer
				interval: 5000
				repeat: false
				running: false
				onTriggered: if(container.proxyModel.chatRoomModel) container.proxyModel.chatRoomModel.resetMessageCount()
			}
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			clip: false
			highlightFollowsCurrentItem: false
			// Use moving event => this is a user action.
			onIsMovingChanged:{
				if(!chat.isMoving && chat.atYBeginning && !chat.loadingEntries){// Moving has stopped. Check if we are at beginning
					chat.displaying = true
					container.proxyModel.loadMoreEntriesAsync()
				}
			}
			// -----------------------------------------------------------------------
			Component.onCompleted: Logic.initView()
			onMovementStarted: {Logic.handleMovementStarted(); chat.isMoving = true}
			onMovementEnded: {Logic.handleMovementEnded(); chat.isMoving = false}
			
			// -----------------------------------------------------------------------
			
			Connections {
				target: proxyModel
				
				// When the view is changed (for example `Calls` -> `Messages`),
				// the position is set at end and it can be possible to load
				// more entries.
				onEntryTypeFilterChanged: Logic.initView()
				
				onMoreEntriesLoaded: {
					Logic.handleMoreEntriesLoaded(n)// move view to n - 1 item
					chat.displaying = false
				}
			}
			
			// -----------------------------------------------------------------------
			// Message/Event renderer.
			// -----------------------------------------------------------------------
			
			delegate: Rectangle {
				id: entry
				property bool isNotice : $chatEntry && ($chatEntry.type === ChatRoomModel.NoticeEntry)
				property bool isCall : $chatEntry && ($chatEntry.type === ChatRoomModel.CallEntry)
				property bool isMessage : $chatEntry && ($chatEntry.type === ChatRoomModel.MessageEntry)
				property var previousItem : proxyModel.count > 0 && index >0 ? proxyModel.getAt(index-1) : null
				property var nextItem : proxyModel.count > 0 ? proxyModel.getAt(index+1) : null	// bind to count
				property bool displayDate: $chatEntry && !Utils.equalDate(new Date($chatEntry.timestamp), new Date())
				property bool isTopGrouped: isGrouped(entry.previousItem, $chatEntry) || false
				property bool isBottomGrouped: isGrouped($chatEntry, entry.nextItem) || false
				
				onIsBottomGroupedChanged: if(loader.item) loader.item.isBottomGrouped = isBottomGrouped
				onIsTopGroupedChanged: if(loader.item) loader.item.isTopGrouped = isTopGrouped
				
				function isGrouped(item1, item2){
					return item1 && item2  //Have a previous entry
											&& item1.type == ChatRoomModel.MessageEntry // Previous entry is a message
											&& item2.type == ChatRoomModel.MessageEntry // Previous entry is a message
											&& item2.fromSipAddress == item1.fromSipAddress // Same user
											&& Math.abs((new Date(item2.timestamp)).getTime() - (new Date(item1.timestamp)).getTime())/1000 < 60
				}
				function isHoverEntry () {
					return mouseArea.containsMouse
				}
				
				function removeEntry () {
					proxyModel.removeRow(index)
				}
				color: ChatStyle.colorModel.color
				implicitHeight: layout.height + (entry.isBottomGrouped? 1 : ChatStyle.entry.bottomMargin)
				
				width: chat.contentWidth	// Fill all space
				clip: false
				
				
				// ---------------------------------------------------------------------
				
				MouseArea {
					id: mouseArea
					
					cursorShape: Qt.ArrowCursor
					hoverEnabled: true
					implicitHeight: layout.height
					width: parent.width + parent.anchors.rightMargin
					anchors.top: parent.top
					//anchors.topMargin: (entry.isTopGrouped? 1 : ChatStyle.entry.bottomMargin)
					clip: false
					acceptedButtons: Qt.NoButton
					onContainsMouseChanged: if(loader.item) loader.item.isHovering = containsMouse
					ColumnLayout{
						id: layout
						spacing: 0
						width: entry.width
						RowLayout{
							id: headerLayout
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignTop | ($chatEntry && $chatEntry.isOutgoing ? Qt.AlignRight : Qt.AlignLeft)
							Layout.leftMargin: ChatStyle.entry.metaWidth// + ChatStyle.entry.message.extraContent.spacing
							Layout.rightMargin: ChatStyle.entry.message.outgoing.areaSize
							spacing:0
							// Display time.
							visible: !entry.isTopGrouped
							Text {
								id:timeDisplay
								Layout.alignment: Qt.AlignTop | ($chatEntry && $chatEntry.isOutgoing ? Qt.AlignRight : Qt.AlignLeft)
								Layout.preferredHeight: implicitHeight// ChatStyle.entry.lineHeight
								//Layout.preferredWidth: ChatStyle.entry.time.width
								
								color: ChatStyle.entry.event.text.colorModel.color
								font.pointSize: ChatStyle.entry.time.pointSize
								property bool displayYear: entry.displayDate && (new Date($chatEntry.timestamp)).getFullYear() != (new Date()).getFullYear()
								text: $chatEntry
											? (entry.displayDate ? UtilsCpp.toDateString($chatEntry.timestamp, (displayYear ? 'yyyy/':'') + 'MM/dd') + ' ' : '')
													+ UtilsCpp.toTimeString($chatEntry.timestamp, 'hh:mm') + (authorName.visible ? ' - ' : '')
											: ''
								
								verticalAlignment: Text.AlignVCenter
								
								TooltipArea {
									text: $chatEntry ? UtilsCpp.toDateTimeString($chatEntry.timestamp) : ''
								}
								visible:!isNotice
							}
							Text{
								id:authorName
								//Layout.leftMargin: timeDisplay.width + ChatStyle.entry.metaWidth + ChatStyle.entry.message.extraContent.spacing
								property var displayName: $chatEntry ? $chatEntry.fromDisplayName ? $chatEntry.fromDisplayName : $chatEntry.name : ''
								text : displayName != undefined ? displayName : ''
								
								color: ChatStyle.entry.event.text.colorModel.color
								font.pointSize: ChatStyle.entry.event.text.pointSize
								visible: isMessage 
										 && $chatEntry != undefined
										 && !$chatEntry.isOutgoing // Only outgoing
										 && (!entry.previousItem  //No previous entry
											 || entry.previousItem.type != ChatRoomModel.MessageEntry // Previous entry is a message
											 || entry.previousItem.fromSipAddress != $chatEntry.fromSipAddress // Different user
											 || (new Date(entry.previousItem.timestamp)).setHours(0, 0, 0, 0) != (new Date($chatEntry.timestamp)).setHours(0, 0, 0, 0) // Same day == section
											 )
							}
						}
						// Display content.
						Loader {
							id: loader
							height: (item !== null && typeof(item)!== 'undefined')? item.height: 0
							Layout.fillWidth: true
							source: Logic.getComponentFromEntry($chatEntry)
							property int loaderIndex: 0	// index of loader from remaining loaders
							property int remainingIndex : loaderIndex % ((chat.remainingLoadersCount) / chat.syncLoaderBatch) != 0	// Check loader index to remaining loader.
							onRemainingIndexChanged: if( remainingIndex == 0 && asynchronous) asynchronous = false
							asynchronous: true
							z:1
						
							onStatusChanged:	if( status == Loader.Ready) {
													loader.item.isTopGrouped = entry.isTopGrouped
													loader.item.isBottomGrouped = entry.isBottomGrouped
													remainingIndex = -1	// overwrite to remove signal changed. That way, there is no more binding loops.
													--chat.remainingLoadersCount // Loader is ready: remove one from remaining count.
												}
							
							Component.onCompleted: {
								loaderIndex = ++chat.remainingLoadersCount	// on new Loader : one more remaining
							}
							Component.onDestruction: if( status != Loader.Ready) --chat.remainingLoadersCount	// Remove remaining count if not loaded
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
																	var chat = CallsListModel.createChatRoom( '', proxyModel.chatRoomModel.haveEncryption, [sipAddress], false )
																	if(chat){
																		chat.chatRoomModel.forwardMessage($chatEntry)
																		TimelineListModel.select(chat.chatRoomModel)
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
							
							onGoToMessage:{
								container.goToMessage(message)	// sometimes, there is no access to chat id (maybe because of cleaning component while loading new items). Use a global intermediate.
							}
							onConferenceIcsCopied: container.noticeBannerText = qsTr('conferencesCopiedICS')
							onAddContactClicked: container.addContactClicked(contactAddress)
							onViewContactClicked: container.viewContactClicked(contactAddress)
						}
					}
				}
			}
			footer: Item{
				implicitHeight: composersItem.implicitHeight
				width: parent.width
				clip: false
				Text {
					id: composersItem
					property var composers : container.proxyModel.chatRoomModel ? container.proxyModel.chatRoomModel.composers : undefined
					property int count : composers && composers.length ? composers.length : 0
					color: ChatStyle.composingText.colorModel.color
					font.pointSize: ChatStyle.composingText.pointSize
					height: visible ? undefined : 0
					leftPadding: ChatStyle.composingText.leftPadding
					visible: count > 0 && ( (!proxyModel.chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled)
														 || (proxyModel.chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled) )
					wrapMode: Text.Wrap
					//: '%1 is typing...' indicate that someone is composing in chat
					text:(count==0?'': qsTr('chatTyping','',count).arg(container.proxyModel.getDisplayNameComposers()))
				}
			}
						
			ActionButton{
				id: gotToBottomButton
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 10
				anchors.right: parent.right
				anchors.rightMargin: 35
				visible: !chat.endIsDisplayed
				onVisibleChanged: updateMarkAsRead()
				Component.onCompleted: updateMarkAsRead()
				function updateMarkAsRead(){
					if(!visible)
						container.proxyModel.markAsReadEnabled = true
				}
				
				Connections{
					target: container.proxyModel
					onMarkAsReadEnabledChanged: if( !container.proxyModel.markAsReadEnabled)
													gotToBottomButton.updateMarkAsRead()
				}
				
				isCustom: true
				backgroundRadius: width/2
				colorSet: ChatStyle.gotToBottom
				onClicked: {
						chat.bindToEnd = true
					}
				MessageCounter{
					anchors.left: parent.right
					anchors.bottom: parent.top
					anchors.bottomMargin: 0
					anchors.leftMargin: -14
					count: container.proxyModel.chatRoomModel ? container.proxyModel.chatRoomModel.unreadMessagesCount : 0
					showOnlyNumber: true
					iconSize: 15
					pointSize: Units.dp * 7
				}
			}
			
		}
		Rectangle {
			id: bottomChatBackground
			Layout.fillWidth: true
			Layout.preferredHeight: textAreaBorders.height + chatMessagePreview.height+messageBlock.height + chatEmojis.height
			color: ChatStyle.sendArea.backgroundBorder.colorModel.color
			visible: proxyModel.chatRoomModel && !proxyModel.chatRoomModel.isReadOnly && (!proxyModel.chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled || proxyModel.chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled)
			
			ColumnLayout{
				anchors.fill: parent				
				spacing: 0
				MessageBanner{
					id: messageBlock
					onHeightChanged: height = Layout.preferredHeight
					Layout.fillWidth: true
					Layout.preferredHeight: fitHeight
					Layout.leftMargin: ChatStyle.entry.leftMargin
					Layout.rightMargin: ChatStyle.entry.rightMargin
					noticeBannerText: ''
				}
				ChatMessagePreview{
						id: chatMessagePreview
						Layout.fillWidth: true
						Layout.leftMargin: ChatStyle.sendArea.backgroundBorder.width
						maxHeight: container.height - textAreaBorders.height
						replyChatRoomModel: proxyModel.chatRoomModel
						replyRightMargin: textArea.textRightMargin
						replyLeftMargin: textArea.textLeftMargin
						
				}
				ChatEmojis{
					id: chatEmojis
					onEmojiClicked: textArea.insertEmoji(emoji)
					Layout.fillWidth: true
				}
				// -------------------------------------------------------------------------
				// Send area.
				// -------------------------------------------------------------------------
				
				Borders {
					id: textAreaBorders
					Layout.fillWidth: true
					Layout.preferredHeight: textArea.height
					Layout.leftMargin: ChatStyle.sendArea.backgroundBorder.width
					borderColor: ChatStyle.sendArea.border.colorModel.color
					topWidth: ChatStyle.sendArea.border.width
					
					DroppableTextArea {
						id: textArea
						
						enabled:proxyModel && proxyModel.chatRoomModel ? !proxyModel.chatRoomModel.isReadOnly:false
						isEphemeral : proxyModel && proxyModel.chatRoomModel ? proxyModel.chatRoomModel.ephemeralEnabled:false
						
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						
						height: visible ? ChatStyle.sendArea.height + ChatStyle.sendArea.border.width : 0
						minimumHeight:ChatStyle.sendArea.height + ChatStyle.sendArea.border.width
						maximumHeight:container.height/2
						
						dropEnabled: SettingsModel.fileTransferUrl.length > 0
						dropDisabledReason: qsTr('noFileTransferUrl')
						placeholderText: qsTr('newMessagePlaceholder')
						recordAudioToggled: RecorderManager.haveVocalRecorder && RecorderManager.getVocalRecorder().state != LinphoneEnums.RecorderStateClosed
						emojiVisible: chatEmojis.visible
						onDropped: Logic.handleFilesDropped(files)
						property bool componentReady: false
						onTextChanged: {// This slot can be call before the item has been completed because of Rich text. So the cache must not take it account.
								if(componentReady) {
									proxyModel.cachedText=text
								}
							}
						onValidText: {
							textArea.text = ''
							chat.bindToEnd = true
							if(proxyModel.chatRoomModel) {
								proxyModel.sendMessage(text)//Note : 'text' is coming from validText. It's not the text member.
							}else{
								proxyModel.chatRoomModel = CallsListModel.createChat(proxyModel.peerAddress)
								proxyModel.sendMessage(text)
							}
						}
						onAudioRecordRequest: RecorderManager.resetVocalRecorder()
						onEmojiClicked: {
							chatEmojis.visible = !chatEmojis.visible
						}
						Component.onCompleted: {text = proxyModel.cachedText; cursorPosition=text.length;componentReady=true}
						Rectangle{
							anchors.fill:parent
							color:'white'
							opacity: 0.5
							visible:!textArea.enabled
						}
					}
				}// Send Area
			}// ColumnLayout
		}// Bottom background
	}
}

