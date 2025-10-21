import QtQuick
import QtQuick.Layouts

import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
	id: mainItem
	Layout.preferredHeight: contentHeight
	height: contentHeight
	visible: contentHeight > 0
	clip: true
    rightMargin: Utils.getSizeWithScreenRatio(5)
    spacing: Utils.getSizeWithScreenRatio(5)

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
        height: Utils.getSizeWithScreenRatio(56)
		width: mainItem.width
		
		RowLayout {
			id: participantDelegate
			anchors.left: parent.left
            anchors.leftMargin: Utils.getSizeWithScreenRatio(10)
			anchors.right: parent.right
            anchors.rightMargin: Utils.getSizeWithScreenRatio(10)
			anchors.verticalCenter: parent.verticalCenter
            spacing: Utils.getSizeWithScreenRatio(10)
			z: 1
			Avatar {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
				_address: modelData.core.address
				secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
				shadowEnabled: false
			}
			Text {
				text: modelData.core.displayName
                font.pixelSize: Utils.getSizeWithScreenRatio(14)
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
		}
	}
}
