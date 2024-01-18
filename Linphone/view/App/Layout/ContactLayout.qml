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
		property alias image: buttonImg
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
			contentItem: Image {
				id: buttonImg
				source: labelButton.source
				width: 24 * DefaultStyle.dp
				height: 24 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				sourceSize.width: 24 * DefaultStyle.dp
				sourceSize.height: 24 * DefaultStyle.dp
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
			text: mainItem.contactName
			horizontalAlignment: Text.AlignHCenter
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
		}
		Text {
			id: contactAddress
			visible: mainItem.addressVisible
			text: mainItem.contactAddress
			horizontalAlignment: Text.AlignHCenter
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
		// spacing: 10 * DefaultStyle.dp
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: mainItem.implicitWidth
		Layout.preferredHeight: childrenRect.height
		// Layout.fillHeight: true
		LabelButton {
			anchors.left: parent.left
			// width: 24 * DefaultStyle.dp//image.width
			// height: image.height
			image.source: AppIcons.phone
			label: qsTr("Appel")
			button.onClicked: {
				var addr = mainItem.contact.core.defaultAddress
				var addressEnd = "@sip.linphone.org"
				if (!addr.endsWith(addressEnd)) addr += addressEnd
				UtilsCpp.createCall(addr)
			}
		}
		LabelButton {
			anchors.horizontalCenter: parent.horizontalCenter
			// Layout.preferredWidth: image.width
			// Layout.preferredHeight: image.height
			image.source: AppIcons.chatTeardropText
			label: qsTr("Message")
			button.onClicked: console.debug("[CallPage.qml] TODO : open conversation")
		}
		LabelButton {
			id: videoCall
			anchors.right: parent.right
			// Layout.preferredWidth: image.width
			// Layout.preferredHeight: image.height
			image.source: AppIcons.videoCamera
			label: qsTr("Appel Video")
			button.onClicked: {
				var addr = mainItem.contact.core.defaultAddress
				var addressEnd = "@sip.linphone.org"
				if(!addr.endsWith(addressEnd)) addr += addressEnd
				UtilsCpp.createCall(addr)
				console.log("[CallPage.qml] TODO : enable video")
			}
		}
		// Item {Layout.fillWidth: true}

	}
	ColumnLayout {
		id: detailControl
		Layout.fillWidth: true
		Layout.fillHeight: true

		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: 30 * DefaultStyle.dp
	}
}