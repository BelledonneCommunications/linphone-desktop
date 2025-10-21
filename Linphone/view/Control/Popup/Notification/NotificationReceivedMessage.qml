import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import QtQuick.Controls as Control
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================

Notification {
	id: mainItem
    radius: Utils.getSizeWithScreenRatio(10)
	backgroundColor: DefaultStyle.grey_600
	backgroundOpacity: 0.8
    overriddenWidth: Utils.getSizeWithScreenRatio(400)
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
        leftPadding: Utils.getSizeWithScreenRatio(18)
        rightPadding: Utils.getSizeWithScreenRatio(18)
        topPadding: Utils.getSizeWithScreenRatio(32)
        bottomPadding: Utils.getSizeWithScreenRatio(18)
		background: Item {
			anchors.fill: parent
			RowLayout {
				anchors.top: parent.top
				anchors.topMargin: Utils.getSizeWithScreenRatio(9)
				anchors.horizontalCenter: parent.horizontalCenter
                spacing: Utils.getSizeWithScreenRatio(4)
				Image {
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(12)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(12)
					source: AppIcons.logo
				}
				Text {
					text: "Linphone"
					color: DefaultStyle.grey_0
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Typography.b3.weight
						capitalization: Font.Capitalize
					}
				}
			}
			Button {
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.topMargin: Utils.getSizeWithScreenRatio(9)
				anchors.rightMargin: Utils.getSizeWithScreenRatio(12)
				padding: 0
				z: mousearea.z + 1
				background: Item{anchors.fill: parent}
				icon.source: AppIcons.closeX
				width: Utils.getSizeWithScreenRatio(14)
				height: Utils.getSizeWithScreenRatio(14)
				icon.width: Utils.getSizeWithScreenRatio(14)
				icon.height: Utils.getSizeWithScreenRatio(14)
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
            spacing: Utils.getSizeWithScreenRatio(9)
			RowLayout {
				spacing: Utils.getSizeWithScreenRatio(14)
				Avatar {
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(60)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(60)
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
