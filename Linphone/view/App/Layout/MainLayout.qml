/**
* Qml template used for welcome and login/register pages
**/

import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Dialogs 

import Linphone
import UtilsCpp

Item {
	id: mainItem

	RowLayout {
		anchors.fill: parent
		// spacing: 30
		anchors.topMargin: 18
		VerticalTabBar {
			id: tabbar
			Layout.fillHeight: true
			Layout.preferredWidth: width
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
				Layout.leftMargin: 25
				TextInput {
					fillWidth: true
					placeholderText: qsTr("Rechercher un contact, appeler ou envoyer un message...")
				}
				Control.Button {
					id: avatarButton
					AccountProxy{
						id: accountProxy
						property bool haveAvatar: defaultAccount && defaultAccount.core.pictureUri || false
					}
					
					Layout.preferredWidth: 30
					Layout.preferredHeight: 30
					background: Item {
						visible: false
					}
					contentItem: Image {
						id: avatar
						source: accountProxy.haveAvatar ? accountProxy.defaultAccount.core.pictureUri : AppIcons.welcomeLinphoneLogo
						fillMode: Image.PreserveAspectFit
					}
					onClicked: {
							fileDialog.open()
					}
					FileDialog {
						 id: fileDialog
						 currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
						 onAccepted: {
							var avatarPath = UtilsCpp.createAvatar( selectedFile )
							if(avatarPath){
								accountProxy.defaultAccount.core.pictureUri = avatarPath
							}
						}
					 }
				}
				Control.Button {
					enabled: false
					Layout.preferredWidth: 30
					Layout.preferredHeight: 30
					background: Item {
					}
					contentItem: Image {
						source: AppIcons.verticalDots
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
 
