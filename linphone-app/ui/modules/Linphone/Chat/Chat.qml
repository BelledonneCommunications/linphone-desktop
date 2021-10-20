import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import UtilsCpp 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle {
	id: container
	
	property alias proxyModel: chat.model	// ChatRoomProxyModel
	property alias tryingToLoadMoreEntries : chat.tryToLoadMoreEntries
	
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
								Layout.fillWidth: true
								source: Logic.getComponentFromEntry($chatEntry)
							}
						}
					}
				}
			}
			
			footer: Text {
				property var composers : container.proxyModel.composers
				color: ChatStyle.composingText.color
				font.pointSize: ChatStyle.composingText.pointSize
				height: visible ? undefined : 0
				leftPadding: ChatStyle.composingText.leftPadding
				visible: composers.length > 0 && SettingsModel.chatEnabled
				wrapMode: Text.Wrap
				//: '%1 is typing...' indicate that someone is composing in chat
				text:(composers.length==0?'': qsTr('chatTyping','',composers.length).arg(container.proxyModel.getDisplayNameComposers()))
			}
		}
		
		// -------------------------------------------------------------------------
		// Send area.
		// -------------------------------------------------------------------------
		
		Borders {
			Layout.fillWidth: true
			Layout.preferredHeight: textArea.height
			
			borderColor: ChatStyle.sendArea.border.color
			topWidth: ChatStyle.sendArea.border.width
			visible: SettingsModel.chatEnabled && proxyModel.chatRoomModel && !proxyModel.chatRoomModel.hasBeenLeft
			
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
					if(proxyModel.chatRoomModel)
						proxyModel.sendMessage(text)
					else{
						console.log("Peer : " +proxyModel.peerAddress+ "/"+chat.model.peerAddress)
						proxyModel.chatRoomModel = CallsListModel.createChat(proxyModel.peerAddress)
						proxyModel.sendMessage(text)
					}
				}
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
