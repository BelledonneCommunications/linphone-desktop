import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import QtQuick.Controls as Control
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

// =============================================================================

Notification {
	id: mainItem
    radius: Math.round(20 * DefaultStyle.dp)
	backgroundColor: DefaultStyle.grey_600
	backgroundOpacity: 0.8
    overriddenWidth: Math.round(400 * DefaultStyle.dp)
	overriddenHeight: content.height
	
	property string avatarUri: notificationData && notificationData.avatarUri
	property string chatRoomName: notificationData && notificationData.chatRoomName
	property string remoteAddress: notificationData && notificationData.remoteAddress
	property string message: notificationData && notificationData.message
	
	Popup {
		id: content
		visible: mainItem.visible
		width: parent.width
        leftPadding: Math.round(18 * DefaultStyle.dp)
        rightPadding: Math.round(18 * DefaultStyle.dp)
        topPadding: Math.round(9 * DefaultStyle.dp)
        bottomPadding: Math.round(18 * DefaultStyle.dp)
		background: Item{}
		contentItem: ColumnLayout {
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
				spacing: Math.round(14 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				RowLayout {
					spacing: Math.round(10 * DefaultStyle.dp)
					Avatar {
						Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
						Layout.alignment: Qt.AlignHCenter
						property var contactObj: UtilsCpp.findFriendByAddress(mainItem.remoteAddress)
						contact: contactObj?.value || null
						displayNameVal: contact ? "" : mainItem.avatarUri
					}
					ColumnLayout {
						spacing: 0
						Text {
							text: mainItem.chatRoomName
							color: DefaultStyle.main2_200
							Layout.fillWidth: true
							maximumLineCount: 1
							font {
								pixelSize: Typography.h3.pixelSize
								weight: Typography.h3.weight
								capitalization: Font.Capitalize
							}
						}
						Text {
							text: mainItem.remoteAddress
							color: DefaultStyle.main2_100
							Layout.fillWidth: true
							maximumLineCount: 1
							font {
								pixelSize: Typography.p1.pixelSize
								weight: Typography.p1.weight
							}
						}
					}
					Item{Layout.fillWidth: true}
				}
				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: Math.round(60 * DefaultStyle.dp)
					color: DefaultStyle.main2_400
					radius: Math.round(5 * DefaultStyle.dp)
					Text {
						anchors.fill: parent
						anchors.leftMargin: 8 * DefaultStyle.dp
						anchors.rightMargin: 8 * DefaultStyle.dp
						anchors.topMargin: 8 * DefaultStyle.dp
						anchors.bottomMargin: 8 * DefaultStyle.dp
						verticalAlignment: Text.AlignVCenter
						text: mainItem.message
						maximumLineCount: 2
						color: DefaultStyle.grey_1000
						font {
							pixelSize: Typography.p1s.pixelSize
							weight: Typography.p1s.weight
							italic: true
						}
					}
				}
			}
		}
	}

}
