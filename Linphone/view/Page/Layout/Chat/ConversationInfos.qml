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
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
	property ChatGui chatGui
	property var chatCore: chatGui.core
	property var contactObj: chatGui ? UtilsCpp.findFriendByAddress(mainItem.chatCore.peerAddress) : null
	property FriendGui contact: contactObj ? contactObj.value : null
	property bool isAppFriend: contact && contact.core.isAppFriend
	property bool isGroup: chatCore && chatCore.isGroupChat
	spacing: 0
	signal ephemeralSettingsRequested()
	signal showSharedFilesRequested(bool showMedias)
	signal manageParticipantsRequested()

	signal oneOneCall(bool video)
	signal groupCall()

	Avatar {
		Layout.alignment: Qt.AlignHCenter
		contact: mainItem.contact
		displayNameVal: mainItem.chatCore.avatarUri
		secured: mainItem.chatGui && mainItem.chatGui.core.isSecured
		Layout.preferredWidth: Utils.getSizeWithScreenRatio(100)
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
		PopupButton {
			id: debugButton
			z: parent.z + 1
			icon.source: ""
			anchors.right: parent.right
			anchors.top: parent.top
			hoverEnabled: false
			MouseArea {
				z: parent.z + 1
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onPressAndHold: (mouse) => {
					if (mouse.button === Qt.RightButton) debugButton.popup.open()
				}
			}
			popup.contentItem: RowLayout {
				Text {
					id: chatroomaddress
					text: chatCore?.chatRoomAddress || ""
				}
				SmallButton {
					icon.source: AppIcons.copy
					onClicked: {
						UtilsCpp.copyToClipboard(chatroomaddress.text)
						debugButton.close()
					}
					style: ButtonStyle.noBackground
				}
			}
		}
	}

	Component {
		id: groupTitleContent
		RowLayout {
			id: titleMainItem
			property bool isEditingSubject: false
			property bool canEditSubject: mainItem.chatCore.meAdmin && mainItem.chatCore.isGroupChat
			
			function saveSubject() {
				mainItem.chatCore.lSetSubject(title.text)
			}
			
			Item {
				visible: titleMainItem.canEditSubject
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(18)
			}

			Rectangle {
				color: "transparent"
				border.color: titleMainItem.isEditingSubject ? DefaultStyle.main1_500_main : "transparent"
				border.width: 1
				radius: Utils.getSizeWithScreenRatio(4)
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(150)
				Layout.preferredHeight: title.contentHeight
				anchors.margins: Utils.getSizeWithScreenRatio(2)

				TextEdit {
					id: title
					anchors.fill: parent
					anchors.margins: 6
					font: Typography.p1
					color: DefaultStyle.main2_700
					text: mainItem.chatCore.title || ""
					enabled: titleMainItem.isEditingSubject
					wrapMode: TextEdit.Wrap
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					Keys.onReturnPressed: {
						if (titleMainItem.isEditingSubject)
							titleMainItem.saveSubject()
						titleMainItem.isEditingSubject = !titleMainItem.isEditingSubject
					}
				}
			}

			Item {
				visible: titleMainItem.canEditSubject
				Layout.alignment: Qt.AlignVCenter
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(18)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(18)

				EffectImage {
					anchors.fill: parent
					fillMode: Image.PreserveAspectFit
					imageSource: titleMainItem.isEditingSubject ? AppIcons.check : AppIcons.pencil
					colorizationColor: titleMainItem.isEditingSubject ? DefaultStyle.main1_500_main : DefaultStyle.main2_500_main
				}

				MouseArea {
					id: editMouseArea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						if (titleMainItem.isEditingSubject)
							titleMainItem.saveSubject()
						titleMainItem.isEditingSubject = !titleMainItem.isEditingSubject
					}
					cursorShape: Qt.PointingHandCursor
				}
			}
		}
	}

	Component {
		id: oneOneTitleContent
		Text {
			font: Typography.p1
			color: DefaultStyle.main2_700
			text: mainItem.chatCore.title || ""
		}
	}
	
	Loader {
		id: titleLayout
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Utils.getSizeWithScreenRatio(11)
		sourceComponent: mainItem.isGroup ? groupTitleContent : oneOneTitleContent
	}
	
	Text {
		font: Typography.p3
		color: DefaultStyle.main2_700
		text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(mainItem.chatCore.peerAddress) : mainItem.chatCore.peerAddress
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Utils.getSizeWithScreenRatio(5)
	}
	
	Text {
		visible: mainItem.contact
		font: Typography.p3
		color: mainItem.contact ? mainItem.contact.core.presenceColor : "transparent"
		text: mainItem.contact ? mainItem.contact.core.presenceStatus : ""
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Utils.getSizeWithScreenRatio(5)
	}
	
	RowLayout {
		visible: !mainItem.chatCore.isReadOnly
		spacing: Utils.getSizeWithScreenRatio(10)
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Utils.getSizeWithScreenRatio(30)
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(110)
		Layout.minimumHeight: Utils.getSizeWithScreenRatio(110)
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(130)
			Layout.maximumWidth: Utils.getSizeWithScreenRatio(130)
			button.icon.width: Utils.getSizeWithScreenRatio(24)
			button.icon.height: Utils.getSizeWithScreenRatio(24)
			button.icon.source: AppIcons.phone
			//: "Appel"
			label: qsTr("one_one_infos_call")
			button.onClicked: mainItem.isGroup ? mainItem.groupCall() : mainItem.oneOneCall(false)
		}
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(130)
			Layout.maximumWidth: Utils.getSizeWithScreenRatio(130)
			button.icon.width: Utils.getSizeWithScreenRatio(24)
			button.icon.height: Utils.getSizeWithScreenRatio(24)
			button.icon.source: mainItem.chatCore.muted ? AppIcons.bell : AppIcons.bellSlash
			//: "Sourdine"
			label: mainItem.chatCore.muted ? qsTr("one_one_infos_unmute") : qsTr("one_one_infos_mute")
			button.onClicked: {
				mainItem.chatCore.muted = !mainItem.chatCore.muted
			}
		}
		LabelButton {
			visible: !mainItem.isGroup || !SettingsCpp.disableMeetingsFeature
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(130)
			Layout.maximumWidth: Utils.getSizeWithScreenRatio(130)
			button.icon.width: Utils.getSizeWithScreenRatio(24)
			button.icon.height: Utils.getSizeWithScreenRatio(24)
			button.icon.source: mainItem.isGroup 
				? AppIcons.videoconference
				: mainItem.isAppFriend
					? AppIcons.adressBook 
					: AppIcons.plusCircle
			label: mainItem.isGroup
				//: Schedule a meeting
				? qsTr("group_infos_meeting") 
				: mainItem.isAppFriend
					//: Show contact
					? qsTr("one_one_infos_open_contact") 
					//: Create contact
					: qsTr("one_one_infos_create_contact")
			button.onClicked: {
				if (mainItem.isGroup)
					UtilsCpp.getMainWindow().scheduleMeeting(mainItem.chatCore.title, mainItem.chatCore.participantsAddresses)
				else {
					if (mainItem.isAppFriend)
						mainWindow.displayContactPage(mainItem.contact.core.defaultAddress)
					else
						mainWindow.displayCreateContactPage("",mainItem.chatCore.peerAddress)
				}
			}
		}
	}

	Control.ScrollView {
		id: scrollView
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: Utils.getSizeWithScreenRatio(30)
		clip: true
		Layout.leftMargin: Utils.getSizeWithScreenRatio(15)

		Control.ScrollBar.vertical: ScrollBar {
			id: scrollbar
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			visible: scrollView.contentHeight > scrollView.height
		}
		
		ColumnLayout {
			spacing: 0
			width: scrollView.width - scrollbar.width - Utils.getSizeWithScreenRatio(5)
			
			Loader {
				id: participantLoader
				Layout.fillWidth: true
				active: mainItem.isGroup
				sourceComponent: GroupChatInfoParticipants {
					Layout.fillWidth: true
					title: qsTr("group_infos_participants").arg(mainItem.chatCore.participants.length)
					participants: mainItem.chatCore.participants
					chatCore: mainItem.chatCore
					onManageParticipantsRequested: mainItem.manageParticipantsRequested()
				}
				Connections {
					target: mainItem.chatCore
					onParticipantsChanged : { // hacky reload to update intric height
						participantLoader.active = false
						participantLoader.active = true
					}
				}
			}

			ChatInfoActionsGroup {
				Layout.topMargin: Utils.getSizeWithScreenRatio(30)
				//: Medias & documents
				title: qsTr("group_infos_media_docs")
				entries: [
					{
						icon: AppIcons.photo,
						visible: true,
						//: Shared medias
						text: qsTr("group_infos_shared_medias"),
						color: DefaultStyle.main2_600,
						showRightArrow: true,
						action: function() {
							mainItem.showSharedFilesRequested(true)
						}
					},
					{
						icon: AppIcons.pdf,
						visible: true,
						//: Shared documents
						text: qsTr("group_infos_shared_docs"),
						color: DefaultStyle.main2_600,
						showRightArrow: true,
						action: function() {
							mainItem.showSharedFilesRequested(false)
						}
					}
				]
			}
		
			ChatInfoActionsGroup {
				Layout.topMargin: Utils.getSizeWithScreenRatio(17)
				//: Other actions
				title: qsTr("group_infos_other_actions")
				entries: mainItem.isGroup
				? [
					{
						icon: AppIcons.clockCountDown,
						visible: !mainItem.chatCore.isReadOnly,
						text: mainItem.chatCore.ephemeralEnabled ? qsTr("group_infos_ephemerals")+UtilsCpp.getEphemeralFormatedTime(mainItem.chatCore.ephemeralLifetime) : qsTr("group_infos_enable_ephemerals"),
						color: DefaultStyle.main2_600,
						showRightArrow: false,
						action: function() {
							mainItem.ephemeralSettingsRequested()
						}
					},
					{
						icon: AppIcons.signOut,
						visible: !mainItem.chatCore.isReadOnly,
						//: Leave chat room
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
									mainItem.chatCore.lLeave()
								}
							})
						}
					},
					{
						icon: AppIcons.trashCan,
						visible: true,
						//: Delete history
						text: qsTr("group_infos_delete_history"),
						color: DefaultStyle.danger_500_main,
						showRightArrow: false,
						action: function() {
							//: Delete history ?
							mainWindow.showConfirmationLambdaPopup(qsTr("group_infos_delete_history_toast_title"),
								//: All the messages will be removed from the chat room. Do you want to continue ?
								qsTr("group_infos_delete_history_toast_message"),
								"",
								function(confirmed) {
									if (confirmed) {
										mainItem.chatCore.lDeleteHistory()
									}
								})
						}
					}
				]
				: [
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
						color: DefaultStyle.danger_500_main,
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
		}
	}

	Item {
		Layout.fillHeight: true
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
	}
}
