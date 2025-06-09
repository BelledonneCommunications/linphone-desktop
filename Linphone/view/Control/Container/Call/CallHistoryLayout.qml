import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
    spacing: Math.round(30 * DefaultStyle.dp)

	property var callHistoryGui

	property FriendGui contact
	property var conferenceInfo: callHistoryGui?.core.conferenceInfo
	property bool isConference: conferenceInfo != undefined && conferenceInfo != null
	property string contactAddress: specificAddress != "" ? specificAddress : contact && contact.core.defaultAddress || ""
	property var computedContactNameObj: UtilsCpp.getDisplayName(contactAddress)
	property string computedContactName: computedContactNameObj ? computedContactNameObj.value: ""
	property string contactName: contact
		? contact.core.fullName 
		: callHistoryGui
			? callHistoryGui.core.displayName
			: computedContactName

	// Set this property to get the security informations 
	// for a specific address and not for the entire contact
	property string specificAddress: ""

	property alias buttonContent: rightButton.data
	property alias detailContent: detailControl.data

	ColumnLayout {
        spacing: Math.round(13 * DefaultStyle.dp)
		Item {
            Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
			Layout.preferredHeight: detailAvatar.height
			Layout.alignment: Qt.AlignHCenter
			Avatar {
				id: detailAvatar
				anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(100 * DefaultStyle.dp)
                height: Math.round(100 * DefaultStyle.dp)
				contact: mainItem.contact || null
				isConference: !!mainItem.conferenceInfo
				displayNameVal: mainItem.contactName
				secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
			}
			Item {
				id: rightButton
				anchors.right: parent.right
				anchors.verticalCenter: detailAvatar.verticalCenter
                anchors.rightMargin: Math.round(20 * DefaultStyle.dp)
                width: Math.round(30 * DefaultStyle.dp)
                height: Math.round(30 * DefaultStyle.dp)
			}
		}
		ColumnLayout {
			Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
            spacing: Math.round(5 * DefaultStyle.dp)

			ColumnLayout {
                spacing: Math.round(2 * DefaultStyle.dp)
				Text {
					Layout.preferredWidth: implicitWidth
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					text: detailAvatar.displayNameVal
					maximumLineCount: 1
					font {
                        pixelSize: Typography.p1.pixelSize
                        weight: Typography.p1.weight
						capitalization: Font.Capitalize
					}
				}
				Text {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					visible: mainItem.specificAddress != ""
					text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(mainItem.specificAddress) : mainItem.specificAddress
					elide: Text.ElideMiddle
					maximumLineCount: 1
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(300 * DefaultStyle.dp)
					}
				}
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				horizontalAlignment: Text.AlignHCenter
				Layout.fillWidth: true
				visible: mainItem.contact
				text: contact ? contact.core.presenceStatus : ""
				color: contact ? contact.core.presenceColor : 'transparent'
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Math.round(300 * DefaultStyle.dp)
				}
			}
		}
	}
	RowLayout {
		Layout.alignment: Qt.AlignHCenter
        spacing: Math.round(72 * DefaultStyle.dp)
		Layout.fillWidth: true
		Layout.preferredHeight: childrenRect.height
		MediumButton {
			visible: mainItem.isConference && !SettingsCpp.disableMeetingsFeature
			Layout.alignment: Qt.AlignHCenter
            //: "Rejoindre la réunion"
            text: qsTr("meeting_info_join_title")
			style: ButtonStyle.grey
			onClicked: {
				if (mainItem.conferenceInfo) {
					var callsWindow = UtilsCpp.getCallsWindow()
					callsWindow.setupConference(mainItem.conferenceInfo)
					UtilsCpp.smartShowWindow(callsWindow)
				}
			}
		}
		LabelButton {
			visible: !mainItem.isConference
            width: Math.round(56 * DefaultStyle.dp)
            height: Math.round(56 * DefaultStyle.dp)
            button.icon.width: Math.round(24 * DefaultStyle.dp)
            button.icon.height: Math.round(24 * DefaultStyle.dp)
			button.icon.source: AppIcons.phone
            //: "Appel"
            label: qsTr("contact_call_action")
			button.onClicked: {
				if (mainItem.specificAddress === "") mainWindow.startCallWithContact(mainItem.contact, false, mainItem)
				else UtilsCpp.createCall(mainItem.specificAddress)
			}
		}
		LabelButton {
			visible: !mainItem.isConference && !SettingsCpp.disableChatFeature
            width: Math.round(56 * DefaultStyle.dp)
            height: Math.round(56 * DefaultStyle.dp)
            button.icon.width: Math.round(24 * DefaultStyle.dp)
            button.icon.height: Math.round(24 * DefaultStyle.dp)
            button.icon.source: AppIcons.chatTeardropText
            //: "Message"
            label: qsTr("contact_message_action")
			button.onClicked: {
				console.debug("[CallHistoryLayout.qml] Open conversation")
				if (mainItem.specificAddress === "") {
					mainWindow.displayChatPage(mainItem.contact.core.defaultAddress)
				} else mainWindow.displayChatPage(mainItem.specificAddress)
			}
        }
        LabelButton {
            visible: !mainItem.isConference && SettingsCpp.videoEnabled
            width: Math.round(56 * DefaultStyle.dp)
            height: Math.round(56 * DefaultStyle.dp)
            button.icon.width: Math.round(24 * DefaultStyle.dp)
            button.icon.height: Math.round(24 * DefaultStyle.dp)
            button.icon.source: AppIcons.videoCamera
            //: "Appel Video"
            label: qsTr("contact_video_call_action")
            button.onClicked: {
                if (mainItem.specificAddress === "") mainWindow.startCallWithContact(mainItem.contact, true, mainItem)
                else UtilsCpp.createCall(mainItem.specificAddress, {'localVideoEnabled': true})
            }
        }
	}
	ColumnLayout {
		id: detailControl
		Layout.fillWidth: true
		Layout.fillHeight: true

		Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Math.round(30 * DefaultStyle.dp)
	}
}
