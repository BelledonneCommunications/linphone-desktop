import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
	id: mainItem
	visible: contentHeight > 0
	clip: true
    rightMargin: Utils.getSizeWithScreenRatio(5)
    spacing: Utils.getSizeWithScreenRatio(8)

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
        height: Utils.getSizeWithScreenRatio(56)
		width: mainItem.width
		
		RowLayout {
			id: participantDelegate
			anchors.fill: parent
			anchors.rightMargin: (scrollbar.width + Utils.getSizeWithScreenRatio(5))
            spacing: Utils.getSizeWithScreenRatio(10)
			z: 1
			Avatar {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
				_address: modelData.core.sipAddress
				secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
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
			RowLayout {
				Layout.alignment: Qt.AlignRight
				property bool isMe: modelData.core.isMe
				onIsMeChanged: if (isMe) mainItem.me = modelData
                spacing: Utils.getSizeWithScreenRatio(26)
				RowLayout {
                	spacing: Utils.getSizeWithScreenRatio(10)
					Text {
						visible: mainItem.isMeAdmin || modelData.core.isAdmin
						Layout.alignment: Qt.AlignRight
						//: "Admin"
						text: qsTr("meeting_participant_is_admin_label")
						color: DefaultStyle.main2_400
						font {
							pixelSize: Utils.getSizeWithScreenRatio(12)
							weight: Utils.getSizeWithScreenRatio(300)
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
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
					color: DefaultStyle.main2_100
    				leftPadding: Utils.getSizeWithScreenRatio(3)
    				rightPadding: Utils.getSizeWithScreenRatio(3)
    				topPadding: Utils.getSizeWithScreenRatio(3)
    				bottomPadding: Utils.getSizeWithScreenRatio(3)
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
