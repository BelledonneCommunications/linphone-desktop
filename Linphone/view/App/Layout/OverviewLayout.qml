/**
* Qml template used for welcome and login/register pages
**/

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone

Item {
	id: mainItem

	RowLayout {
		spacing: 10
		Layout.fillHeight: true
		VerticalTabBar {
			Layout.fillHeight: true
		}
		ColumnLayout {
			Layout.fillHeight: true
			TextInput {
				fillWidth: true
				placeholderText: qsTr("Rechercher un contact, appeler ou envoyer un message...")
			}
			Image {
				//avatar
			}
			Button {
				// color: DefaultStyle.moreButtonBackground
			}
		}
	}
} 
 
