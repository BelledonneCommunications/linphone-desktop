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
	
	// ---------------------------------------------------------------------------
	
	color: ChatStyle.color
	clip: true
	
	function positionViewAtIndex(index){
		chat.bindToEnd = false
		chat.positionViewAtIndex(index, ListView.Beginning)
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
			property bool bindToEnd: false
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
			section {
				criteria: ViewSection.FullString
				delegate: sectionHeading
				property: '$sectionDate'
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
			// Heading.
			// -----------------------------------------------------------------------
			
			Component {
				id: sectionHeading
				
				Item {
					implicitHeight: container.height + ChatStyle.sectionHeading.bottomMargin
					width: parent.width
					clip: false
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
				clip: false
				
				// ---------------------------------------------------------------------
				
				MouseArea {
					id: mouseArea
					
					cursorShape: Qt.ArrowCursor
					hoverEnabled: true
					implicitHeight: layout.height
					width: parent.width + parent.anchors.rightMargin
					clip: false
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
								
								text: UtilsCpp.toTimeString($chatEntry.timestamp, 'hh:mm')
								
								verticalAlignment: Text.AlignVCenter
								
								TooltipArea {
									text: UtilsCpp.toDateTimeString($chatEntry.timestamp)
								}
								visible:!isNotice
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
														remainingIndex = -1	// overwrite to remove signal changed. That way, there is no more binding loops.
														--chat.remainingLoadersCount // Loader is ready: remove one from remaining count.
													}
								
								Component.onCompleted: loaderIndex = ++chat.remainingLoadersCount	// on new Loader : one more remaining
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
							}
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
					color: ChatStyle.composingText.color
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
				visible: chat.isIndexAfter(chat.count-1)
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
			Layout.preferredHeight: textAreaBorders.height + chatMessagePreview.height+messageBlock.height
			color: ChatStyle.sendArea.backgroundBorder.color
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
				// -------------------------------------------------------------------------
				// Send area.
				// -------------------------------------------------------------------------
				
				Borders {
					id: textAreaBorders
					Layout.fillWidth: true
					Layout.preferredHeight: textArea.height
					Layout.leftMargin: ChatStyle.sendArea.backgroundBorder.width
					borderColor: ChatStyle.sendArea.border.color
					topWidth: ChatStyle.sendArea.border.width
					visible: proxyModel.chatRoomModel && !proxyModel.chatRoomModel.isReadOnly && (!proxyModel.chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled || proxyModel.chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled)
					
					DroppableTextArea {
						id: textArea
						
						enabled:proxyModel && proxyModel.chatRoomModel ? !proxyModel.chatRoomModel.isReadOnly:false
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
						recordAudioToggled: RecorderManager.haveVocalRecorder && RecorderManager.getVocalRecorder().state != LinphoneEnums.RecorderStateClosed
						
						onDropped: Logic.handleFilesDropped(files)
						onTextChanged: Logic.handleTextChanged(text)
						onValidText: {
							textArea.text = ''
							chat.bindToEnd = true
							if(proxyModel.chatRoomModel) {
								proxyModel.sendMessage(text)
							}else{
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
				}// Send Area
			}// ColumnLayout
		}// Bottom background
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

