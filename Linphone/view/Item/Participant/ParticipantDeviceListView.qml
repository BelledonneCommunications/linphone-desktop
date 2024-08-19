import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone
import UtilsCpp 1.0

ListView {
	id: mainItem
	Layout.preferredHeight: contentHeight
	height: contentHeight
	visible: contentHeight > 0
	clip: true
	rightMargin: 5 * DefaultStyle.dp
	spacing: 5 * DefaultStyle.dp

	property string searchBarText

	property CallGui call

	property bool hoverEnabled: true
	property bool initialHeadersVisible: true
	property bool displayNameCapitalization: true

	property ConferenceInfoGui confInfoGui

	currentIndex: -1

	model: ParticipantDeviceProxy {
		id: participantDevices
		currentCall: mainItem.call
	}

	delegate: Item {
		height: 56 * DefaultStyle.dp
		width: mainItem.width
		
		RowLayout {
			id: participantDelegate
			anchors.left: parent.left
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.rightMargin: 10 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			spacing: 10 * DefaultStyle.dp
			z: 1
			Avatar {
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				_address: modelData.core.address
			}
			Text {
				text: modelData.core.displayName
				font.pixelSize: 14 * DefaultStyle.dp
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
		}
	}
}
