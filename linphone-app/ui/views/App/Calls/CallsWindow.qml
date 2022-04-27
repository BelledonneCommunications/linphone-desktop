import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'CallsWindow.js' as Logic

// =============================================================================

Window {
	id: window
	
	// ---------------------------------------------------------------------------
	
	// `{}` is a workaround to avoid `TypeError: Cannot read property...` when calls list is empty
	readonly property CallModel call: calls.selectedCall
	/*
	?calls.selectedCall:{
														  callError: '',
														  isOutgoing: true,
														  recording: false,
														  localSas: '',
														  peerAddress: '',
														  localAddress: '',
														  type: false,
														  updating: true,
														  videoEnabled: false, 
														  chatRoomModel:null
													  });
													  */
	property ConferenceInfoModel conferenceInfoModel
	
	readonly property bool chatIsOpened: !rightPaned.isClosed()
	readonly property bool callsIsOpened: !mainPaned.isClosed()
	
	
	// ---------------------------------------------------------------------------
	
	function openChat () {
		rightPaned.open()
	}
	
	function closeChat () {
		rightPaned.close()
	}
	
	function endOfProcess(exitValue){
		window.detachVirtualWindow();
		if(exitValue == 0 && calls.count == 0)
			close();
	}
	
	function openConferenceManager (params) {
		Logic.openConferenceManager(params, endOfProcess)
	}
	
	function setHeight (height) {
		window.height = (Window.screen && height > Window.screen.desktopAvailableHeight)
				? Window.screen.desktopAvailableHeight
				: height
	}
	
	// ---------------------------------------------------------------------------
	
	minimumHeight: CallsWindowStyle.minimumHeight
	minimumWidth: CallsWindowStyle.minimumWidth
	title: qsTr('callsTitle')
	
	// ---------------------------------------------------------------------------
	onClosing: Logic.handleClosing(close)
	onDetachedVirtualWindow: Logic.tryToCloseWindow()
	
	// ---------------------------------------------------------------------------
	
	Paned {
		id: mainPaned
		anchors.fill: parent
		defaultChildAWidth: CallsWindowStyle.callsList.defaultWidth
		maximumLeftLimit: CallsWindowStyle.callsList.maximumWidth
		minimumLeftLimit: CallsWindowStyle.callsList.minimumWidth
		
		// -------------------------------------------------------------------------
		// Calls list.
		// -------------------------------------------------------------------------
		
		childA: Rectangle {
			id: leftPaned
			anchors.fill: parent
			color: CallsWindowStyle.callsList.color
			
			ColumnLayout {
				anchors.fill: parent
				spacing: 0
				
				Item {
					Layout.fillWidth: true
					Layout.preferredHeight: CallsWindowStyle.callsList.header.height
					
					visible: SettingsModel.outgoingCallsEnabled || SettingsModel.conferenceEnabled
					
					LinearGradient {
						anchors.fill: parent
						
						start: Qt.point(0, 0)
						end: Qt.point(0, height)
						
						gradient: Gradient {
							GradientStop { position: 0.0; color: CallsWindowStyle.callsList.header.color1 }
							GradientStop { position: 1.0; color: CallsWindowStyle.callsList.header.color2 }
						}
					}
					
					ActionBar {
						anchors {
							left: parent.left
							leftMargin: CallsWindowStyle.callsList.header.leftMargin
							verticalCenter: parent.verticalCenter
						}
						
						iconSize: CallsWindowStyle.callsList.header.iconSize
						
						ActionButton {
							isCustom: true
							backgroundRadius: 4
							colorSet: CallsWindowStyle.callsList.newCall
							visible: SettingsModel.outgoingCallsEnabled
							
							onClicked: Logic.openCallSipAddress()
						}
						
						ActionButton {
							isCustom: true
							backgroundRadius: 4
							colorSet: CallsWindowStyle.callsList.newConference
							visible: SettingsModel.conferenceEnabled
							
							onClicked: {
								Logic.openConferenceManager()
							}
						}
					}
					ActionButton {
						anchors.right: parent.right
						anchors.rightMargin: 15
						anchors.verticalCenter: parent.verticalCenter
						isCustom: true
						backgroundRadius: 4
						colorSet: CallsWindowStyle.callsList.closeButton
						
						onClicked: mainPaned.close()
					}
				}
				
				Calls {
					id: calls
					
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					conferenceModel: ConferenceProxyModel {}
					model: CallsListProxyModel {}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Content.
		// -------------------------------------------------------------------------
		
		childB: Paned {
			id: rightPaned
			
			anchors.fill: parent
			closingEdge: Qt.RightEdge
			defaultClosed: true
			minimumLeftLimit: CallsWindowStyle.call.minimumWidth
			minimumRightLimit: CallsWindowStyle.chat.minimumWidth
			resizeAInPriority: true
			
			// -----------------------------------------------------------------------
			
			Component {
				id: incomingCall
				
				IncomingCall {
					call: window.call
				}
			}
			
			Component {
				id: outgoingCall
				
				OutgoingCall {
					call: window.call
				}
			}
			
			Component {
				id: incall
				
				Incall {
					call: window.call
				}
			}
			
			Component {
				id: endedCall
				
				EndedCall {
					call: window.call
				}
			}
			
			Component {
				id: chat
				
				Chat {
					proxyModel: ChatRoomProxyModel {
						Component.onCompleted: {
							if (chatRoomModel
									&& (!chatRoomModel.haveEncryption && !SettingsModel.standardChatEnabled || chatRoomModel.haveEncryption && !SettingsModel.secureChatEnabled)) {
								setEntryTypeFilter(ChatRoomModel.CallEntry | ChatRoomModel.NoticeEntry)
							}
						}
						chatRoomModel: window.call.chatRoomModel
						peerAddress: window.call.peerAddress
						fullPeerAddress: window.call.fullPeerAddress
						fullLocalAddress: window.call.fullLocalAddress
						localAddress: window.call.localAddress
					}
					
					Connections {
						target: SettingsModel
						onStandardChatEnabledChanged: if(!chatRoomModel.haveEncryption) proxyModel.setEntryTypeFilter(status ? ChatRoomModel.GenericEntry : ChatRoomModel.CallEntry  | ChatRoomModel.NoticeEntry)
						onSecureChatEnabledChanged: if(chatRoomModel.haveEncryption) proxyModel.setEntryTypeFilter(status ? ChatRoomModel.GenericEntry : ChatRoomModel.CallEntry  | ChatRoomModel.NoticeEntry)
					}
				}
			}
			
			Component {
				id: conference
				
				Conference {
					conferenceModel: calls.conferenceModel
				}
			}
			
			Component {
				id: waitingRoom
				WaitingRoom{
					conferenceInfoModel: window.conferenceInfoModel
					onCancel: endOfProcess(0)
					enabled: window.visible
				}
			}
			Component {
				id: videoConference
				VideoConference {
					callModel: window.call
					listCallsOpened: window.callsIsOpened
					onOpenListCallsRequest: mainPaned.open()
					enabled: window.visible
				}
			}
			
			// -----------------------------------------------------------------------
			
			childA: Loader {
				id: middlePane
				anchors.fill: parent
				sourceComponent: Logic.getContent(window.call, window.conferenceInfoModel)
				onSourceComponentChanged: {
					if( sourceComponent == waitingRoom)
						mainPaned.close()
					rightPaned.childAItem.update()
				}// Force update when loading a new Content. It's just to be sure
				active: window.call || window.conferenceInfoModel
			}
			
			childB: Loader {
				anchors.fill: parent
				sourceComponent: window.call && window.call.peerAddress && window.call.localAddress ? chat : null
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Handle transfer.
	// Handle count changed. Not on proxy model!!!
	// ---------------------------------------------------------------------------
	
	Connections {
		target: CallsListModel
		onCallTransferAsked: Logic.handleCallTransferAsked(callModel)
		onCallAttendedTransferAsked: Logic.handleCallAttendedTransferAsked(callModel)
		onCallConferenceAsked: Logic.openWaitingRoom(conferenceInfoModel)
		onRowsRemoved: Logic.tryToCloseWindow()
	}
}
