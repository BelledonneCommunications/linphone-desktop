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
	property CallModel call: calls.selectedCall
	onCallChanged: if(!call && conferenceInfoModel) {conferenceInfoModel = null}
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
	readonly property bool haveChat: rightPane.sourceComponent
	
	
	
	// ---------------------------------------------------------------------------
	
	function openChat () {
		rightPaned.open()
	}
	
	function closeChat () {
		rightPaned.close()
	}
	
	function endOfProcess(exitValue){
		window.detachVirtualWindow();
		if(exitValue == 0 && calls.count == 0 && middlePane.sourceComponent != waitingRoom) {
			close();
		}
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
		defaultClosed: true
		maximumLeftLimit: CallsWindowStyle.callsList.maximumWidth
		minimumLeftLimit: CallsWindowStyle.callsList.minimumWidth
		
		hideSplitter: !window.callsIsOpened && middlePane.sourceComponent == incall || middlePane.sourceComponent == waitingRoom
		
		// -------------------------------------------------------------------------
		// Calls list.
		// -------------------------------------------------------------------------
		
		childA: Rectangle {
			id: leftPaned
			anchors.fill: parent
			color: CallsWindowStyle.callsList.colorModel.color
			
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
							GradientStop { position: 0.0; color: CallsWindowStyle.callsList.header.color1.color }
							GradientStop { position: 1.0; color: CallsWindowStyle.callsList.header.color2.color }
						}
					}
					RowLayout{
						anchors.fill: parent
						ActionBar {
							Layout.leftMargin: CallsWindowStyle.callsList.header.leftMargin
							Layout.alignment: Qt.AlignVCenter
							
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
								colorSet: CallsWindowStyle.callsList.mergeConference
								visible: SettingsModel.conferenceEnabled
								enabled: CallsListModel.canMergeCalls
								
								onClicked: {
									CallsListModel.mergeAll()
								}
							}
						}
						Item{// Spacer
							Layout.fillWidth: true
						}
						ActionButton {
							Layout.alignment: Qt.AlignVCenter
							Layout.rightMargin: 15
							isCustom: true
							backgroundRadius: 4
							colorSet: CallsWindowStyle.callsList.closeButton
							
							onClicked: mainPaned.close()
						}
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
			
			hideSplitter: !window.chatIsOpened && (!middlePane.sourceComponent || middlePane.sourceComponent == incall || !rightPane.sourceComponent)
			// -----------------------------------------------------------------------
			
			Component {
				id: incomingCall
				
				IncomingCall {
					call: window.call
				}
			}
			
			Component {
				id: chat
				
				Chat {
					anchors.fill: parent
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
						isCall: true	// Used for cleaning data if there are no call associated to this chat room.
					}
					
					Connections {
						target: SettingsModel
						onStandardChatEnabledChanged: if(!chatRoomModel.haveEncryption) proxyModel.setEntryTypeFilter(status ? ChatRoomModel.GenericEntry : ChatRoomModel.CallEntry  | ChatRoomModel.NoticeEntry)
						onSecureChatEnabledChanged: if(chatRoomModel.haveEncryption) proxyModel.setEntryTypeFilter(SettingsModel.secureChatEnabled ? ChatRoomModel.GenericEntry : ChatRoomModel.CallEntry  | ChatRoomModel.NoticeEntry)
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
					onCancel: {
						endOfProcess(0)
						window.conferenceInfoModel = null
						calls.refreshLastCall()
					}
					enabled: window.visible
					callModel: window.call
				}
			}
			Component {
				id: incall
				Incall {
					callModel: window.call
					enabled: window.visible
					listCallsOpened: window.callsIsOpened
					onOpenListCallsRequest: mainPaned.open()
					onIsFullScreenChanged:	if(isFullScreen){
												window.hide()
											}else{
												window.show()
											}
				}
			}
			
			// -----------------------------------------------------------------------
			
			childA: Loader {
				id: middlePane
				anchors.fill: parent
				sourceComponent: Logic.getContent(window.call, window.conferenceInfoModel)
				property var lastComponent: null
				onSourceComponentChanged: {
											if(lastComponent != sourceComponent){
												if( sourceComponent == waitingRoom)
													mainPaned.close()
												rightPaned.childAItem.update()
												if(!sourceComponent && calls.count == 0)
													window.close()
												lastComponent = sourceComponent
											}
						
										}// Force update when loading a new Content. It's just to be sure
				active: window.call || window.conferenceInfoModel
			}
			
			childB: Loader {
				id: rightPane
				anchors.fill: parent
				sourceComponent: window.call && window.call.chatRoomModel ? chat : null
				onSourceComponentChanged: if(!sourceComponent) window.closeChat()
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
