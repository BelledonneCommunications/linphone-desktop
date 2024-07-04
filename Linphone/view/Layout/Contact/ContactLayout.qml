import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp
import SettingsCpp

ColumnLayout {
	id: mainItem
	spacing: 30 * DefaultStyle.dp

	property FriendGui contact
	property ConferenceInfoGui conferenceInfo
	property bool isConference: conferenceInfo != undefined && conferenceInfo != null
	property string contactAddress: contact && contact.core.defaultAddress || ""
	property string contactName: contact && contact.core.displayName || ""

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
			background: Rectangle {
				anchors.fill: parent
				radius: 40 * DefaultStyle.dp
				color: DefaultStyle.main2_200
			}
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

	Item {
		Layout.preferredWidth: 360 * DefaultStyle.dp
		Layout.preferredHeight: detailAvatar.height
		// Layout.fillWidth: true
		Layout.alignment: Qt.AlignHCenter
		Avatar {
			id: detailAvatar
			anchors.horizontalCenter: parent.horizontalCenter 
			width: 100 * DefaultStyle.dp
			height: 100 * DefaultStyle.dp
			contact: mainItem.contact || null
			address: mainItem.conferenceInfo 
				? mainItem.conferenceInfo.core.subject 
				: mainItem.contactAddress || mainItem.contactName
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
		Text {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WrapAnywhere
			elide: Text.ElideRight
			text: mainItem.contactName
			maximumLineCount: 1
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
				capitalization: Font.Capitalize
			}
		}
		Text {
			property var mode : contact ? contact.core.consolidatedPresence : -1
			Layout.alignment: Qt.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
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
		Text {
			// connection status
		}
	}
	RowLayout {
		Layout.alignment: Qt.AlignHCenter
		spacing: 72 * DefaultStyle.dp
		Layout.fillWidth: true
		Layout.preferredHeight: childrenRect.height
		Button {
			visible: mainItem.isConference && !SettingsCpp.disableMeetingsFeature
			Layout.alignment: Qt.AlignHCenter
			text: qsTr("Rejoindre la réunion")
			color: DefaultStyle.main2_200
			pressedColor: DefaultStyle.main2_400
			textColor: DefaultStyle.main2_600
			onClicked: {
				if (mainItem.conferenceInfo) {
					var callsWindow = UtilsCpp.getCallsWindow()
					callsWindow.setupConference(mainItem.conferenceInfo)
					callsWindow.show()
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
				mainWindow.startCallWithContact(contact, false, mainItem)
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
				mainWindow.startCallWithContact(contact, true, mainItem)
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
