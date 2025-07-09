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
	property var contactObj: chatGui ? UtilsCpp.findFriendByAddress(mainItem.chatCore.peerAddress) : null
	property var parentView
	spacing: 0
	signal ephemeralSettingsRequested()
	signal showSharedFilesRequested()
	signal searchInHistoryRequested()


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
		visible: contactObj && contactObj.value || false
		font: Typography.p3
		color: contactObj?.value != null ? contactObj?.value.core.presenceColor : "transparent"
		text: contactObj?.value != null ? contactObj?.value.core.presenceStatus : ""
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(5 * DefaultStyle.dp)
	}
	
	RowLayout {
		spacing: Math.round(10 * DefaultStyle.dp)
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(110 * DefaultStyle.dp)
		Layout.minimumHeight: Math.round(110 * DefaultStyle.dp)
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Math.round(130 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(130 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.phone
			//: "Appel"
			label: qsTr("one_one_infos_call")
			button.onClicked: parentView.oneOneCall(false)
		}
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Math.round(130 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(130 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: mainItem.chatCore.muted ? AppIcons.bell : AppIcons.bellSlash
			//: "Sourdine"
			label: mainItem.chatCore.muted ? qsTr("one_one_infos_unmute") : qsTr("one_one_infos_mute")
			button.onClicked: {
				mainItem.chatCore.muted = !mainItem.chatCore.muted
			}
		}
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Math.round(130 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(130 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.search
			//: "Rechercher"
			label: qsTr("one_one_infos_search")
			button.onClicked: {
				mainItem.searchInHistoryRequested()
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
					mainItem.showSharedFilesRequested(true)
				}
			},
			{
				icon: AppIcons.pdf,
				visible: true,
				text: qsTr("one_one_infos_shared_docs"),
				color: DefaultStyle.main2_600,
				showRightArrow: true,
				action: function() {
					mainItem.showSharedFilesRequested(false)
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
				visible: !mainItem.chatCore.isReadOnly,
				text: mainItem.chatCore.ephemeralEnabled ? qsTr("one_one_infos_ephemerals")+UtilsCpp.getEphemeralFormatedTime(mainItem.chatCore.ephemeralLifetime) : qsTr("one_one_infos_enable_ephemerals"),
				color: DefaultStyle.main2_600,
				showRightArrow: false,
				action: function() {
					mainItem.ephemeralSettingsRequested()
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
