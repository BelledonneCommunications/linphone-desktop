import QtQuick
import QtQuick.Layouts as Layout
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
	property bool callStarted: call?.core.isStarted
	readonly property var callState: call? call.core.state : undefined
	property int conferenceLayout: call ? call.core.conferenceVideoLayout : LinphoneEnums.ConferenceLayout.ActiveSpeaker
	// property int participantDeviceCount: conference ? conference.core.participantDeviceCount : -1
	// onParticipantDeviceCountChanged: {
		// setConferenceLayout()
	// }
	Component.onCompleted: setConferenceLayout()
	onConferenceLayoutChanged: {
		console.log("CallLayout change : " +conferenceLayout)
		setConferenceLayout()
	}

	function setConferenceLayout() {
		callLayout.sourceComponent = undefined	// unload old view before opening the new view to avoid conflicts in Video UI.
		callLayout.sourceComponent = !conference || mainItem.conferenceLayout == LinphoneEnums.ConferenceLayout.ActiveSpeaker
			? activeSpeakerComponent
			: gridComponent
	}

	Text {
		id: callTerminatedText
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 25 * DefaultStyle.dp
		z: 1
		visible: mainItem.callState === LinphoneEnums.CallState.End || mainItem.callState === LinphoneEnums.CallState.Error || mainItem.callState === LinphoneEnums.CallState.Released
		text: mainItem.conference
				? qsTr("Vous avez quitté la conférence")
				: mainItem.callTerminatedByUser
					? qsTr("Vous avez terminé l'appel") 
					: mainItem.callStarted 
						? qsTr("Votre correspondant a terminé l'appel")
						: call && call.core.lastErrorMessage || ""
		color: DefaultStyle.grey_0
		font {
			pixelSize: 22 * DefaultStyle.dp
			weight: 300 * DefaultStyle.dp
		}
	}
	
	Loader{
		id: callLayout
		anchors.fill: parent
		sourceComponent: mainItem.participantDeviceCount === 0
			? waitingForOthersComponent
			: activeSpeakerComponent
	}
	
	Component{
		id: activeSpeakerComponent
		ActiveSpeakerLayout{
			Layout.Layout.fillWidth: true
			Layout.Layout.fillHeight: true
			call: mainItem.call
		}
	}
	Component{
		id: gridComponent
		CallGridLayout{
			Layout.Layout.fillWidth: true
			Layout.Layout.fillHeight: true
			call: mainItem.call
		}
	}
}
// TODO : waitingForParticipant
		// ColumnLayout {
		// 	id: waitingForParticipant
		// 	Text {
		// 		text: qsTr("Waiting for other participants...")
		// 		color: DefaultStyle.frey_0
		// 		font {
		// 			pixelSize: 30 * DefaultStyle.dp
		// 			weight: 300 * DefaultStyle.dp
		// 		}
		// 	}
		// 	Button {
		// 		inversedColors: true
		// 		text: qsTr("Share invitation")
		// 		icon.source: AppIcons.shareNetwork
		// 		color: DefaultStyle.main2_400
		// 		Layout.preferredWidth: 206 * DefaultStyle.dp
		// 		Layout.preferredHeight: 47 * DefaultStyle.dp
		// 	}
		// }

