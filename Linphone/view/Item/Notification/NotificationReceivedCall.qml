import QtQuick 2.7
import QtQuick.Layouts 1.3
import Linphone
import UtilsCpp
// =============================================================================

Notification {
	id: mainItem
	radius: 20 * DefaultStyle.dp
	overriddenHeight: 101 * DefaultStyle.dp
	overriddenWidth: 422 * DefaultStyle.dp

	readonly property var call: notificationData && notificationData.call
	property var state: call.core.state
	onStateChanged:{
		if (state != LinphoneEnums.CallState.IncomingReceived){
			close()
		}
	}

	RowLayout {
		anchors.fill: parent
		anchors.leftMargin: 19 * DefaultStyle.dp
		anchors.rightMargin: 19 * DefaultStyle.dp
		anchors.bottomMargin: 15 * DefaultStyle.dp
		anchors.topMargin: 15 * DefaultStyle.dp
		spacing: 30 * DefaultStyle.dp
		RowLayout {
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignLeft
			spacing: 13 * DefaultStyle.dp
			Avatar {
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				call: mainItem.call
			}
			ColumnLayout {
				Text {
					property var remoteAddress: UtilsCpp.getDisplayName(call.core.peerAddress)
					text: remoteAddress ? remoteAddress.value : ""
					color: DefaultStyle.grey_600
					font {
						pixelSize: 20 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
						capitalization: Font.Capitalize
					}
				}
				RowLayout {
					EffectImage {
						imageSource: AppIcons.arrowDownLeft
						colorizationColor: DefaultStyle.success_500main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
					}
					Text {
						Layout.fillWidth: true
						elide: Text.ElideRight
						property var localAddress: UtilsCpp.getDisplayName(call.core.localAddress)
						text: qsTr("Appel entrant%1").arg(localAddress ? qsTr(" pour %1").arg(localAddress.value) : "") //call.core.peerAddress
						color: DefaultStyle.grey_600
						font {
							pixelSize: 13 * DefaultStyle.dp
							weight: 400 * DefaultStyle.dp
						}
					}
				}
			}
		}
		
		RowLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			spacing: 26 * DefaultStyle.dp
			Button {
				color: DefaultStyle.success_500main
				Layout.preferredWidth: 75 * DefaultStyle.dp
				Layout.preferredHeight: 55 * DefaultStyle.dp
				contentItem: EffectImage {
					colorizationColor: DefaultStyle.grey_0
					imageSource: AppIcons.phone
					imageWidth: 32 * DefaultStyle.dp
					imageHeight: 32 * DefaultStyle.dp
				}
				onClicked: {
					mainItem.call.core.lAccept(false)
					UtilsCpp.openCallsWindow(mainItem.call)
				}
			}
			Button {
				color: DefaultStyle.danger_500main
				Layout.preferredWidth: 75 * DefaultStyle.dp
				Layout.preferredHeight: 55 * DefaultStyle.dp
				contentItem: EffectImage {
					colorizationColor: DefaultStyle.grey_0
					imageSource: AppIcons.endCall
					imageWidth: 32 * DefaultStyle.dp
					imageHeight: 32 * DefaultStyle.dp
				}
				onClicked: {
					mainItem.call.core.lDecline()
				}
			}
		}
	}
}
