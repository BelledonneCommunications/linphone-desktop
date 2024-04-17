import QtQuick
import QtQuick.Layouts as Layout
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0
// =============================================================================

Item {
	id: mainItem
	anchors.fill: parent
	
	property CallGui call
	property bool callTerminatedByUser: false
	readonly property var callState: call && call.core.state || undefined
	property int conferenceLayout: call && call.core.conferenceVideoLayout || 0
	onConferenceLayoutChanged: {
		console.log("CallLayout change : " +conferenceLayout)
		callLayout.sourceComponent = undefined	// unload old view before opening the new view to avoid conflicts in Video UI.
		callLayout.sourceComponent = mainItem.conferenceLayout == LinphoneEnums.ConferenceLayout.ActiveSpeaker
								? activeSpeakerComponent
								: gridComponent
	}
	onCallStateChanged: if (callState === LinphoneEnums.CallState.End) {
							callTerminatedText.visible = true
						}else if( callState === LinphoneEnums.CallState.Error) {
							centerLayout.currentIndex = 1
						}
	
	Text {
		id: callTerminatedText
		visible: false
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 25 * DefaultStyle.dp
		text: mainItem.callTerminatedByUser ? qsTr("Vous avez terminé l'appel") : qsTr("Votre correspondant a terminé l'appel")
		color: DefaultStyle.grey_0
		z: 1
		font {
			pixelSize: 22 * DefaultStyle.dp
			weight: 300 * DefaultStyle.dp
		}
	}
	Layout.StackLayout {
		id: centerLayout
		currentIndex: 0
		anchors.fill: parent
		Loader{
			id: callLayout
			Layout.Layout.fillWidth: true
			Layout.Layout.fillHeight: true
			sourceComponent: gridComponent
		}
		Layout.ColumnLayout {
			id: userNotFoundLayout
			Layout.Layout.preferredWidth: parent.width
			Layout.Layout.preferredHeight: parent.height
			Layout.Layout.alignment: Qt.AlignCenter
			Text {
				text: qsTr(mainItem.call.core.lastErrorMessage)
				Layout.Layout.alignment: Qt.AlignCenter
				color: DefaultStyle.grey_0
				font.pixelSize: 40 * DefaultStyle.dp
			}
		}
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
		GridLayout{
				Layout.Layout.fillWidth: true
				Layout.Layout.fillHeight: true
				call: mainItem.call
		}
	}
}

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

