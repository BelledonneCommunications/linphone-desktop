import QtCore
import QtQuick
import QtQuick.Controls 2.15
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
	property var parentView
	property bool manageParticipants: false
    signal manageParticipantsRequested()
    signal ephemeralSettingsRequested()

	spacing: 0

	Avatar {
		Layout.alignment: Qt.AlignHCenter
		displayNameVal: mainItem.chatCore.avatarUri
		Layout.preferredWidth: Math.round(100 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(100 * DefaultStyle.dp)
	}
	
	RowLayout {
		id: titleMainItem
		property bool isEditingSubject: false
		property bool canEditSubject: mainItem.chatCore.meAdmin && mainItem.chatCore.isGroupChat
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(11 * DefaultStyle.dp)
		
		function saveSubject() {
			mainItem.chatCore.lSetSubject(title.text)
		}
		
		Item {
			visible: titleMainItem.canEditSubject
			Layout.preferredWidth: Math.round(18 * DefaultStyle.dp)
		}

		Rectangle {
			color: "transparent"
			border.color: titleMainItem.isEditingSubject ? DefaultStyle.main1_500_main : "transparent"
			border.width: 1
			radius: Math.round(4 * DefaultStyle.dp)
			Layout.preferredWidth: Math.round(150 * DefaultStyle.dp)
			Layout.preferredHeight: title.contentHeight
			anchors.margins: Math.round(2 * DefaultStyle.dp)

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
			Layout.preferredWidth: Math.round(18 * DefaultStyle.dp)
			Layout.preferredHeight: Math.round(18 * DefaultStyle.dp)

			EffectImage {
				anchors.fill: parent
				fillMode: Image.PreserveAspectFit
				imageSource: titleMainItem.isEditingSubject ? AppIcons.check : AppIcons.pencil
				colorizationColor: titleMainItem.isEditingSubject ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
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

	
	Text {
		font: Typography.p3
		color: DefaultStyle.main2_700
		text: mainItem.chatCore.peerAddress
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(5 * DefaultStyle.dp)
	}

	RowLayout {
		spacing: Math.round(10 * DefaultStyle.dp)
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(100 * DefaultStyle.dp)
		Layout.minimumHeight: Math.round(100 * DefaultStyle.dp)
		LabelButton {
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Math.round(130 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(130 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: chatCore.muted ? AppIcons.bell : AppIcons.bellSlash
			//: "Sourdine"
			label: chatCore.muted ? qsTr("group_infos_unmute") : qsTr("group_infos_mute")
			button.onClicked: chatCore.muted = !chatCore.muted
		}
		LabelButton {
			visible: !SettingsCpp.disableMeetingsFeature
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
			label: qsTr("group_infos_call")
			button.onClicked: parentView.groupCall()
		}
		LabelButton {
			visible: !SettingsCpp.disableMeetingsFeature
			text.Layout.fillWidth: true
			text.horizontalAlignment: Text.AlignHCenter
			text.wrapMode: Text.Wrap
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: Math.round(130 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(130 * DefaultStyle.dp)
			button.icon.width: Math.round(24 * DefaultStyle.dp)
			button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.videoconference
			//: "Réunion"
			label: qsTr("group_infos_meeting")
			button.onClicked: {
				UtilsCpp.getMainWindow().scheduleMeeting(mainItem.chatCore.title, mainItem.chatCore.participantsAddresses)
			}
		}
	}
	
	Component {
		id: participantList
		GroupChatInfoParticipants {
			Layout.fillWidth: true
			title: qsTr("group_infos_participants").arg(mainItem.chatCore.participants.length)
			participants: mainItem.chatCore.participants
			chatCore: mainItem.chatCore
			onManageParticipantsRequested: mainItem.manageParticipantsRequested()
		}
	}

	
	ScrollView {
		id: scrollView
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: Math.round(30 * DefaultStyle.dp)
		clip: true
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
		
		ColumnLayout {
			spacing: 0
			width: scrollView.width
			
			Loader {
				id: participantLoader
				Layout.fillWidth: true
				sourceComponent: participantList
				Connections {
					target: mainItem.chatCore
					onParticipantsChanged : { // hacky reload to update intric height
						participantLoader.active = false
						participantLoader.active = true
					}
				}
			}

			ChatInfoActionsGroup {
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
				Layout.topMargin: Math.round(17 * DefaultStyle.dp)
				title: qsTr("group_infos_other_actions")
				entries: [
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
		Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
	}
}
