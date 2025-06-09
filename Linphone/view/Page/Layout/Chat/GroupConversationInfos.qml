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
	property var chat
	spacing: 0

	Avatar {
		Layout.alignment: Qt.AlignHCenter
		displayNameVal: mainItem.chat.core.avatarUri
		Layout.preferredWidth: Math.round(100 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(100 * DefaultStyle.dp)
	}
	
	Text {
		font: Typography.p1
		color: DefaultStyle.main2_700
		text: mainItem.chat?.core.title || ""
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(11 * DefaultStyle.dp)
	}
	
	Text {
		font: Typography.p3
		color: DefaultStyle.main2_700
		text: mainItem.chat?.core.peerAddress
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
			button.icon.source: chat.core.muted ? AppIcons.bell : AppIcons.bellSlash
			//: "Sourdine"
			label: qsTr("group_infos_mute")
			button.onClicked: {
				chat.core.muted = !chat.core.muted
			}
		}
		LabelButton {
			width: Math.round(56 * DefaultStyle.dp)
			height: Math.round(56 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.phone
			//: "Appel"
			label: qsTr("group_infos_call")
			button.onClicked: {
				//TODO
			}
		}
		LabelButton {
			width: Math.round(56 * DefaultStyle.dp)
			height: Math.round(56 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.videoconference
			//: "Réunion"
			label: qsTr("group_infos_meeting")
			button.onClicked: {
				//TODO
			}
		}
	}

	ChatInfoActionsGroup {
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(12 * DefaultStyle.dp)
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		title: qsTr("group_infos_media_docs")
		entries: [
			{
				icon: AppIcons.photo,
				visible: true,
				text: qsTr("group_infos_media_docs"),
				color: DefaultStyle.main2_600,
				showRightArrow: true,
				action: function() {
					console.log("group_infos_shared_media")
				}
			},
			{
				icon: AppIcons.pdf,
				visible: true,
				text: qsTr("group_infos_shared_docs"),
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
		title: qsTr("group_infos_other_actions")
		entries: [
			{
				icon: AppIcons.clockCountDown,
				visible: true,
				text: mainItem.chat.core.ephemeralEnabled ? qsTr("group_infos_disable_ephemerals") : qsTr("group_infos_enable_ephemerals"),
				color: DefaultStyle.main2_600,
				showRightArrow: false,
				action: function() {
					mainItem.chat.core.ephemeralEnabled = !mainItem.chat.core.ephemeralEnabled
				}
			},
			{
				icon: AppIcons.signOut,
				visible: !mainItem.chat.core.isReadOnly,
				text: qsTr("group_infos_leave_room"),
				color: DefaultStyle.main2_600,
				showRightArrow: false,
				action: function() {
				//: Leave Chat Room ?
					mainWindow.showConfirmationLambdaPopup(qsTr("group_infos_leave_room_toast_title"),
					//: All the messages will be removed from the chat room. Do you want to continue ?
					qsTr("group_infos_leave_room_toast_message"),
					"",
					function(confirmed) {
						if (confirmed) {
							mainItem.chat.core.lLeave()
						}
					})
				}
			},
			{
				icon: AppIcons.trashCan,
				visible: true,
				text: qsTr("group_infos_delete_history"),
				color: DefaultStyle.danger_500main,
				showRightArrow: false,
				action: function() {
					//: Delete history ?
					mainWindow.showConfirmationLambdaPopup(qsTr("group_infos_delete_history_toast_title"),
						//: All the messages will be removed from the chat room. Do you want to continue ?
						qsTr("group_infos_delete_history_toast_message"),
						"",
						function(confirmed) {
							if (confirmed) {
								mainItem.chat.core.lDeleteHistory()
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
