import QtQuick 2.7
import Qt.labs.platform 1.0

import Linphone 1.0

// =============================================================================

MenuBar {
	id: menuBar
	function open () {
		menu.open()
	}
	signal displayRecordings()
	
	// ---------------------------------------------------------------------------
	// Menu.
	// ---------------------------------------------------------------------------
	//
	Menu {
		id: menu
		title: qsTr('settings')

		MenuItem {
			text: qsTr('settings')
			role: MenuItem.PreferencesRole
			onTriggered: App.smartShowWindow(App.getSettingsWindow())
			shortcut: StandardKey.Preferences
		}
		
		MenuItem {
			visible: CoreManager.initialized && SettingsModel.callRecorderEnabled
			//: 'Recordings' : Label for the recordings menu.
			text: qsTr('recordings')
			role: MenuItem.ApplicationSpecificRole
			onTriggered: menuBar.displayRecordings()
		}

		MenuItem {
			visible: CoreManager.initialized && SettingsModel.isCheckForUpdateAvailable()
			//: 'Check for updates' : Item menu for checking updates
			text: qsTr('checkForUpdates')
			role: MenuItem.ApplicationSpecificRole
			onTriggered: App.checkForUpdates(true)
		}

		MenuItem {
			text: qsTr('about')
			role: MenuItem.AboutRole
			onTriggered: {
				window.detachVirtualWindow()
				window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/About.qml'))
			}
			shortcut: StandardKey.HelpContents
		}

		MenuItem {
			text: qsTr('quit')
			role: MenuItem.QuitRole
			onTriggered: {
				console.info("Exiting App from Top Menu");
				Qt.quit()
			}
			shortcut: StandardKey.Quit
			
		}
	}
}
