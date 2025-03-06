import QtQuick
import QtQuick.Layouts

import Linphone
import UtilsCpp 1.0

ListView {
	id: mainItem
	Layout.preferredHeight: contentHeight
	height: contentHeight
	visible: contentHeight > 0
	clip: true
    rightMargin: Math.round(5 * DefaultStyle.dp)
    spacing: Math.round(5 * DefaultStyle.dp)

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
        height: Math.round(56 * DefaultStyle.dp)
		width: mainItem.width
		
		RowLayout {
			id: participantDelegate
			anchors.left: parent.left
            anchors.leftMargin: Math.round(10 * DefaultStyle.dp)
			anchors.right: parent.right
            anchors.rightMargin: Math.round(10 * DefaultStyle.dp)
			anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(10 * DefaultStyle.dp)
			z: 1
			Avatar {
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
				_address: modelData.core.address
				shadowEnabled: false
			}
			Text {
				text: modelData.core.displayName
                font.pixelSize: Math.round(14 * DefaultStyle.dp)
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
		}
	}
}
