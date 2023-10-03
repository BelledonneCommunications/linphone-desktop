import QtQuick 2.15
import QtQuick.Layouts 1.0
import Linphone

Item{
	id: mainItem
	ColumnLayout{
		anchors.fill: parent
		Text{
			Layout.fillWidth: true
			text: LoginPageCpp.isLogged ? "Online" : "Offline"
		}
		RowLayout{
			Button{
				text: 'Sign In'
				onClicked: console.log("Click!")
			}
			Button{
				text: 'Sign Out'
				onClicked: console.log("Click!")
			}
		}
	}
}
 