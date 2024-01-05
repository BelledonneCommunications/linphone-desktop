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

	function goToNewCall() {
		tabbar.currentIndex = 0
		callPage.goToNewCall()
	}

	function transferCallSucceed() {
		transferSucceedPopup.open()
	}

	Timer {
		id: autoClosePopup
		interval: 5000
		onTriggered: {
			transferSucceedPopup.close()
		} 
	}
	Popup {
		id: transferSucceedPopup
		onVisibleChanged: if (visible) autoClosePopup.restart()
		closePolicy: Control.Popup.NoAutoClose
		x : parent.x + parent.width - width
		y : parent.y + parent.height - height
		rightMargin: 20 * DefaultStyle.dp
		bottomMargin: 20 * DefaultStyle.dp
		padding: 20 * DefaultStyle.dp
		underlineColor: DefaultStyle.success_500main
		radius: 0
		contentItem: RowLayout {
			spacing: 15 * DefaultStyle.dp
			EffectImage {
				source: AppIcons.smiley
				colorizationColor: DefaultStyle.success_500main
				Layout.preferredWidth: 32 * DefaultStyle.dp
				Layout.preferredHeight: 32 * DefaultStyle.dp
				width: 32 * DefaultStyle.dp
				height: 32 * DefaultStyle.dp
			}
			Rectangle {
				Layout.preferredWidth: 1 * DefaultStyle.dp
				Layout.preferredHeight: parent.height
				color: DefaultStyle.main2_200
			}
			ColumnLayout {
				Text {
					text: qsTr("Appel transféré")
					color: DefaultStyle.success_500main
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Text {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					text: qsTr("Votre correspondant a été transféré au contact sélectionné")
					color: DefaultStyle.main2_500main
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
			}
		}
	}

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
						source: AppIcons.more
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
					id: callPage
				}
				//ContactPage{}
				//ConversationPage{}
				//MeetingPage{}
			}
		}
	}
} 
 
