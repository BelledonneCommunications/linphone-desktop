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
    property var title: String
    property var participants
    property var chatCore
    signal manageParticipantsRequested()
    
    function isGroupEditable() {
    	return chatCore && chatCore.meAdmin && !chatCore.isReadOnly
	}

	RowLayout {
		Text {
			font: Typography.h4
			color: DefaultStyle.main2_600
			text: title
			Layout.topMargin: Math.round(5 * DefaultStyle.dp)
		}
		Item{Layout.fillWidth: true}
		BigButton {
			id: expandButton
			style: ButtonStyle.noBackground
			checkable: true
			checked: true
			icon.source: checked ? AppIcons.upArrow : AppIcons.downArrow
		}
	}

	Control.Control {
		visible: expandButton.checked
		Layout.fillWidth: true
		Layout.topMargin: Math.round(9 * DefaultStyle.dp)
		height: Math.min(contentColumn.implicitHeight, Math.round(90 * DefaultStyle.dp))
		bottomPadding: Math.round(15 * DefaultStyle.dp)

		background: Rectangle {
			color: DefaultStyle.grey_100
			radius: Math.round(15 * DefaultStyle.dp)
		}

		contentItem: ColumnLayout {
			id: contentColumn
			spacing: Math.round(16 * DefaultStyle.dp)
			
			Item {
				Layout.topMargin: Math.round(7 * DefaultStyle.dp)
			}

			Repeater {
				model: participants
				delegate: RowLayout {
					width: parent.width
					Layout.leftMargin: Math.round(17 * DefaultStyle.dp)
					Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
					spacing: Math.round(10 * DefaultStyle.dp)
					property var participantGui: modelData
					property var participantCore: participantGui.core
					property var contactObj: UtilsCpp.findFriendByAddress(participantCore.sipAddress)
					property var contact: contactObj?.value || null
					Avatar {
						contact: contactObj?.value || null
						displayNameVal: participantCore.displayName
						Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
					}
					ColumnLayout {
						Layout.fillWidth: true
						Layout.preferredHeight: Math.round(56 * DefaultStyle.dp)

						ColumnLayout {
							spacing: Math.round(2 * DefaultStyle.dp)
							Layout.alignment: Qt.AlignVCenter

							Text {
								text:  participantCore.displayName
								font: Typography.p1
								color: DefaultStyle.main2_700
							}

							Text {
								visible: participantCore.isAdmin
								text: qsTr("group_infos_participant_is_admin")
								font: Typography.p3
								color: DefaultStyle.main2_500_main
							}
						}
					}
					
					Item {
						Layout.fillWidth: true
					}
					
					PopupButton {
						id: detailOptions
						popup.x: width
						popup.contentItem: FocusScope {
							implicitHeight: detailsButtons.implicitHeight
							implicitWidth: detailsButtons.implicitWidth
							Keys.onPressed: event => {
												if (event.key == Qt.Key_Left
													|| event.key == Qt.Key_Escape) {
													detailOptions.popup.close()
													event.accepted = true
												}
											}
							ColumnLayout {
								id: detailsButtons
								anchors.fill: parent
								IconLabelButton {
									Layout.fillWidth: true
									//: "Show contact"
									text: contact && contact.core && contact.core.isAppFriend ? qsTr("menu_see_existing_contact") :
																//: "Add to contacts"
																qsTr("menu_add_address_to_contacts")
									icon.source: (contact && contact.core && contact.core.isAppFriend)
										? AppIcons.adressBook
										: AppIcons.plusCircle
									icon.width: Math.round(32 * DefaultStyle.dp)
									icon.height: Math.round(32 * DefaultStyle.dp)
									onClicked: {
										detailOptions.close()
										if (contact && contact.core.isAppFriend)
											UtilsCpp.getMainWindow().displayContactPage(participantCore.sipAddress)
										else
											UtilsCpp.getMainWindow().displayCreateContactPage("",participantCore.sipAddress)
									}
								}
								IconLabelButton {
									visible: mainItem.isGroupEditable()
									Layout.fillWidth: true
									text: participantCore.isAdmin ? qsTr("group_infos_remove_admin_rights") : qsTr("group_infos_give_admin_rights")
									icon.source: AppIcons.profile
									icon.width: Math.round(32 * DefaultStyle.dp)
									icon.height: Math.round(32 * DefaultStyle.dp)
									onClicked: {
										detailOptions.close()
										mainItem.chatCore.lToggleParticipantAdminStatusAtIndex(index)
									}
								}
								IconLabelButton {
									visible: !contact || (contact.core && !contact.core.isAppFriend)
									Layout.fillWidth: true
									text: qsTr("group_infos_copy_sip_address")
									icon.source: AppIcons.copy
									icon.width: Math.round(32 * DefaultStyle.dp)
									icon.height: Math.round(32 * DefaultStyle.dp)
									onClicked: {
										detailOptions.close()
										UtilsCpp.copyToClipboard(participantCore.sipAddress)
									}
								}
								Rectangle {
									visible: mainItem.isGroupEditable()
									color: DefaultStyle.main2_200
									Layout.fillWidth: true
									height: Math.round(1 * DefaultStyle.dp)
									width: parent.width - Math.round(30 * DefaultStyle.dp)
									Layout.leftMargin: Math.round(17 * DefaultStyle.dp)
								}
								IconLabelButton {
									visible: mainItem.isGroupEditable()
									Layout.fillWidth: true
									text: qsTr("group_infos_remove_participant")
									icon.source: AppIcons.trashCan
									icon.width: Math.round(32 * DefaultStyle.dp)
									icon.height: Math.round(32 * DefaultStyle.dp)
									style: ButtonStyle.hoveredBackgroundRed
									onClicked: {
										detailOptions.close()
										UtilsCpp.getMainWindow().showConfirmationLambdaPopup(qsTr("group_infos_remove_participants_toast_title"),
										qsTr("group_infos_remove_participants_toast_message"),
										"",
										function(confirmed) {
											if (confirmed) {
												mainItem.chatCore.lRemoveParticipantAtIndex(index)
											}
										})
									}
								}
							}
						}
					}
					
				}
			}
			
			MediumButton {
				id: manageParticipants
				visible: mainItem.isGroupEditable()
				height: Math.round(40 * DefaultStyle.dp)
				icon.source: AppIcons.plusCircle
				icon.width: Math.round(16 * DefaultStyle.dp)
				icon.height: Math.round(16 * DefaultStyle.dp)
				//: "Gérer des participants"
				text: qsTr("group_infos_manage_participants_title")
				style: ButtonStyle.secondary
				onClicked: mainItem.manageParticipantsRequested()
				Layout.alignment: Qt.AlignHCenter
			}
		}
	}
}
