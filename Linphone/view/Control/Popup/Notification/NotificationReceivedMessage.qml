import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import QtQuick.Controls as Control
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

// =============================================================================

Notification {
	id: mainItem
    radius: Math.round(10 * DefaultStyle.dp)
	backgroundColor: DefaultStyle.grey_600
	backgroundOpacity: 0.8
    overriddenWidth: Math.round(400 * DefaultStyle.dp)
	overriddenHeight: content.height

	property var chat: notificationData ? notificationData.chat : null
	
	property string avatarUri: notificationData?.avatarUri
	property string chatRoomName: notificationData?.chatRoomName ? notificationData.chatRoomName : ""
	property string remoteAddress: notificationData?.remoteAddress ? notificationData.remoteAddress : ""
	property string chatRoomAddress: notificationData?.chatRoomAddress ? notificationData.chatRoomAddress : ""
	property bool isGroupChat: notificationData?.isGroupChat ? notificationData.isGroupChat : false
	property string message: notificationData?.message ? notificationData.message : ""
	Connections {
		enabled: chat
		target: chat ? chat.core : null
		function onMessageOpen() {
			close()
		}
	}
	
	Popup {
		id: content
		visible: mainItem.visible
		width: parent.width
        leftPadding: Math.round(18 * DefaultStyle.dp)
        rightPadding: Math.round(18 * DefaultStyle.dp)
        topPadding: Math.round(32 * DefaultStyle.dp)
        bottomPadding: Math.round(18 * DefaultStyle.dp)
		background: Item {
			anchors.fill: parent
			RowLayout {
				anchors.top: parent.top
				anchors.topMargin: Math.round(9 * DefaultStyle.dp)
				anchors.horizontalCenter: parent.horizontalCenter
                spacing: Math.round(4 * DefaultStyle.dp)
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
			Button {
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.topMargin: Math.round(9 * DefaultStyle.dp)
				anchors.rightMargin: Math.round(12 * DefaultStyle.dp)
				padding: 0
				z: mousearea.z + 1
				background: Item{anchors.fill: parent}
				icon.source: AppIcons.closeX
				width: Math.round(14 * DefaultStyle.dp)
				height: Math.round(14 * DefaultStyle.dp)
				icon.width: Math.round(14 * DefaultStyle.dp)
				icon.height: Math.round(14 * DefaultStyle.dp)
				contentImageColor: DefaultStyle.grey_0
				onPressed: {
					mainItem.close()
				}
			}
			MouseArea {
				id: mousearea
				anchors.fill: parent
				onClicked: {
					UtilsCpp.openChat(mainItem.chat)
					mainItem.close()
				}
			}
		}
		contentItem: ColumnLayout {
            spacing: Math.round(9 * DefaultStyle.dp)
			RowLayout {
				spacing: Math.round(14 * DefaultStyle.dp)
				Avatar {
					Layout.preferredWidth: Math.round(60 * DefaultStyle.dp)
					Layout.preferredHeight: Math.round(60 * DefaultStyle.dp)
					// Layout.alignment: Qt.AlignHCenter
					property var contactObj: UtilsCpp.findFriendByAddress(mainItem.remoteAddress)
					contact: contactObj?.value || null
					displayNameVal: mainItem.avatarUri
				}
				ColumnLayout {
					spacing: 0
					Text {
						text: mainItem.chatRoomName
						color: DefaultStyle.grey_100
						Layout.fillWidth: true
						maximumLineCount: 1
						font {
							pixelSize: Typography.h4.pixelSize
							weight: Typography.h4.weight
							capitalization: Font.Capitalize
						}
					}
					Text {
						visible: mainItem.isGroupChat
						text: mainItem.remoteAddress
						color: DefaultStyle.main2_100
						Layout.fillWidth: true
						maximumLineCount: 1
						font {
							pixelSize: Typography.p4.pixelSize
							weight: Typography.p4.weight
						}
					}
					Text {
						text: mainItem.message
						Layout.fillWidth: true
						maximumLineCount: 2
						color: DefaultStyle.grey_300
						font {
							pixelSize: Typography.p1s.pixelSize
							weight: Typography.p1s.weight
						}
					}
				}
			}
		}
	}

}
