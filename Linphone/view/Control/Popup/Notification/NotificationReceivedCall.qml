import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

// =============================================================================

Notification {
	id: mainItem
    radius: Math.round(20 * DefaultStyle.dp)
	backgroundColor: DefaultStyle.grey_600
	backgroundOpacity: 0.8
    overriddenWidth: Math.round(400 * DefaultStyle.dp)
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
        leftPadding: Math.round(32 * DefaultStyle.dp)
        rightPadding: Math.round(32 * DefaultStyle.dp)
        topPadding: Math.round(9 * DefaultStyle.dp)
        bottomPadding: Math.round(18 * DefaultStyle.dp)
		anchors.centerIn: parent
		background: Item{}
		contentItem: ColumnLayout {
			anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(9 * DefaultStyle.dp)
			RowLayout {
                spacing: Math.round(4 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignHCenter
				Image {
                    Layout.preferredWidth: Math.round(12 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(12 * DefaultStyle.dp)
					source: AppIcons.logo
				}
				Text {
					text: "Linphone"
					color: DefaultStyle.grey_0
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Typography.b3.weight
						capitalization: Font.Capitalize
					}
				}
			}
			ColumnLayout {
                spacing: Math.round(17 * DefaultStyle.dp)
				ColumnLayout {
                    spacing: Math.round(14 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignHCenter
					Avatar {
                        Layout.preferredWidth: Math.round(60 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(60 * DefaultStyle.dp)
						Layout.alignment: Qt.AlignHCenter
						call: mainItem.call
						isConference: mainItem.call && mainItem.call.core.isConference
					}
					ColumnLayout {
						spacing: 0
						Text {
							text: call.core.remoteName
							Layout.fillWidth: true
                            Layout.maximumWidth: mainItem.width - content.leftPadding - content.rightPadding
							Layout.alignment: Qt.AlignHCenter
							horizontalAlignment: Text.AlignHCenter
							maximumLineCount: 1
							color: DefaultStyle.grey_0
							font {
                                pixelSize: Math.round(20 * DefaultStyle.dp)
                                weight: Typography.b3.weight
								capitalization: Font.Capitalize
							}
						}
						Text {
                            //: "Appel entrant"
                            text: qsTr("call_audio_incoming")
							Layout.alignment: Qt.AlignHCenter
							color: DefaultStyle.grey_0
							font {
                                pixelSize: Math.round(14 * DefaultStyle.dp)
                                weight: Math.round(500 * DefaultStyle.dp)
							}
						}
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
                    spacing: Math.round(26 * DefaultStyle.dp)
					Button {
                        spacing: Math.round(6 * DefaultStyle.dp)
						style: ButtonStyle.phoneGreen
                        Layout.preferredWidth: Math.round(118 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
						asynchronous: false
                        icon.width: Math.round(19 * DefaultStyle.dp)
                        icon.height: Math.round(19 * DefaultStyle.dp)
                        //: "Accepter"
                        text: qsTr("dialog_accept")
                        textSize: Math.round(14 * DefaultStyle.dp)
                        textWeight: Math.round(500 * DefaultStyle.dp)
						onClicked: {
							console.debug("[NotificationReceivedCall] Accept click")
							UtilsCpp.openCallsWindow(mainItem.call)
							mainItem.call.core.lAccept(false)
						}
					}
					Button {
                        spacing: Math.round(6 * DefaultStyle.dp)
						style: ButtonStyle.phoneRed
                        Layout.preferredWidth: Math.round(118 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
						asynchronous: false
                        icon.width: Math.round(19 * DefaultStyle.dp)
                        icon.height: Math.round(19 * DefaultStyle.dp)
                        //: "Refuser
                        text: qsTr("dialog_deny")
                        textSize: Math.round(14 * DefaultStyle.dp)
                        textWeight: Math.round(500 * DefaultStyle.dp)
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
