import QtQuick 2.7
import Qt.labs.platform 1.0

import Linphone 1.0

// =============================================================================

MenuBar {
	function open () {
		menu.open()
	}

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
			onTriggered: Qt.quit()
			shortcut: StandardKey.Quit
			
		}
	}
}
