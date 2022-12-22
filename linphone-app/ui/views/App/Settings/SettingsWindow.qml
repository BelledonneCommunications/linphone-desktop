import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Clipboard 1.0
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
	
	onClosing: {
		logViewer.active = false
		SettingsModel.settingsWindowClosing()
		tabBar.setCurrentIndex(0)
	}
	
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
		Item{
			Layout.fillWidth: true
			Layout.preferredHeight: TabButtonStyle.text.height
			RowLayout {
				anchors.fill: parent
				spacing: 0
				TabBar {
					id: tabBar
					
					onCurrentIndexChanged: SettingsModel.onSettingsTabChanged(currentIndex)
					spacing:0
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
						visible: SettingsModel.videoSupported
						iconName: TabButtonStyle.icon.videoIcon
						text: qsTr('videoTab')
						width: visible ? implicitWidth : 0
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
			Rectangle{
				id: hideBar
				anchors.fill: parent
				color: TabButtonStyle.backgroundColor.normal
				visible: logViewer.active
			}
		}
		
		// -------------------------------------------------------------------------
		// Content.
		// -------------------------------------------------------------------------
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
			StackLayout {
				anchors.fill: parent	
				
				currentIndex: tabBar.currentIndex
				SettingsSipAccounts {}
				SettingsAudio {}
				SettingsVideo {}
				SettingsCallsChat {}
				SettingsNetwork {}
				SettingsTunnel {}
				SettingsUi {}
				SettingsAdvanced {onShowLogs: logViewer.active=true }
			}
			Loader{
				id: logViewer
				anchors.fill: parent
				active: false
				sourceComponent: Component{
					Rectangle{
						id: logBackground
						anchors.fill: parent
						property variant stringList: null
						function updateText() {
							stringList = SettingsModel.getLogText().split('\n')
							idContentListView.positionViewAtEnd()
						}
						Component.onCompleted: updateText()
						ColumnLayout{
							anchors.fill: parent
							RowLayout{// Prepare for other actions
								ActionButton{
									Layout.topMargin: 5
									Layout.leftMargin: 5
									backgroundRadius: width/2
									isCustom: true
									colorSet: SettingsWindowStyle.buttons.back
									onClicked: logViewer.active = false
								}
								ActionButton{
									Layout.topMargin: 5
									Layout.leftMargin: 5
									backgroundRadius: width/2
									isCustom: true
									colorSet: SettingsWindowStyle.buttons.copy
									onClicked: {updating = true ; Clipboard.text = SettingsModel.getLogText();updating=false}
								}
							}
							ListView {
								id: idContentListView
								model: logBackground.stringList
								Layout.fillHeight: true
								Layout.fillWidth: true
								Layout.topMargin: 20
								Layout.leftMargin: 10
								Layout.rightMargin: 10
								clip: true
								
								delegate: Text {
									width: idContentListView.width
									text: model.modelData
									font.pointSize: FormTableStyle.entry.text.pointSize
									textFormat: Text.PlainText
									wrapMode: Text.Wrap
								}
								ScrollBar.vertical: ScrollBar {}
							}
						}
					}
				}
			}
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
