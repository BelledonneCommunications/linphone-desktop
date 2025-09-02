import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ListView {
	id: mainItem
	visible: contentHeight > 0
	clip: true
    rightMargin: Math.round(5 * DefaultStyle.dp)
    spacing: Math.round(8 * DefaultStyle.dp)

	property string searchBarText

	property CallGui call
	property ParticipantGui me: call.conference ? call.conference.core.me : null
	property bool isMeAdmin: me ? me.core.isAdmin : false

	property bool hoverEnabled: true
	property bool initialHeadersVisible: true
	property bool displayNameCapitalization: true

	property ConferenceInfoGui confInfoGui

	signal addParticipantRequested()

	Control.ScrollBar.vertical: ScrollBar {
		id: scrollbar
		anchors.top: mainItem.top
		anchors.bottom: mainItem.bottom
		anchors.right: mainItem.right
		visible: mainItem.height < mainItem.contentHeight
	}

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
			anchors.fill: parent
			anchors.rightMargin: (scrollbar.width + 5 * DefaultStyle.dp)
            spacing: Math.round(10 * DefaultStyle.dp)
			z: 1
			Avatar {
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
				_address: modelData.core.sipAddress
				secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
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
			RowLayout {
				Layout.alignment: Qt.AlignRight
				property bool isMe: modelData.core.isMe
				onIsMeChanged: if (isMe) mainItem.me = modelData
                spacing: Math.round(26 * DefaultStyle.dp)
				RowLayout {
                	spacing: Math.round(10 * DefaultStyle.dp)
					Text {
						visible: mainItem.isMeAdmin || modelData.core.isAdmin
						Layout.alignment: Qt.AlignRight
						//: "Admin"
						text: qsTr("meeting_participant_is_admin_label")
						color: DefaultStyle.main2_400
						font {
							pixelSize: Math.round(12 * DefaultStyle.dp)
							weight: Math.round(300 * DefaultStyle.dp)
						}
					}
					Switch {
						opacity: mainItem.isMeAdmin && !modelData.core.isMe ? 1 : 0
						Component.onCompleted: if (modelData.core.isAdmin) toggle()
						//TODO : Utilser checked et onToggled (pas compris)
						onToggled: participantModel.setParticipantAdminStatus(modelData.core, position === 1)
					}
				}
				SmallButton {
					opacity: mainItem.isMeAdmin && !modelData.core.isMe ? 1 : 0
                    Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
					color: DefaultStyle.main2_100
    				leftPadding: Math.round(3 * DefaultStyle.dp)
    				rightPadding: Math.round(3 * DefaultStyle.dp)
    				topPadding: Math.round(3 * DefaultStyle.dp)
    				bottomPadding: Math.round(3 * DefaultStyle.dp)
					style: ButtonStyle.hoveredBackground
					icon.source: AppIcons.closeX
					onClicked: participantModel.removeParticipant(modelData.core)
				}
			}
		}
	}

	footer: Rectangle {
		color: "transparent"
		width: mainItem.width
		height: childrenRect.height
		visible: mainItem.isMeAdmin
		MediumButton {
			anchors.centerIn: parent
			icon.source: AppIcons.plusCircle
			//: "Ajouter des participants"
			text: qsTr("meeting_add_participants_title")
			style: ButtonStyle.tertiary
			onClicked: mainItem.addParticipantRequested()
		}
	}
}
