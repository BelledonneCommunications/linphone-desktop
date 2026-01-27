import QtQuick
import QtQuick.Layouts

import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
	id: mainItem
	clip: true
    spacing: Utils.getSizeWithScreenRatio(5)

	property bool hoverEnabled: true
	property bool displayNameCapitalization: true

	property ChatGui chatGui
	height: contentHeight
	property int delegateHoverRectangleRadius: 0

	signal participantClicked(string username)

	currentIndex: -1

	model: ParticipantInfoProxy {
		id: participantModel
		chat: mainItem.chatGui
	}

	delegate: Item {
		id: participantDelegate
		height: Utils.getSizeWithScreenRatio(56)
		width: mainItem.width//mainItem.width
		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: Utils.getSizeWithScreenRatio(18)
			anchors.rightMargin: Utils.getSizeWithScreenRatio(18)
			spacing: Utils.getSizeWithScreenRatio(10)
			Avatar {
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
				_address: modelData.core.sipAddress
				shadowEnabled: false
			}
			Text {
				text: modelData.core.displayName
				font.pixelSize: Utils.getSizeWithScreenRatio(14)
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
				radius: mainItem.delegateHoverRectangleRadius
			}
		}
	}
}
