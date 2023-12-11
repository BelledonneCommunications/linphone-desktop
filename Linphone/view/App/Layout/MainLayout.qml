/**
* Qml template used for welcome and login/register pages
**/

import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone
import UtilsCpp

Item {
	id: mainItem
	
	signal addAccountRequest()

	RowLayout {
		anchors.fill: parent
		// spacing: 30
		anchors.topMargin: 18 * DefaultStyle.dp
		VerticalTabBar {
			id: tabbar
			Layout.fillHeight: true
			model: [
				{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
				{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
				{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations")},
				{icon: AppIcons.usersThree, selectedIcon: AppIcons.usersThreeSelected, label: qsTr("Réunions")}
			]
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			RowLayout {
				id: topRow
				Layout.leftMargin: 25 * DefaultStyle.dp
				Layout.rightMargin: 41 * DefaultStyle.dp
				SearchBar {
					Layout.fillWidth: true
					placeholderText: qsTr("Rechercher un contact, appeler ou envoyer un message...")
				}
				Control.Button {
					id: avatarButton
					AccountProxy{
						id: accountProxy
						//property bool haveAvatar: defaultAccount && defaultAccount.core.pictureUri || false
					}
					
					Layout.preferredWidth: 54 * DefaultStyle.dp
					Layout.preferredHeight: width
					background: Item {
						visible: false
					}
					contentItem: Avatar {
						id: avatar
						height: avatarButton.height
						width: avatarButton.width
						account: accountProxy.defaultAccount
					}
					onClicked: {
						accountList.open()
					}
				}
				Control.Button {
					id: settingsButton
					enabled: false
					Layout.preferredWidth: 30 * DefaultStyle.dp
					Layout.preferredHeight: 30 * DefaultStyle.dp
					background: Item {
					}
					contentItem: Image {
						source: AppIcons.verticalDots
					}
					Popup{
						id: accountList
						x: -width + parent.width
						y: settingsButton.height + (10 * DefaultStyle.dp)
						contentWidth: accounts.width
						contentHeight: accounts.height
						Accounts{
							id: accounts
							onAddAccountRequest: mainItem.addAccountRequest()
						}
					}
				}
			}
			StackLayout {
				// width: parent.width
				// height: parent.height

				currentIndex: tabbar.currentIndex

				CallPage {
				}
				//ContactPage{}
				//ConversationPage{}
				//MeetingPage{}
			}
		}
	}
} 
 
