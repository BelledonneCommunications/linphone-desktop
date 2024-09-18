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
	property ParticipantGui me: call.conference ? call.conference.core.me : null
	property bool isMeAdmin: me ? me.core.isAdmin : false

	property bool hoverEnabled: true
	property bool initialHeadersVisible: true
	property bool displayNameCapitalization: true

	property ConferenceInfoGui confInfoGui

	signal addParticipantRequested()

	currentIndex: -1

	model: ParticipantProxy {
		id: participantModel
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
				_address: modelData.core.sipAddress
			}
			Text {
				text: modelData.core.displayName
				font.pixelSize: 14 * DefaultStyle.dp
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
			Text {
				Layout.alignment: Qt.AlignRight
				visible: modelData.core.isAdmin
				text: qsTr("Admin")
				color: DefaultStyle.main2_400
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignRight
				property bool isMe: modelData.core.isMe
				onIsMeChanged: if (isMe) mainItem.me = modelData
				enabled: mainItem.isMeAdmin && !modelData.core.isMe
				opacity: enabled ? 1.0 : 0
				spacing: 26 * DefaultStyle.dp
				Switch {
					Component.onCompleted: if (modelData.core.isAdmin) toggle()
					//TODO : Utilser checked et onToggled (pas compris)
					onToggled: participantModel.setParticipantAdminStatus(modelData.core, position === 1)
				}
				Button {
					Layout.preferredWidth: 20 * DefaultStyle.dp
					Layout.preferredHeight: 20 * DefaultStyle.dp
					color: DefaultStyle.main2_100
					icon.source: AppIcons.closeX
					icon.width: 14 * DefaultStyle.dp
					icon.height: 14 * DefaultStyle.dp
					onClicked: participantModel.removeParticipant(modelData.core)
				}
			}
		}
	}

	footer: Rectangle {
		color: DefaultStyle.grey_100
		visible: mainItem.isMeAdmin
		height: 74 * DefaultStyle.dp
		width: mainItem.width
		Button {
			anchors.centerIn: parent
			leftPadding: 16 * DefaultStyle.dp
			rightPadding: 16 * DefaultStyle.dp
			topPadding: 10 * DefaultStyle.dp
			bottomPadding: 10 * DefaultStyle.dp
			height: 40 * DefaultStyle.dp
			icon.source: AppIcons.plusCircle
			icon.width: 16 * DefaultStyle.dp
			icon.height: 16 * DefaultStyle.dp
			contentImageColor: DefaultStyle.main1_500_main
			color: DefaultStyle.main1_100
			text: qsTr("Ajouter des participants")
			textColor: DefaultStyle.main1_500_main
			textSize: 15 * DefaultStyle.dp
			textWeight: 600 * DefaultStyle.dp
			onClicked: mainItem.addParticipantRequested()
		}
	}
}
