import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
    spacing: Utils.getSizeWithScreenRatio(30)

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
        spacing: Utils.getSizeWithScreenRatio(13)
		Item {
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(360)
			Layout.preferredHeight: detailAvatar.height
			Layout.alignment: Qt.AlignHCenter
			Avatar {
				id: detailAvatar
				anchors.horizontalCenter: parent.horizontalCenter
                width: Utils.getSizeWithScreenRatio(100)
                height: Utils.getSizeWithScreenRatio(100)
				contact: mainItem.contact || null
				isConference: !!mainItem.conferenceInfo
				displayNameVal: mainItem.contactName
				secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
			}
			Item {
				id: rightButton
				anchors.right: parent.right
				anchors.verticalCenter: detailAvatar.verticalCenter
                anchors.rightMargin: Utils.getSizeWithScreenRatio(20)
                width: Utils.getSizeWithScreenRatio(30)
                height: Utils.getSizeWithScreenRatio(30)
			}
		}
		ColumnLayout {
			Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(360)
            spacing: Utils.getSizeWithScreenRatio(5)

			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(2)
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
					}
				}
				Text {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					visible: mainItem.specificAddress != ""
					text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(mainItem.specificAddress) : mainItem.specificAddress
					elide: Text.ElideMiddle
					maximumLineCount: 1
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(300)
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
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Utils.getSizeWithScreenRatio(300)
				}
			}
		}
	}
	MediumButton {
		visible: mainItem.isConference && !SettingsCpp.disableMeetingsFeature
		Layout.alignment: Qt.AlignHCenter
		//: "Rejoindre la réunion"
		text: qsTr("meeting_info_join_title")
		style: ButtonStyle.grey
		onClicked: {
			if (mainItem.conferenceInfo) {
				var callsWindow = UtilsCpp.getOrCreateCallsWindow()
				callsWindow.setupConference(mainItem.conferenceInfo)
				UtilsCpp.smartShowWindow(callsWindow)
			}
		}
	}
	RowLayout {
		Layout.alignment: Qt.AlignHCenter
        spacing: Utils.getSizeWithScreenRatio(72)
		Layout.fillWidth: true
		Layout.preferredHeight: childrenRect.height
		visible: !mainItem.isConference
		LabelButton {
            width: Utils.getSizeWithScreenRatio(56)
            height: Utils.getSizeWithScreenRatio(56)
            button.icon.width: Utils.getSizeWithScreenRatio(24)
            button.icon.height: Utils.getSizeWithScreenRatio(24)
			button.icon.source: AppIcons.phone
            //: "Appel"
            label: qsTr("contact_call_action")
			button.onClicked: {
				if (mainItem.specificAddress === "") mainWindow.startCallWithContact(mainItem.contact, false, mainItem)
				else UtilsCpp.createCall(mainItem.specificAddress)
			}
		}
		LabelButton {
			visible: !SettingsCpp.disableChatFeature
            width: Utils.getSizeWithScreenRatio(56)
            height: Utils.getSizeWithScreenRatio(56)
            button.icon.width: Utils.getSizeWithScreenRatio(24)
            button.icon.height: Utils.getSizeWithScreenRatio(24)
            button.icon.source: AppIcons.chatTeardropText
            //: "Message"
            label: qsTr("contact_message_action")
			button.onClicked: {
				console.debug("[CallHistoryLayout.qml] Open conversation")
				if (mainItem.specificAddress === "") {
					mainWindow.sendMessageToContact(mainItem.contact)
				}
				else {
					console.log("specific address", mainItem.specificAddress)
					mainWindow.displayChatPage(mainItem.specificAddress)
				}
			}
        }
        LabelButton {
            visible: SettingsCpp.videoEnabled
            width: Utils.getSizeWithScreenRatio(56)
            height: Utils.getSizeWithScreenRatio(56)
            button.icon.width: Utils.getSizeWithScreenRatio(24)
            button.icon.height: Utils.getSizeWithScreenRatio(24)
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
        Layout.topMargin: Utils.getSizeWithScreenRatio(30)
	}
}
