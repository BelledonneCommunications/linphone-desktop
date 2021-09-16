import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Konami 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

ApplicationWindow {
	id: window
	
	minimumHeight: SettingsWindowStyle.height
	minimumWidth: SettingsWindowStyle.width
	
	title: qsTr('settingsTitle')
	
	onClosing: SettingsModel.settingsWindowClosing()
	
	// ---------------------------------------------------------------------------
	
	Shortcut {
		sequence: StandardKey.Close
		onActivated: window.hide()
	}
	
	// ---------------------------------------------------------------------------
	
	Rectangle {
		anchors.fill: parent
		color: SettingsWindowStyle.color
	}
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Navigation bar.
		// -------------------------------------------------------------------------
		
		RowLayout {
			Layout.fillWidth: true
			spacing: 0
			
			TabBar {
				id: tabBar
				
				onCurrentIndexChanged: SettingsModel.onSettingsTabChanged(currentIndex)
				
				TabButton {
					iconName: TabButtonStyle.icon.sipAccountsIcon
					text: qsTr('sipAccountsTab')
					width: implicitWidth
				}
				
				TabButton {
					iconName: TabButtonStyle.icon.audioIcon
					text: qsTr('audioTab')
					width: implicitWidth
				}
				
				TabButton {
					enabled: SettingsModel.videoSupported
					iconName: TabButtonStyle.icon.videoIcon
					text: qsTr('videoTab')
					width: implicitWidth
				}
				
				TabButton {
					iconName: TabButtonStyle.icon.callIcon
					text: qsTr('callsAndChatTab')
					width: implicitWidth
				}
				
				TabButton {
					enabled: SettingsModel.showNetworkSettings || SettingsModel.developerSettingsEnabled
					iconName: TabButtonStyle.icon.networkIcon
					text: qsTr('networkTab')
					width: implicitWidth
				}
				
				TabButton {
					visible: SettingsModel.tunnelAvailable()
					enabled: visible			
					iconName: TabButtonStyle.icon.sipAccountsIcon
					//: 'Tunnel' : Tab title for tunnel section in settings.
					text: qsTr('tunnelTab')
					width: visible ? implicitWidth : 0
				}
				
				TabButton {
					iconName: TabButtonStyle.icon.advancedIcon
					text: qsTr('uiTab')
					width: implicitWidth
				}
				
				TabButton {
					iconName: TabButtonStyle.icon.advancedIcon
					text: qsTr('uiAdvanced')
					width: implicitWidth
				}
			}
			
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: TabButtonStyle.text.height
				
				color: TabButtonStyle.backgroundColor.normal
				
				MouseArea {
					anchors.fill: parent
					
					onClicked: konami.forceActiveFocus()
					cursorShape: Qt.ArrowCursor
					
					Konami {
						id: konami
						onTriggered: SettingsModel.developerSettingsEnabled = true
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Content.
		// -------------------------------------------------------------------------
		
		StackLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			currentIndex: tabBar.currentIndex
			SettingsSipAccounts {}
			SettingsAudio {}
			SettingsVideo {}
			SettingsCallsChat {}
			SettingsNetwork {}
			SettingsTunnel {}
			SettingsUi {}
			SettingsAdvanced {}
		}
		
		// -------------------------------------------------------------------------
		// Buttons.
		// -------------------------------------------------------------------------
		
		TextButtonB {
			Layout.alignment: Qt.AlignRight
			Layout.topMargin: SettingsWindowStyle.validButton.topMargin
			Layout.bottomMargin: SettingsWindowStyle.validButton.bottomMargin
			Layout.rightMargin: SettingsWindowStyle.validButton.rightMargin
			
			text: qsTr('validButton')
			
			onClicked: window.close()
		}
	}
}
