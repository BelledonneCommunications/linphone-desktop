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

	delegate: Item {
		id: callDelegate
		width: mainItem.width
		height: 45 * DefaultStyle.dp

		RowLayout {
			id: delegateContent
			anchors.fill: parent
			spacing: 0
			Avatar {
				id: delegateAvatar
				_address: modelData.core.remoteAddress
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
			}
			Text {
				id: delegateName
				property var remoteNameObj: UtilsCpp.getDisplayName(modelData.core.remoteAddress)
				text: modelData.core.isConference 
					? modelData.core.conference.core.subject
					: remoteNameObj ? remoteNameObj.value : ""
				Layout.leftMargin: 8 * DefaultStyle.dp
			}
			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true
			}
			Text {
				id: callStateText
				property string type: modelData.core.isConference ? qsTr('Réunion') : qsTr('Appel')
				Layout.rightMargin: 2 * DefaultStyle.dp
				text: modelData.core.state === LinphoneEnums.CallState.Paused
				|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
					? type + qsTr(" en pause")
					: type + qsTr(" en cours")
			}
			Button {
				id: transferButton
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				visible: mainItem.isTransferList && mainItem.currentRemoteAddress !== modelData.core.remoteAddress
				onClicked: {
					mainItem.transferCallToAnotherRequested(modelData)
				}
				icon.source: AppIcons.transferCall
				contentImageColor: down ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
				background: Item {}
			}
			PopupButton {
				visible: !mainItem.isTransferList
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.rightMargin: 10 * DefaultStyle.dp
				Layout.leftMargin: 14 * DefaultStyle.dp
				popup.rightPadding: 10 * DefaultStyle.dp
				popup.contentItem: ColumnLayout {
					spacing: 16 * DefaultStyle.dp
					MenuButton {
						id: pausingButton
						onClicked: modelData.core.lSetPaused(!modelData.core.paused)
						KeyNavigation.up: endCallButton
						KeyNavigation.down: endCallButton
						Layout.preferredWidth: icon.width + spacing + pauseMeter.advanceWidth + leftPadding + rightPadding
						icon.source: modelData.core.state === LinphoneEnums.CallState.Paused 
						|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
						? AppIcons.phone : AppIcons.pause
						text: modelData.core.state === LinphoneEnums.CallState.Paused 
						|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
						? qsTr("Reprendre l'appel") : qsTr("Mettre en pause")
						TextMetrics {
							id: pauseMeter
							text: pausingButton.text
						}
					}
					MenuButton {
						id: endCallButton
						onClicked: {
							mainWindow.callTerminatedByUser = true
							mainWindow.endCall(modelData)
						}
						KeyNavigation.up: pausingButton
						KeyNavigation.down: pausingButton
						Layout.preferredWidth: icon.width + spacing + endMeter.advanceWidth + leftPadding + rightPadding
						icon.source: AppIcons.endCall
						contentImageColor: DefaultStyle.danger_500main
						textColor: DefaultStyle.danger_500main
						text: qsTr("Terminer l'appel")
						TextMetrics {
							id: endMeter
							text: endCallButton.text
						}
					}
				}
			}
		}
	}
}
