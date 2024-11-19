import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
// =============================================================================

Notification {
	id: mainItem
	radius: 20 * DefaultStyle.dp
	overriddenWidth: 450 * DefaultStyle.dp//content.width
	overriddenHeight: 101 * DefaultStyle.dp//content.height
	
	readonly property var call: notificationData && notificationData.call
	property var state: call.core.state
	property var status: call.core.status
	onStateChanged:{
		if (state != LinphoneEnums.CallState.IncomingReceived){
			close()
		}
	}
	onStatusChanged:{
		console.log("status", status)
	}
	
	Popup {
		id: content
		visible: mainItem.visible
		width: parent.width
		height: parent.height
		leftPadding: 26 * DefaultStyle.dp
		rightPadding: 26 * DefaultStyle.dp
		topPadding: 15 * DefaultStyle.dp
		bottomPadding: 15 * DefaultStyle.dp
		background: Item{}
		contentItem: RowLayout {
			spacing: 15 * DefaultStyle.dp
			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft
				spacing: 13 * DefaultStyle.dp
				Layout.preferredHeight: childrenRect.height
				Layout.preferredWidth: childrenRect.width
				Avatar {
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					call: mainItem.call
				}
				ColumnLayout {
					Text {
						text: call.core.remoteName
						Layout.fillWidth: true
						Layout.maximumWidth: 200 * DefaultStyle.dp
						maximumLineCount: 1
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
							property var localAddress: UtilsCpp.getDisplayName(call.core.localAddress)
							text: qsTr("Appel entrant")//.arg(localAddress ? qsTr(" pour %1").arg(localAddress.value) : "") //call.core.remoteAddress
							color: DefaultStyle.grey_600
							font {
								pixelSize: 13 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
				}
			}
			Item{Layout.fillWidth: true}
			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				spacing: 26 * DefaultStyle.dp
				Button {
					color: DefaultStyle.success_500main
					Layout.preferredWidth: 75 * DefaultStyle.dp
					Layout.preferredHeight: 55 * DefaultStyle.dp
					asynchronous: false
					contentItem: EffectImage {
						colorizationColor: DefaultStyle.grey_0
						imageSource: AppIcons.phone
						imageWidth: 32 * DefaultStyle.dp
						imageHeight: 32 * DefaultStyle.dp
					}
					onClicked: {
						console.debug("[NotificationReceivedCall] Accept click")
						UtilsCpp.openCallsWindow(mainItem.call)
						mainItem.call.core.lAccept(false)
					}
				}
				Button {
					color: DefaultStyle.danger_500main
					Layout.preferredWidth: 75 * DefaultStyle.dp
					Layout.preferredHeight: 55 * DefaultStyle.dp
					asynchronous: false
					contentItem: EffectImage {
						colorizationColor: DefaultStyle.grey_0
						imageSource: AppIcons.endCall
						imageWidth: 32 * DefaultStyle.dp
						imageHeight: 32 * DefaultStyle.dp
					}
					onClicked: {
						console.debug("[NotificationReceivedCall] Decline click")
						mainItem.call.core.lDecline()
					}
				}
			}
		}
	}

}
