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
	spacing: 30 * DefaultStyle.dp

	property FriendGui contact
	property ConferenceInfoGui conferenceInfo
	property bool isConference: conferenceInfo != undefined && conferenceInfo != null
	property string contactAddress: specificAddress != "" ? specificAddress : contact && contact.core.defaultAddress || ""
	property var computedContactNameObj: UtilsCpp.getDisplayName(contactAddress)
	property string computedContactName: computedContactNameObj ? computedContactNameObj.value: ""
	property string contactName: contact
		? contact.core.fullName 
		: conferenceInfo
			? conferenceInfo.core.subject
			: computedContactName

	// Set this property to get the security informations 
	// for a specific address and not for the entire contact
	property string specificAddress: ""

	property alias buttonContent: rightButton.data
	property alias detailContent: detailControl.data

	component LabelButton: ColumnLayout {
		id: labelButton
		// property alias image: buttonImg
		property alias button: button
		property string label
		spacing: 8 * DefaultStyle.dp
		Button {
			id: button
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 56 * DefaultStyle.dp
			Layout.preferredHeight: 56 * DefaultStyle.dp
			topPadding: 16 * DefaultStyle.dp
			bottomPadding: 16 * DefaultStyle.dp
			leftPadding: 16 * DefaultStyle.dp
			rightPadding: 16 * DefaultStyle.dp
			contentImageColor: DefaultStyle.main2_600
			radius: 40 * DefaultStyle.dp
			style: ButtonStyle.grey
		}
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: labelButton.label
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
		}
	}

	ColumnLayout {
		spacing: 13 * DefaultStyle.dp
		Item {
			Layout.preferredWidth: 360 * DefaultStyle.dp
			Layout.preferredHeight: detailAvatar.height
			Layout.alignment: Qt.AlignHCenter
			Avatar {
				id: detailAvatar
				anchors.horizontalCenter: parent.horizontalCenter
				width: 100 * DefaultStyle.dp
				height: 100 * DefaultStyle.dp
				contact: mainItem.contact || null
				isConference: !!mainItem.conferenceInfo
				_address: mainItem.conferenceInfo
					? mainItem.conferenceInfo.core.subject
					: mainItem.contactAddress || mainItem.contactName
				secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
			}
			Item {
				id: rightButton
				anchors.right: parent.right
				anchors.verticalCenter: detailAvatar.verticalCenter
				anchors.rightMargin: 20 * DefaultStyle.dp
				width: 30 * DefaultStyle.dp
				height: 30 * DefaultStyle.dp
			}
		}
		ColumnLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 360 * DefaultStyle.dp
			spacing: 5 * DefaultStyle.dp

			ColumnLayout {
				spacing: 2 * DefaultStyle.dp
				Text {
					Layout.preferredWidth: implicitWidth
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					text: detailAvatar.displayNameVal
					maximumLineCount: 1
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
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
						pixelSize: 12 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
			}
			Text {
				property var mode : contact ? contact.core.consolidatedPresence : -1
				Layout.alignment: Qt.AlignHCenter
				horizontalAlignment: Text.AlignHCenter
				Layout.fillWidth: true
				visible: mainItem.contact
				text: mode === LinphoneEnums.ConsolidatedPresence.Online
					? qsTr("En ligne")
					: mode === LinphoneEnums.ConsolidatedPresence.Busy
						? qsTr("Occupé")
						: mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
							? qsTr("Ne pas déranger")
							: qsTr("Hors ligne")
				color: mode === LinphoneEnums.ConsolidatedPresence.Online
					? DefaultStyle.success_500main
					: mode === LinphoneEnums.ConsolidatedPresence.Busy
						? DefaultStyle.warning_600
						: mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
							? DefaultStyle.danger_500main
							: DefaultStyle.main2_500main
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
				}
			}
		}
	}
	RowLayout {
		Layout.alignment: Qt.AlignHCenter
		spacing: 72 * DefaultStyle.dp
		Layout.fillWidth: true
		Layout.preferredHeight: childrenRect.height
		MediumButton {
			visible: mainItem.isConference && !SettingsCpp.disableMeetingsFeature
			Layout.alignment: Qt.AlignHCenter
			text: qsTr("Rejoindre la réunion")
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
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.phone
			label: qsTr("Appel")
			button.onClicked: {
				if (mainItem.specificAddress === "") mainWindow.startCallWithContact(mainItem.contact, false, mainItem)
				else UtilsCpp.createCall(mainItem.specificAddress)
			}
		}
		LabelButton {
			visible: !mainItem.isConference && !SettingsCpp.disableChatFeature
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.chatTeardropText
			label: qsTr("Message")
			button.onClicked: console.debug("[ContactLayout.qml] TODO : open conversation")
		}
		LabelButton {
			visible: !mainItem.isConference
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.videoCamera
			label: qsTr("Appel Video")
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
		Layout.topMargin: 30 * DefaultStyle.dp
	}
}
