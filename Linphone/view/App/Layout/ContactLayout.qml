import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

ColumnLayout {
	id: mainItem
	spacing: 30 * DefaultStyle.dp

	property var contact
	property string contactAddress: contact && contact.core.defaultAddress || ""
	property string contactName: contact && contact.core.displayName || ""

	property bool addressVisible: true

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
		Layout.preferredWidth: mainItem.implicitWidth
		Layout.preferredHeight: detailAvatar.height
		// Layout.fillWidth: true
		Layout.alignment: Qt.AlignHCenter
		Avatar {
			// TODO : find friend and pass contact argument
			id: detailAvatar
			anchors.horizontalCenter: parent.horizontalCenter 
			width: 100 * DefaultStyle.dp
			height: 100 * DefaultStyle.dp
			contact: mainItem.contact || null
			address: !contact && mainItem.contactAddress || mainItem.contactName
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
		// Layout.fillWidth: true
		Text {
			Layout.alignment: Qt.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
			text: mainItem.contactName
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
				capitalization: Font.Capitalize
			}
		}
		Text {
			id: contactAddress
			property var mode : contact ? contact.core.consolidatedPresence : -1
			Layout.alignment: Qt.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
			visible: mainItem.addressVisible
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
	Item {
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: mainItem.implicitWidth
		Layout.preferredHeight: childrenRect.height
		LabelButton {
			anchors.left: parent.left
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.phone
			label: qsTr("Appel")
			property var callObj
			button.onClicked: {
 	  			var addr = UtilsCpp.generateLinphoneSipAddress(mainItem.contact.core.defaultAddress)
				callObj = UtilsCpp.createCall(addr)
			}
		}
		LabelButton {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.chatTeardropText
			label: qsTr("Message")
			button.onClicked: console.debug("[CallPage.qml] TODO : open conversation")
		}
		LabelButton {
			id: videoCall
			anchors.right: parent.right
			width: 56 * DefaultStyle.dp
			height: 56 * DefaultStyle.dp
			button.icon.width: 24 * DefaultStyle.dp
			button.icon.height: 24 * DefaultStyle.dp
			button.icon.source: AppIcons.videoCamera
			label: qsTr("Appel Video")
			property var callObj
			button.onClicked: {
				var addr = UtilsCpp.generateLinphoneSipAddress(mainItem.contact.core.defaultAddress)
	  			callObj = UtilsCpp.createCall(addr)
  				console.log("[CallPage.qml] TODO : enable video")
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