import QtQuick 2.7
import QtQuick.Layouts 1.3
import Linphone
import UtilsCpp
// =============================================================================

Notification {
	id: mainItem
	
	// ---------------------------------------------------------------------------
	
	readonly property var call: notificationData && notificationData.call
	property var state: call.core.state
	onStateChanged:{
		console.log("state notif", state, this)
		 if(state != LinphoneEnums.CallState.IncomingReceived){
			close()
		}
	}
	// overridenWidth: 320 * DefaultStyle.dp
	// overridenHeight: 150 * DefaultStyle.dp
	// ---------------------------------------------------------------------------
	ColumnLayout {
		anchors.fill: parent
		anchors.leftMargin: 15
		anchors.rightMargin: 15
		anchors.bottomMargin:15
		anchors.topMargin:15
	
	// ---------------------------------------------------------------------
	// Action buttons.
	// ---------------------------------------------------------------------
	
		RowLayout {
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignLeft
			spacing: 15 * DefaultStyle.dp
			Avatar {
				Layout.preferredWidth: 40 * DefaultStyle.dp
				Layout.preferredHeight: 40 * DefaultStyle.dp
				call: mainItem.call
			}
			ColumnLayout {
				Text {
					property var remoteAddress: UtilsCpp.getDisplayName(call.core.peerAddress)
					text: remoteAddress ? remoteAddress.value : ""
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 700 * DefaultStyle.dp
					}
				}
				Text {
					text: call.core.peerAddress
				}
			}
		}
	
		RowLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			spacing: 10 * DefaultStyle.dp
			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				spacing: 3 * DefaultStyle.dp
				Button {
					color: DefaultStyle.success_500main
					Layout.preferredWidth: 40 * DefaultStyle.dp
					Layout.preferredHeight: 40 * DefaultStyle.dp
					contentItem: EffectImage {
						colorizationColor: DefaultStyle.grey_0
						source: AppIcons.phone
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					onClicked: {
						mainItem.call.core.lAccept(false)
						UtilsCpp.openCallsWindow(mainItem.call)
					}
				}
				Button {
					color: DefaultStyle.success_500main
					Layout.preferredWidth: 40 * DefaultStyle.dp
					Layout.preferredHeight: 40 * DefaultStyle.dp
					contentItem: EffectImage {
						colorizationColor: DefaultStyle.grey_0
						source: AppIcons.videoCamera
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					onClicked: {
						mainItem.call.core.lAccept(true)
						UtilsCpp.openCallsWindow(mainItem.call)
					}
				}
			}
			Item{
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			Button {
				color: DefaultStyle.danger_500main
				Layout.rightMargin: 20 * DefaultStyle.dp
				Layout.preferredWidth: 55 * DefaultStyle.dp
				Layout.preferredHeight: 40 * DefaultStyle.dp
				contentItem: EffectImage {
					colorizationColor: DefaultStyle.grey_0
					source: AppIcons.endCall
					imageWidth: 24 * DefaultStyle.dp
					imageHeight: 24 * DefaultStyle.dp
				}
				onClicked: {
					mainItem.call.core.lDecline()
				}
			}
		}
	}
}
