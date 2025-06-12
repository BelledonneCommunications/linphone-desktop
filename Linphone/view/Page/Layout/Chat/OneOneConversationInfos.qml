import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	property ChatGui chatGui
	property var chatCore: chatGui.core
	property var contactObj: chat ? UtilsCpp.findFriendByAddress(mainItem.chatCore.peerAddress) : null
	spacing: 0

	Avatar {
		Layout.alignment: Qt.AlignHCenter
		contact: contactObj?.value || null
		displayNameVal: contact ? "" : mainItem.chatCore.avatarUri
		Layout.preferredWidth: Math.round(100 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(100 * DefaultStyle.dp)
	}
	
	Text {
		font: Typography.p1
		color: DefaultStyle.main2_700
		text: mainItem.chatCore.title || ""
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(11 * DefaultStyle.dp)
	}
	
	Text {
		font: Typography.p3
		color: DefaultStyle.main2_700
		text: mainItem.chatCore.peerAddress
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(5 * DefaultStyle.dp)
	}
	
	Text {
		visible: contactObj?.value
		font: Typography.p3
		color: contactObj?.value != null ? contactObj?.value.core.presenceColor : "transparent"
		text: contactObj?.value != null ? contactObj?.value.core.presenceStatus : ""
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(5 * DefaultStyle.dp)
	}
	
	RowLayout {
		spacing: Math.round(55 * DefaultStyle.dp)
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		LabelButton {
			width: Math.round(56 * DefaultStyle.dp)
			height: Math.round(56 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.phone
			//: "Appel"
			label: qsTr("one_one_infos_call")
			button.onClicked: {
				mainWindow.startCallWithContact(contactObj.value, false, mainItem)
			}
		}
		LabelButton {
			width: Math.round(56 * DefaultStyle.dp)
			height: Math.round(56 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: mainItem.chatCore.muted ? AppIcons.bell : AppIcons.bellSlash
			//: "Sourdine"
			label: qsTr("one_one_infos_mute")
			button.onClicked: {
				mainItem.chatCore.muted = !mainItem.chatCore.muted
			}
		}
		LabelButton {
			width: Math.round(56 * DefaultStyle.dp)
			height: Math.round(56 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.search
			//: "Rechercher"
			label: qsTr("one_one_infos_search")
			button.onClicked: {
				//TODO
			}
		}
	}

	ChatInfoActionsGroup {
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(12 * DefaultStyle.dp)
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		title: qsTr("one_one_infos_media_docs")
		entries: [
			{
				icon: AppIcons.photo,
				visible: true,
				text: qsTr("one_one_infos_shared_media"),
				color: DefaultStyle.main2_600,
				showRightArrow: true,
				action: function() {
					console.log("Opening shared media")
				}
			},
			{
				icon: AppIcons.pdf,
				visible: true,
				text: qsTr("one_one_infos_shared_docs"),
				color: DefaultStyle.main2_600,
				showRightArrow: true,
				action: function() {
					console.log("Opening shared documents")
				}
			}
		]
	}
	
	ChatInfoActionsGroup {
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(12 * DefaultStyle.dp)
		Layout.topMargin: Math.round(17 * DefaultStyle.dp)
		title: qsTr("one_one_infos_other_actions")
		entries: [
			{
				icon: contactObj.value ? AppIcons.adressBook : AppIcons.plusCircle,
				visible: true,
				text: contactObj.value ? qsTr("one_one_infos_open_contact") : qsTr("one_one_infos_create_contact"),
				color: DefaultStyle.main2_600,
				showRightArrow: false,
				action: function() {
					// contactObj.value = friendGui
					if (contactObj.value)
						mainWindow.displayContactPage(contactObj.value.core.defaultAddress)
					else
						mainWindow.displayCreateContactPage("",mainItem.chatCore.peerAddress)
				}
			},
			{
				icon: AppIcons.clockCountDown,
				visible: true,
				text: mainItem.chatCore.ephemeralEnabled ? qsTr("one_one_infos_disable_ephemerals") : qsTr("one_one_infos_enable_ephemerals"),
				color: DefaultStyle.main2_600,
				showRightArrow: false,
				action: function() {
					mainItem.chatCore.ephemeralEnabled = !mainItem.chatCore.ephemeralEnabled
				}
			},
			{
				icon: AppIcons.trashCan,
				visible: true,
				text: qsTr("one_one_infos_delete_history"),
				color: DefaultStyle.danger_500main,
				showRightArrow: false,
				action: function() {
					//: Delete history ?
					mainWindow.showConfirmationLambdaPopup(qsTr("one_one_infos_delete_history_toast_title"),
						//: All the messages will be removed from the chat room. Do you want to continue ?
						qsTr("one_one_infos_delete_history_toast_message"),
						"",
						function(confirmed) {
							if (confirmed) {
								mainItem.chatCore.lDeleteHistory()
							}
						})
				}
			}
		]
	}

	Item {
		Layout.fillHeight: true
	}
}
