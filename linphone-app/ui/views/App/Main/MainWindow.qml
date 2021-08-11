import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'MainWindow.js' as Logic

// =============================================================================

ApplicationWindow {
	id: window
	
	property string _currentView
	property var _lockedInfo
	
	// ---------------------------------------------------------------------------
	
	function lockView (info) {
		Logic.lockView(info)
	}
	
	function unlockView () {
		Logic.unlockView()
	}
	
	function setView (view, props) {
		Logic.setView(view, props)
	}
	
	// ---------------------------------------------------------------------------
	// Window properties.
	// ---------------------------------------------------------------------------
	
	minimumHeight: MainWindowStyle.minimumHeight
	minimumWidth: MainWindowStyle.minimumWidth
	
	title: Utils.capitalizeFirstLetter(Qt.application.name)
	
	// ---------------------------------------------------------------------------
	
	onActiveFocusItemChanged: Logic.handleActiveFocusItemChanged(activeFocusItem)
	onClosing: Logic.handleClosing(close)
	
	// ---------------------------------------------------------------------------
	
	Connections {
		target: CoreManager
		onCoreManagerInitialized: mainLoader.active = true
	}
	
	Shortcut {
		sequence: StandardKey.Close
		onActivated: window.hide()
	}
	// ---------------------------------------------------------------------------
	
	Loader {
		id: mainLoader
		
		active: false
		anchors.fill: parent
		
		sourceComponent: ColumnLayout {
			// Workaround to get these properties in `MainWindow.js`.
			readonly property alias contactsEntry: contactsEntry
			readonly property alias contentLoader: contentLoader
			readonly property alias conferencesEntry: conferencesEntry
			readonly property alias menu: menu
			
			readonly property alias timeline: timeline
			
			spacing: 0
			
			// -----------------------------------------------------------------------
			
			AuthenticationNotifier {
				onAuthenticationRequested: Logic.handleAuthenticationRequested(authInfo, realm, sipAddress, userId)
			}
			
			// -----------------------------------------------------------------------
			// Toolbar properties.
			// -----------------------------------------------------------------------
			
			ToolBar {
				Layout.fillWidth: true
				Layout.preferredHeight: MainWindowStyle.toolBar.height
				hoverEnabled : true
				
				background: MainWindowStyle.toolBar.background
				
				RowLayout {
					anchors {
						fill: parent
						leftMargin: MainWindowStyle.toolBar.leftMargin
						rightMargin: MainWindowStyle.toolBar.rightMargin
					}
					spacing: MainWindowStyle.toolBar.spacing
					
					ActionButton {
						icon: (leftPanel.visible?'panel_shown':'panel_hidden')
						tooltipText : (leftPanel.visible?'Open Timeline':'Hide Timeline')
						iconSize: MainWindowStyle.panelButtonSize
						//autoIcon: true
						onClicked: leftPanel.visible = !leftPanel.visible
					}
					ActionButton {
						icon: 'home'
						tooltipText : 'Open Home'
						iconSize: MainWindowStyle.homeButtonSize
						//autoIcon: true
						onClicked: setView('Home')
					}
					
					AccountStatus {
						id: accountStatus
						betterIcon:true
						Layout.preferredHeight: parent.height
						Layout.preferredWidth: MainWindowStyle.accountStatus.width
						Layout.fillWidth: false
						//height: parent.height
						//width: MainWindowStyle.accountStatus.width
						
						TooltipArea {
							text: AccountSettingsModel.sipAddress
							hoveringCursor: Qt.PointingHandCursor
						}
						
						onClicked:  {
							CoreManager.forceRefreshRegisters()
							Logic.manageAccounts()
						}
					}
					
					ColumnLayout {
						Layout.preferredWidth: MainWindowStyle.autoAnswerStatus.width
						visible: SettingsModel.autoAnswerStatus
						
						Icon {
							icon: SettingsModel.autoAnswerStatus
								  ? 'auto_answer'
								  : ''
							iconSize: MainWindowStyle.autoAnswerStatus.iconSize
						}
						
						Text {
							clip: true
							color: MainWindowStyle.autoAnswerStatus.text.color
							font {
								bold: true
								pointSize: MainWindowStyle.autoAnswerStatus.text.pointSize
							}
							text: qsTr('autoAnswerStatus')
							visible: SettingsModel.autoAnswerStatus
							width: parent.width
						}
					}
					
					SmartSearchBar {
						id: smartSearchBar
						
						Layout.fillWidth: true
						
						maxMenuHeight: MainWindowStyle.searchBox.maxHeight
						placeholderText: qsTr('mainSearchBarPlaceholder')
						tooltipText: qsTr('smartSearchBarTooltip')
						
						onAddContact: window.setView('ContactEdit', {
														 sipAddress: sipAddress
													 })
						
						onEntryClicked: {
							if (entry.contact && SettingsModel.contactsEnabled) {
								window.setView('ContactEdit', { sipAddress: entry.sipAddress })
							} else {
								CallsListModel.createChatRoom( "", false, [entry] )
							}
						}
						
						onLaunchCall: CallsListModel.launchAudioCall(sipAddress)
						onLaunchChat: CallsListModel.launchChat( sipAddress,0 )
						onLaunchSecureChat: CallsListModel.launchChat( sipAddress,1 )
						onLaunchVideoCall: CallsListModel.launchVideoCall(sipAddress)
					}
					
					
					ActionButton {
						icon: 'new_chat_group'
						//: 'Open Conference' : Tooltip to illustrate a button
						tooltipText : qsTr('newChatRoom')
						iconSize: MainWindowStyle.newConferenceSize
						//autoIcon: true
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/NewChatRoom.qml')
													   ,{})
						}
					}
					
					ActionButton {
						icon: 'new_conference'
						iconSize: MainWindowStyle.newConferenceSize
						visible: SettingsModel.conferenceEnabled
						tooltipText:qsTr('newConferenceButton')
						//autoIcon: true
						
						onClicked: Logic.openConferenceManager()
					}
					
					ActionButton {
						icon: 'burger_menu'
						iconSize: MainWindowStyle.menuBurgerSize
						visible: Qt.platform.os !== 'osx'
						
						onClicked: menuBar.open()
						MainWindowMenuBar {
							id: menuBar
						}
						
					}
					
				}
			}
			Loader{
				active:Qt.platform.os === 'osx'
				sourceComponent:MainWindowTopMenuBar{}
			}
			// -----------------------------------------------------------------------
			// Content.
			// -----------------------------------------------------------------------
			
			RowLayout {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				spacing: 0
				
				// Main menu.
				ColumnLayout {
					id:leftPanel
					Layout.maximumWidth: MainWindowStyle.menu.width
					Layout.preferredWidth: MainWindowStyle.menu.width
					
					spacing: 0
					
					ApplicationMenu {
						id: menu
						
						defaultSelectedEntry: null
						
						entryHeight: MainWindowStyle.menu.height+10
						entryWidth: MainWindowStyle.menu.width
						
						ApplicationMenuEntry {
							id: contactsEntry
							
							icon: 'contact'
							name: qsTr('contactsEntry')
							visible: SettingsModel.contactsEnabled
							
							onSelected: {
								timeline.model.unselectAll() 
								setView('Contacts')
							}
							Icon{
								anchors.right:parent.right
								anchors.verticalCenter: parent.verticalCenter
								anchors.rightMargin: 10
								icon:'panel_arrow'
								iconSize:10
								
							}
						}
						
						ApplicationMenuEntry {
							visible : false	//TODO
							id: conferencesEntry
							
							icon: 'conferences'
							iconSize: 32
							name: 'MES CONFERENCES'
							
							onSelected: window.setView('HistoryView')
						}
					}
					
					// History.
					Timeline {
						id: timeline
						
						Layout.fillHeight: true
						Layout.fillWidth: true
						model: TimelineProxyModel{}
						
						onEntrySelected:{ 
							if( entry ) {
								window.setView('Conversation', {
												   chatRoomModel:entry.chatRoomModel
												   
											   })
							}else{
								
								window.setView('Home', {})
							}
							menu.resetSelectedEntry()
						}
					}
				}
				
				// Main content.
				Loader {
					id: contentLoader
					
					objectName: '__contentLoader'
					
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					source: 'Home.qml'
					Component.onCompleted: if (AccountSettingsModel.accounts.length < 2) source= 'Assistant.qml' // default proxy = 1. Do not use this set diretly in source because of bindings that will override next setSource
				}
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Url handlers.
	// ---------------------------------------------------------------------------
	
	Connections {
		target: UrlHandlers
		
		onSip: window.setView('Conversation', {
								  peerAddress: sipAddress,
								  localAddress: AccountSettingsModel.sipAddress,
								  fullPeerAddress: sipAddress,
								  fullLocalAddress: AccountSettingsModel.fullSipAddress
							  })
	}
}
