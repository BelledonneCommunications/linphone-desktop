import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Linphone
import QtQml
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
			shadowEnabled: false
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
				Layout.fillWidth: true
				maximumLineCount: 1
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
			style: ButtonStyle.noBackground
			onClicked: {
				mainItem.transferCallToAnotherRequested(modelData)
			}
		}
		Button {
			id: pausingButton
			enabled: !(modelData.core.state === LinphoneEnums.CallState.PausedByRemote)
			Layout.preferredWidth: 28 * DefaultStyle.dp
			Layout.preferredHeight: 28 * DefaultStyle.dp
			Layout.alignment: Qt.AlignVCenter
			leftPadding: 5 * DefaultStyle.dp
			rightPadding: 5 * DefaultStyle.dp
			topPadding: 5 * DefaultStyle.dp
			bottomPadding: 5 * DefaultStyle.dp
			property bool pausedByUser: modelData.core.state === LinphoneEnums.CallState.Paused
			color: pausedByUser ? DefaultStyle.success_500main : DefaultStyle.grey_500
			contentImageColor: DefaultStyle.grey_0
			KeyNavigation.right: endCallButton
			KeyNavigation.left: endCallButton
			icon.source: pausedByUser ? AppIcons.play : AppIcons.pause
			icon.width: 18 * DefaultStyle.dp
			icon.height: 18 * DefaultStyle.dp
			onClicked: modelData.core.lSetPaused(!modelData.core.paused)
			TextMetrics {
				id: pauseMeter
				text: pausingButton.text
				font.bold: true
			}
		}
		SmallButton {
			id: endCallButton
			Layout.preferredWidth: 38 * DefaultStyle.dp
			Layout.preferredHeight: 28 * DefaultStyle.dp
			style: ButtonStyle.phoneRed
			KeyNavigation.left: pausingButton
			KeyNavigation.right: pausingButton
			contentImageColor: DefaultStyle.grey_0
			icon.width: 18 * DefaultStyle.dp
			icon.height: 18 * DefaultStyle.dp
			onClicked: {
				mainWindow.callTerminatedByUser = true
				mainWindow.endCall(modelData)
			}
			TextMetrics {
				id: endMeter
				text: endCallButton.text
				font.bold: true
			}
		}
	}
}
