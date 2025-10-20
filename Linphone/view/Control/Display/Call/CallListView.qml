import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Linphone
import QtQml
import SettingsCpp
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ListView {
	id: mainItem
	model: CallProxy {
		id: callProxy
		sourceModel: AppCpp.calls
    }
	implicitHeight: contentHeight
    spacing: Math.round(15 * DefaultStyle.dp)
	clip: true
	onCountChanged: forceLayout()

	signal transferCallToAnotherRequested(CallGui dest)

	property bool isTransferList: false
    property string currentRemoteAddress: AppCpp.calls.currentCall ? AppCpp.calls.currentCall.core.remoteAddress : ""

	delegate: RowLayout {
		id: callInformationItem
        spacing: Math.round(8 * DefaultStyle.dp)
		width: mainItem.width
        height: Math.round(45 * DefaultStyle.dp)
		property var remoteNameObj: UtilsCpp.getDisplayName(modelData.core.remoteAddress)
		property var callName : (modelData && !SettingsCpp.disableMeetingsFeature && modelData.core.isConference) 
			? modelData.core.conference.core.subject 
			: remoteNameObj
				? remoteNameObj.value 
				: ""
		Avatar {
			id: delegateAvatar
            Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
			_address: modelData.core.remoteAddress
			secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
			isConference: modelData.core.isConference
			shadowEnabled: false
		}
		ColumnLayout {
			spacing: 0
			Text {
				id: delegateName
				text: callInformationItem.callName
                font.pixelSize: Math.round(14 * DefaultStyle.dp)
				Layout.fillWidth: true
				maximumLineCount: 1
			}
			Text {
				id: callStateText
                //: "Réunion
                property string type: modelData.core.isConference ? qsTr("meeting")
                                                                    //: "Appel"
                                                                  : qsTr("call")
                Layout.rightMargin: Math.round(2 * DefaultStyle.dp)
				text: modelData.core.state === LinphoneEnums.CallState.Paused
				|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
                //: "%1 en pause"
                    ? qsTr("paused_call_or_meeting").arg(type)
                      //: "%1 en cours"
                    : qsTr("ongoing_call_or_meeting").arg(type)
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Math.round(300 * DefaultStyle.dp)
				}
			}
		}
		Item{Layout.fillWidth: true}
		Button {
			id: transferButton
            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignVCenter
            visible: mainItem.isTransferList && (mainItem.currentRemoteAddress !== modelData.core.remoteAddress)
			icon.source: AppIcons.transferCall
			style: ButtonStyle.noBackground
			onClicked: {
				mainItem.transferCallToAnotherRequested(modelData)
			}
			//: Transfer call %1
			Accessible.name: qsTr("transfer_call_name_accessible_name").arg(callInformationItem.callName)
		}
		Button {
			id: pausingButton
			enabled: !(modelData.core.state === LinphoneEnums.CallState.PausedByRemote)
            Layout.preferredWidth: Math.round(28 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignVCenter
            leftPadding: Math.round(5 * DefaultStyle.dp)
            rightPadding: Math.round(5 * DefaultStyle.dp)
            topPadding: Math.round(5 * DefaultStyle.dp)
            bottomPadding: Math.round(5 * DefaultStyle.dp)
			property bool pausedByUser: modelData.core.state === LinphoneEnums.CallState.Paused
			color: pausedByUser ? DefaultStyle.success_500_main : DefaultStyle.grey_500
			contentImageColor: DefaultStyle.grey_0
			KeyNavigation.right: endCallButton
			KeyNavigation.left: endCallButton
			icon.source: pausedByUser ? AppIcons.play : AppIcons.pause
            icon.width: Math.round(18 * DefaultStyle.dp)
            icon.height: Math.round(18 * DefaultStyle.dp)
			onClicked: modelData.core.lSetPaused(!modelData.core.paused)
			TextMetrics {
				id: pauseMeter
				text: pausingButton.text
				font.bold: true
			}
			Accessible.name: (pausedByUser ?
				//: Resume %1 call
				qsTr("resume_call_name_accessible_name") :
				//: Pause %1 call
				qsTr("pause_call_name_accessible_name")
				).arg(callInformationItem.callName)
		}
		SmallButton {
			id: endCallButton
            Layout.preferredWidth: Math.round(38 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
			style: ButtonStyle.phoneRed
			KeyNavigation.left: pausingButton
			KeyNavigation.right: pausingButton
			contentImageColor: DefaultStyle.grey_0
            icon.width: Math.round(18 * DefaultStyle.dp)
            icon.height: Math.round(18 * DefaultStyle.dp)
			onClicked: {
				mainWindow.callTerminatedByUser = true
				mainWindow.endCall(modelData)
			}
			TextMetrics {
				id: endMeter
				text: endCallButton.text
				font.bold: true
			}
			//: End %1 call
			Accessible.name: qsTr("end_call_name_accessible_name").arg(callInformationItem.callName)
		}
	}
}
