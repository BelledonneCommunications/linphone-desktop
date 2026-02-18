import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Linphone
import QtQml
import SettingsCpp
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
	id: mainItem
	implicitHeight: contentHeight
    spacing: Utils.getSizeWithScreenRatio(15)
	clip: true

	property bool isTransferList: false
    property string currentRemoteAddress: AppCpp.calls.currentCall ? AppCpp.calls.currentCall.core.remoteAddress : ""
	signal transferCallToAnotherRequested(CallGui dest)
	
	onCountChanged: forceLayout()

	model: CallProxy {
		id: callProxy
		sourceModel: AppCpp.calls
		showCurrentCall: !mainItem.isTransferList
    }

	delegate: RowLayout {
		id: callInformationItem
        spacing: Utils.getSizeWithScreenRatio(8)
		width: mainItem.width
        height: Utils.getSizeWithScreenRatio(45)
		property var remoteNameObj: UtilsCpp.getDisplayName(modelData.core.remoteAddress)
		property var callName : (modelData && !SettingsCpp.disableMeetingsFeature && modelData.core.isConference) 
			? modelData.core.conference.core.subject 
			: remoteNameObj
				? remoteNameObj.value 
				: ""
		Avatar {
			id: delegateAvatar
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
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
                font.pixelSize: Utils.getSizeWithScreenRatio(14)
				Layout.fillWidth: true
				maximumLineCount: 1
			}
			Text {
				id: callStateText
                //: "Réunion
                property string type: modelData.core.isConference ? qsTr("meeting")
                                                                    //: "Appel"
                                                                  : qsTr("call")
                Layout.rightMargin: Utils.getSizeWithScreenRatio(2)
				text: modelData.core.state === LinphoneEnums.CallState.Paused
				|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
                //: "%1 en pause"
                    ? qsTr("paused_call_or_meeting").arg(type)
                      //: "%1 en cours"
                    : qsTr("ongoing_call_or_meeting").arg(type)
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Utils.getSizeWithScreenRatio(300)
				}
			}
		}
		Item{Layout.fillWidth: true}
		Button {
			id: transferButton
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
			Layout.alignment: Qt.AlignVCenter
            visible: mainItem.isTransferList 
			&& (mainItem.currentRemoteAddress !== modelData.core.remoteAddress)
			&& modelData.core.state !== LinphoneEnums.CallState.IncomingReceived
			&& modelData.core.state !== LinphoneEnums.CallState.PushIncomingReceived
			&& modelData.core.state !== LinphoneEnums.CallState.OutgoingInit
			&& modelData.core.state !== LinphoneEnums.CallState.OutgoingProgress
			&& modelData.core.state !== LinphoneEnums.CallState.OutgoingRinging
			&& modelData.core.state !== LinphoneEnums.CallState.OutgoingEarlyMedia
			&& modelData.core.state !== LinphoneEnums.CallState.IncomingEarlyMedia
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
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(28)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
			Layout.alignment: Qt.AlignVCenter
            leftPadding: Utils.getSizeWithScreenRatio(5)
            rightPadding: Utils.getSizeWithScreenRatio(5)
            topPadding: Utils.getSizeWithScreenRatio(5)
            bottomPadding: Utils.getSizeWithScreenRatio(5)
			property bool pausedByUser: modelData.core.state === LinphoneEnums.CallState.Paused
			color: pausedByUser ? DefaultStyle.success_500_main : DefaultStyle.grey_500
			contentImageColor: DefaultStyle.grey_0
			KeyNavigation.right: endCallButton
			KeyNavigation.left: endCallButton
			icon.source: pausedByUser ? AppIcons.play : AppIcons.pause
            icon.width: Utils.getSizeWithScreenRatio(18)
            icon.height: Utils.getSizeWithScreenRatio(18)
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
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(38)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
			style: ButtonStyle.phoneRed
			KeyNavigation.left: pausingButton
			KeyNavigation.right: pausingButton
			contentImageColor: DefaultStyle.grey_0
            icon.width: Utils.getSizeWithScreenRatio(18)
            icon.height: Utils.getSizeWithScreenRatio(18)
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
