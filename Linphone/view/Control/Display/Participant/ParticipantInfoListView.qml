import QtQuick
import QtQuick.Layouts

import Linphone
import UtilsCpp

ListView {
	id: mainItem
	clip: true
    spacing: Math.round(5 * DefaultStyle.dp)

	property bool hoverEnabled: true
	property bool displayNameCapitalization: true

	property ChatGui chatGui
	height: contentHeight

	signal participantClicked(string username)

	currentIndex: -1

	model: ParticipantInfoProxy {
		id: participantModel
		chat: mainItem.chatGui
	}

	delegate: Item {
		id: participantDelegate
		height: Math.round(56 * DefaultStyle.dp)
		width: mainItem.width//mainItem.width
		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: Math.round(18 * DefaultStyle.dp)
			anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
			spacing: Math.round(10 * DefaultStyle.dp)
			Avatar {
				Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
				Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
				_address: modelData.core.sipAddress
				shadowEnabled: false
			}
			Text {
				text: modelData.core.displayName
				font.pixelSize: Math.round(14 * DefaultStyle.dp)
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
			Item{Layout.fillWidth: true}
		}
		MouseArea {
			id: mousearea
			anchors.fill: parent
			onClicked: mainItem.participantClicked(modelData.core.username)
			hoverEnabled: true
			cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			Rectangle {
				anchors.fill: parent
				visible: mousearea.containsMouse
				color: DefaultStyle.main2_200
				opacity: 0.5
			}
		}
	}
}
