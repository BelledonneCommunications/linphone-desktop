import QtQuick
import QtQuick.Layouts

import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
			Text {
				Layout.alignment: Qt.AlignRight
				visible: modelData.core.isAdmin
                //: "Admin"
                text: qsTr("meeting_participant_is_admin_label")
				color: DefaultStyle.main2_400
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Math.round(300 * DefaultStyle.dp)
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignRight
				property bool isMe: modelData.core.isMe
				onIsMeChanged: if (isMe) mainItem.me = modelData
				enabled: mainItem.isMeAdmin && !modelData.core.isMe
				opacity: enabled ? 1.0 : 0
                spacing: Math.round(26 * DefaultStyle.dp)
				Switch {
					Component.onCompleted: if (modelData.core.isAdmin) toggle()
					//TODO : Utilser checked et onToggled (pas compris)
					onToggled: participantModel.setParticipantAdminStatus(modelData.core, position === 1)
				}
				SmallButton {
                    Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
					color: DefaultStyle.main2_100
					style: ButtonStyle.hoveredBackground
					icon.source: AppIcons.closeX
					onClicked: participantModel.removeParticipant(modelData.core)
				}
			}
		}
	}

	footer: Rectangle {
		color: DefaultStyle.grey_100
		visible: mainItem.isMeAdmin
        height: Math.round(74 * DefaultStyle.dp)
		width: mainItem.width
		MediumButton {
			anchors.centerIn: parent
            height: Math.round(40 * DefaultStyle.dp)
			icon.source: AppIcons.plusCircle
            icon.width: Math.round(16 * DefaultStyle.dp)
            icon.height: Math.round(16 * DefaultStyle.dp)
            //: "Ajouter des participants"
            text: qsTr("meeting_add_participants_title")
			style: ButtonStyle.secondary
			onClicked: mainItem.addParticipantRequested()
		}
	}
}
