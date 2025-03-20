import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls.Basic as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0
// =============================================================================

Item {
	id: mainItem
	property CallGui call
	property ConferenceGui conference: call && call.core.conference
	property bool callTerminatedByUser: false
	property bool callStarted: call? call.core.isStarted : false
	readonly property var callState: call?.core.state
	property int conferenceLayout: call ? call.core.conferenceVideoLayout : LinphoneEnums.ConferenceLayout.ActiveSpeaker
	property int participantDeviceCount: conference ? conference.core.participantDeviceCount : -1
	onParticipantDeviceCountChanged: {
		setConferenceLayout()
	}
	Component.onCompleted: setConferenceLayout()
	onConferenceLayoutChanged: {
		console.log("CallLayout change : " +conferenceLayout)
		setConferenceLayout()
	}

	Connections {
		target: mainItem.conference? mainItem.conference.core : null
		function onIsScreenSharingEnabledChanged() {
			setConferenceLayout()
		}
	}

	function setConferenceLayout() {
		callLayout.sourceComponent = undefined	// unload old view before opening the new view to avoid conflicts in Video UI.
		callLayout.sourceComponent = conference
			? conference.core.isScreenSharingEnabled || (mainItem.conferenceLayout == LinphoneEnums.ConferenceLayout.ActiveSpeaker && participantDeviceCount > 1)
				? activeSpeakerComponent
				: participantDeviceCount <= 1
					? waitingForOthersComponent
					: gridComponent
			: activeSpeakerComponent
	}

	Text {
		id: callTerminatedText
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
        anchors.topMargin: Math.round(25 * DefaultStyle.dp)
		z: 1
		visible: mainItem.callState === LinphoneEnums.CallState.End || mainItem.callState === LinphoneEnums.CallState.Error || mainItem.callState === LinphoneEnums.CallState.Released
		text: mainItem.conference
                //: "Vous avez quitté la conférence"
                ? qsTr("meeting_event_conference_destroyed")
                : mainItem.callTerminatedByUser
                    //: "Vous avez terminé l'appel"
                    ? qsTr("call_ended_by_user")
                    : mainItem.callStarted
                        //: "Votre correspondant a terminé l'appel"
                        ? qsTr("call_ended_by_remote")
						: call && call.core.lastErrorMessage || ""
		color: DefaultStyle.grey_0
		font {
            pixelSize: Math.round(22 * DefaultStyle.dp)
            weight: Math.round(300 * DefaultStyle.dp)
		}
	}
	
	Loader{
		id: callLayout
		anchors.fill: parent
		sourceComponent: mainItem.participantDeviceCount === 0
			? waitingForOthersComponent
			: activeSpeakerComponent
	}

	Component {
		id: waitingForOthersComponent
		Rectangle {
			color: DefaultStyle.grey_600
            radius: Math.round(15 * DefaultStyle.dp)
			ColumnLayout {
				anchors.centerIn: parent
                spacing: Math.round(22 * DefaultStyle.dp)
				width: waitText.implicitWidth
				Text {
					id: waitText
                    //: "En attente d'autres participants…"
                    text: qsTr("conference_call_empty")
                    Layout.preferredHeight: Math.round(67 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					color: DefaultStyle.grey_0
					font {
                        pixelSize: Math.round(30 * DefaultStyle.dp)
                        weight: Math.round(300 * DefaultStyle.dp)
					}
				}
				Item {
					Layout.fillWidth: true
					BigButton {
						color: pressed ? DefaultStyle.main2_200 : "transparent"
						borderColor: DefaultStyle.main2_400
						icon.source: AppIcons.shareNetwork
						contentImageColor: DefaultStyle.main2_400
                        //: "Partager le lien"
                        text: qsTr("conference_share_link_title")
						anchors.centerIn: parent
						textColor: DefaultStyle.main2_400
						onClicked: {
							if (mainItem.conference) {
								UtilsCpp.copyToClipboard(mainItem.call.core.remoteAddress)
                                showInformationPopup(qsTr("copied"),
                                                     //: Le lien de la réunion a été copié dans le presse-papier
                                                     qsTr("information_popup_meeting_address_copied_to_clipboard"), true)
							}
						}
					}
				}
			}
		}
	}
	
	Component{
		id: activeSpeakerComponent
		ActiveSpeakerLayout{
			Layout.fillWidth: true
			Layout.fillHeight: true
			call: mainItem.call
		}
	}
	Component{
		id: gridComponent
		CallGridLayout{
			Layout.fillWidth: true
			Layout.fillHeight: true
			call: mainItem.call
		}
	}
}
