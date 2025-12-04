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
    property var title: String
    property var participants
    property var chatCore
    signal manageParticipantsRequested()
    
    property bool isGroupEditable: chatCore && chatCore.meAdmin && !chatCore.isReadOnly

	RowLayout {
		Text {
			font: Typography.h4
			color: DefaultStyle.main2_600
			text: title
			Layout.topMargin: Utils.getSizeWithScreenRatio(5)
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
		Layout.topMargin: Utils.getSizeWithScreenRatio(9)
		height: Math.min(contentColumn.implicitHeight,Utils.getSizeWithScreenRatio(90))
		bottomPadding: Utils.getSizeWithScreenRatio(15)

		background: Rectangle {
			color: DefaultStyle.grey_100
			radius: Utils.getSizeWithScreenRatio(15)
		}

		contentItem: ColumnLayout {
			id: contentColumn
			spacing: Utils.getSizeWithScreenRatio(16)
			
			Item {
				Layout.topMargin: Utils.getSizeWithScreenRatio(7)
			}

			Repeater {
				model: participants
				delegate: RowLayout {
					width: parent.width
					Layout.leftMargin: Utils.getSizeWithScreenRatio(17)
					Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
					spacing: Utils.getSizeWithScreenRatio(10)
					property var participantGui: modelData
					property var participantCore: participantGui.core
					property var contactObj: UtilsCpp.findFriendByAddress(participantCore.sipAddress)
					property var contact: contactObj?.value || null
					Avatar {
						contact: contactObj?.value || null
						displayNameVal: participantCore.displayName
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
					}
					ColumnLayout {
						Layout.fillWidth: true
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(56)

						ColumnLayout {
							spacing: Utils.getSizeWithScreenRatio(2)
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
									icon.width: Utils.getSizeWithScreenRatio(32)
									icon.height: Utils.getSizeWithScreenRatio(32)
									onClicked: {
										detailOptions.close()
										if (contact && contact.core.isAppFriend)
											UtilsCpp.getMainWindow().displayContactPage(participantCore.sipAddress)
										else
											UtilsCpp.getMainWindow().displayCreateContactPage("",participantCore.sipAddress)
									}
								}
								IconLabelButton {
									visible: mainItem.isGroupEditable
									Layout.fillWidth: true
									text: participantCore.isAdmin ? qsTr("group_infos_remove_admin_rights") : qsTr("group_infos_give_admin_rights")
									icon.source: AppIcons.profile
									icon.width: Utils.getSizeWithScreenRatio(32)
									icon.height: Utils.getSizeWithScreenRatio(32)
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
									icon.width: Utils.getSizeWithScreenRatio(32)
									icon.height: Utils.getSizeWithScreenRatio(32)
									onClicked: {
										detailOptions.close()
										UtilsCpp.copyToClipboard(participantCore.sipAddress)
									}
								}
								Rectangle {
									visible: mainItem.isGroupEditable
									color: DefaultStyle.main2_200
									Layout.fillWidth: true
									height: Utils.getSizeWithScreenRatio(1)
									width: parent.width - Utils.getSizeWithScreenRatio(30)
									Layout.leftMargin: Utils.getSizeWithScreenRatio(17)
								}
								IconLabelButton {
									visible: mainItem.isGroupEditable
									Layout.fillWidth: true
									text: qsTr("group_infos_remove_participant")
									icon.source: AppIcons.trashCan
									icon.width: Utils.getSizeWithScreenRatio(32)
									icon.height: Utils.getSizeWithScreenRatio(32)
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
				visible: mainItem.isGroupEditable
				height: Utils.getSizeWithScreenRatio(40)
				icon.source: AppIcons.plusCircle
				icon.width: Utils.getSizeWithScreenRatio(16)
				icon.height: Utils.getSizeWithScreenRatio(16)
				//: "Gérer des participants"
				text: qsTr("group_infos_manage_participants_title")
				style: ButtonStyle.secondary
				onClicked: mainItem.manageParticipantsRequested()
				Layout.alignment: Qt.AlignHCenter
			}
		}
	}
}
