import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Linphone
import QtQml
import UtilsCpp 1.0

ListView {
	id: mainItem
	model: CallProxy {
		id: callProxy
		sourceModel: AppCpp.calls
	}
	implicitHeight: contentHeight
	spacing: 15 * DefaultStyle.dp
	clip: true
	onCountChanged: forceLayout()

	signal transferCallToAnotherRequested(CallGui dest)

	property bool isTransferList: false
	property string currentRemoteAddress: callProxy.currentCall ? callProxy.currentCall.core.remoteAddress : ""

	delegate: RowLayout {
		spacing: 8 * DefaultStyle.dp
		width: mainItem.width
		height: 45 * DefaultStyle.dp
		Avatar {
			id: delegateAvatar
			Layout.preferredWidth: 45 * DefaultStyle.dp
			Layout.preferredHeight: 45 * DefaultStyle.dp
			_address: modelData.core.remoteAddress
			isConference: modelData.core.isConference
		}
		ColumnLayout {
			spacing: 0
			Text {
				id: delegateName
				property var remoteNameObj: UtilsCpp.getDisplayName(modelData.core.remoteAddress)
				text: modelData.core.isConference 
					? modelData.core.conference.core.subject
					: remoteNameObj ? remoteNameObj.value : ""
				font.pixelSize: 14 * DefaultStyle.dp
			}
			Text {
				id: callStateText
				property string type: modelData.core.isConference ? qsTr('Réunion') : qsTr('Appel')
				Layout.rightMargin: 2 * DefaultStyle.dp
				text: modelData.core.state === LinphoneEnums.CallState.Paused
				|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
					? type + qsTr(" en pause")
					: type + qsTr(" en cours")
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
				}
			}
		}
		Item{Layout.fillWidth: true}
		Button {
			id: transferButton
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			Layout.alignment: Qt.AlignVCenter
			visible: mainItem.isTransferList && mainItem.currentRemoteAddress !== modelData.core.remoteAddress
			icon.source: AppIcons.transferCall
			contentImageColor: down ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
			onClicked: {
				mainItem.transferCallToAnotherRequested(modelData)
			}
			background: Item {}
		}
		Button {
			id: pausingButton
			Layout.preferredWidth: 28 * DefaultStyle.dp
			Layout.preferredHeight: 28 * DefaultStyle.dp
			Layout.alignment: Qt.AlignVCenter
			leftPadding: 5 * DefaultStyle.dp
			rightPadding: 5 * DefaultStyle.dp
			topPadding: 5 * DefaultStyle.dp
			bottomPadding: 5 * DefaultStyle.dp
			property bool isPaused: modelData.core.state === LinphoneEnums.CallState.Paused 
			|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
			color: isPaused ? DefaultStyle.success_500main : DefaultStyle.grey_500
			contentImageColor: DefaultStyle.grey_0
			KeyNavigation.right: endCallButton
			KeyNavigation.left: endCallButton
			icon.source: isPaused ? AppIcons.play : AppIcons.pause
			icon.width: 18 * DefaultStyle.dp
			icon.height: 18 * DefaultStyle.dp
			onClicked: modelData.core.lSetPaused(!modelData.core.paused)
			TextMetrics {
				id: pauseMeter
				text: pausingButton.text
			}
		}
		Button {
			id: endCallButton
			Layout.preferredWidth: 38 * DefaultStyle.dp
			Layout.preferredHeight: 28 * DefaultStyle.dp
			leftPadding: 10 * DefaultStyle.dp
			rightPadding: 10 * DefaultStyle.dp
			topPadding: 5 * DefaultStyle.dp
			bottomPadding: 5 * DefaultStyle.dp
			color: DefaultStyle.danger_500main
			KeyNavigation.left: pausingButton
			KeyNavigation.right: pausingButton
			icon.source: AppIcons.endCall
			contentImageColor: DefaultStyle.grey_0
			icon.width: 18 * DefaultStyle.dp
			icon.height: 18 * DefaultStyle.dp
			textColor: DefaultStyle.danger_500main
			onClicked: {
				mainWindow.callTerminatedByUser = true
				mainWindow.endCall(modelData)
			}
			TextMetrics {
				id: endMeter
				text: endCallButton.text
			}
		}
	}
}
