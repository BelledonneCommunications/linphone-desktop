import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
// =============================================================================

Notification {
	id: mainItem
	radius: 20 * DefaultStyle.dp
	backgroundColor: DefaultStyle.grey_600
	backgroundOpacity: 0.8
	overriddenWidth: 400 * DefaultStyle.dp
	overriddenHeight: content.height
	
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
		leftPadding: 32 * DefaultStyle.dp
		rightPadding: 32 * DefaultStyle.dp
		topPadding: 9 * DefaultStyle.dp
		bottomPadding: 18 * DefaultStyle.dp
		anchors.centerIn: parent
		background: Item{}
		contentItem: ColumnLayout {
			anchors.verticalCenter: parent.verticalCenter
			spacing: 9 * DefaultStyle.dp
			RowLayout {
				spacing: 4 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
				Image {
					Layout.preferredWidth: 12 * DefaultStyle.dp
					Layout.preferredHeight: 12 * DefaultStyle.dp
					source: AppIcons.logo
				}
				Text {
					text: "Linphone"
					color: DefaultStyle.grey_0
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 600 * DefaultStyle.dp
						capitalization: Font.Capitalize
					}
				}
			}
			ColumnLayout {
				spacing: 17 * DefaultStyle.dp
				ColumnLayout {
					spacing: 14 * DefaultStyle.dp
					Layout.alignment: Qt.AlignHCenter
					Avatar {
						Layout.preferredWidth: 60 * DefaultStyle.dp
						Layout.preferredHeight: 60 * DefaultStyle.dp
						Layout.alignment: Qt.AlignHCenter
						call: mainItem.call
						isConferenceInfo: mainItem.call && mainItem.call.core.isConference
					}
					ColumnLayout {
						spacing: 0
						Text {
							text: call.core.remoteName
							Layout.fillWidth: true
							Layout.maximumWidth: (mainItem.width - content.leftPadding - content.rightPadding) * DefaultStyle.dp
							Layout.alignment: Qt.AlignHCenter
							horizontalAlignment: Text.AlignHCenter
							maximumLineCount: 1
							color: DefaultStyle.grey_0
							font {
								pixelSize: 20 * DefaultStyle.dp
								weight: 600 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
						Text {
							text: qsTr("Appel audio")
							Layout.alignment: Qt.AlignHCenter
							color: DefaultStyle.grey_0
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 500 * DefaultStyle.dp
							}
						}
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					spacing: 26 * DefaultStyle.dp
					Button {
						spacing: 6 * DefaultStyle.dp
						color: DefaultStyle.success_500main
						borderColor: color
						Layout.preferredWidth: 118 * DefaultStyle.dp
						Layout.preferredHeight: 32 * DefaultStyle.dp
						asynchronous: false
						icon.source: AppIcons.phone
						icon.width: 19 * DefaultStyle.dp
						icon.height: 19 * DefaultStyle.dp
						contentImageColor: DefaultStyle.grey_0
						text: qsTr("Répondre")
						textColor: DefaultStyle.grey_0
						textSize: 14 * DefaultStyle.dp
						textWeight: 500 * DefaultStyle.dp
						onClicked: {
							console.debug("[NotificationReceivedCall] Accept click")
							UtilsCpp.openCallsWindow(mainItem.call)
							mainItem.call.core.lAccept(false)
						}
					}
					Button {
						spacing: 6 * DefaultStyle.dp
						color: DefaultStyle.danger_500main
						borderColor: color
						Layout.preferredWidth: 118 * DefaultStyle.dp
						Layout.preferredHeight: 32 * DefaultStyle.dp
						asynchronous: false
						icon.source: AppIcons.endCall
						icon.width: 19 * DefaultStyle.dp
						icon.height: 19 * DefaultStyle.dp
						contentImageColor: DefaultStyle.grey_0
						text: qsTr("Refuser")
						textColor: DefaultStyle.grey_0
						textSize: 14 * DefaultStyle.dp
						textWeight: 500 * DefaultStyle.dp
						onClicked: {
							console.debug("[NotificationReceivedCall] Decline click")
							mainItem.call.core.lDecline()
						}
					}
				}
			}
		}
	}

}
