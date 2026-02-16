import QtCore
import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

MessageInfosLayout {
	id: mainItem
	spacing: Utils.getSizeWithScreenRatio(25)

	//: Reactions
	title: qsTr("message_details_reactions_title")
	tabbarModel: chatMessageGui ? chatMessageGui.core.reactionsSingletonAsStrings : []
	listModel: EmojiProxy {
		reactions: chatMessageGui ? chatMessageGui.core.reactions : []
		// First index of reactionsSingletonAsStrings list is all reactions combined which does not appear
		// in reactionsSingleton list
		filter: tabbar.currentIndex >=1 && chatMessageGui && chatMessageGui.core.reactionsSingleton[tabbar.currentIndex-1].body || ""
	}
	listView.delegate: Item {
		width: listView.width
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
			spacing: Utils.getSizeWithScreenRatio(16)
			Avatar {
				Layout.alignment: Qt.AlignHCenter
				contact: contactObj?.value || null
				_address: modelData.address
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
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
				textFormat: Text.RichText
				font {
					pixelSize: Typography.h3.pixelSize
					weight: Typography.p3.weight
				}
			}
		}
	}
}
