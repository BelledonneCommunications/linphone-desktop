import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	property ChatMessageGui chatMessageGui
	property var parentView
	spacing: Math.round(25 * DefaultStyle.dp)

	signal goBackRequested()

	RowLayout {
		BigButton {
			icon.source: AppIcons.leftArrow
			style: ButtonStyle.noBackground
			onClicked: mainItem.goBackRequested()
		}
		Text {
			//: Message status
			text: qsTr("message_details_status title")
			font {
				pixelSize: Typography.h4.pixelSize
				weight: Typography.h4.weight
			}
		}
	}

	ColumnLayout {
		spacing: Math.round(11 * DefaultStyle.dp)
		Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		TabBar {
			id: tabbar
			Layout.fillWidth: true
			model: mainItem.chatMessageGui ? mainItem.chatMessageGui.core.reactionsSingletonAsStrings : []
			pixelSize: Typography.h3m.pixelSize
			textWeight: Typography.h3m.weight
		}

		ListView {
			id: reactionsList
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: Math.round(11 * DefaultStyle.dp)
			model: EmojiProxy {
				reactions: mainItem.chatMessageGui ? mainItem.chatMessageGui.core.reactions : []
				// First index of reactionsSingletonAsStrings list is all reactions combined which does not appear
				// in reactionsSingleton list
				filter: tabbar.currentIndex >=1 && mainItem.chatMessageGui && mainItem.chatMessageGui.core.reactionsSingleton[tabbar.currentIndex-1].body || ""
			}
			delegate: Item {
				width: reactionsList.width
				height: delegateIn.implicitHeight
				property var contactObj: modelData ? UtilsCpp.findFriendByAddress(modelData.address) : null
				property var nameObj: modelData ? UtilsCpp.getDisplayName(modelData.address) : null
				property var isMeObj: modelData ? UtilsCpp.isMe(modelData.address) : null
				MouseArea {
					anchors.fill: parent
					enabled: isMeObj && isMeObj.value
					cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
					hoverEnabled: true
					onClicked: mainItem.chatMessageGui.core.lRemoveReaction()
				}
				RowLayout {
					id: delegateIn
					anchors.fill: parent
					spacing: Math.round(16 * DefaultStyle.dp)
					Avatar {
						Layout.alignment: Qt.AlignHCenter
						contact: contactObj?.value || null
						displayNameVal: contact 
							? "" 
							: nameObj
								? nameObj.value
								: ""
						Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
					}
					ColumnLayout {
						Text {
							text: nameObj?.value || ""
							font {
								pixelSize: Typography.p1.pixelSize
								weight: Typography.p1.weight
							}
						}
						Text {
							visible: isMeObj && isMeObj.value
							//: Click to delete
							text: qsTr("click_to_delete_reaction_info")
							color: DefaultStyle.main2_400
							font {
								pixelSize: Typography.p3.pixelSize
								weight: Typography.p3.weight
							}
						}
					}
					Item{Layout.fillWidth: true}
					Text {
						text: UtilsCpp.encodeEmojiToQmlRichFormat(modelData.body)
						font {
							pixelSize: Typography.h3.pixelSize
							weight: Typography.p3.weight
						}
					}
				}
			}
		}
	}
}
