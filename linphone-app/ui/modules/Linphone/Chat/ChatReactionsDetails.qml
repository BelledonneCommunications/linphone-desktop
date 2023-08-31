import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0
import Units 1.0
import ColorsList 1.0

// =============================================================================

Rectangle{
	id: mainItem
	property string sectionName: 'ChatReactions'
	property font emojiFont : SettingsModel.emojiFont
	property font textFont : SettingsModel.textMessageFont
	property alias chatMessageModel: chatReactionsList.chatMessageModel
	
	
	function show(message){
		chatReactionsList.setChatMessageModel(message, ChatReactionListModel.REACTIONS)
		visible = true
	}

	color: ChatReactionsDetailsStyle.backgroundColorModel.color
	onVisibleChanged: if(visible){
		tabBar.currentIndex = 0
	}
	MouseArea{
		anchors.fill: parent
		onClicked: mainItem.visible = false
	}
	Rectangle{
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: parent.height / 2
		color: ChatReactionsDetailsStyle.stickerColorModel.color
		
		ColumnLayout{
			anchors.fill: parent
			spacing: 0
			TabBar {
				Layout.fillWidth: true
				id: tabBar
				TabButton {
						Layout.fillWidth: true
						//: "%1<br>reactions" : count of all chat reactions with a jump line between count and text.
						text: UtilsCpp.encodeTextToQmlRichFormat(qsTr('reactionsCount', '', chatReactionsList.reactionCount).arg(chatReactionsList.reactionCount), {noLink:1}).toUpperCase()
						// noLink=1 to avoid <br> convertion
						textFont: mainItem.textFont
						onIsSelectedChanged: if(isSelected) chatReactionsList.filter = ''
						displaySelector: true
						stretchContent: false
						style: TabButtonStyle.popup
					}
				Repeater{
					model: ['❤️','👍','😂','😮','😢']
					delegate: TabButton {
						width: visible ? undefined : 0
						property int reactionCount: 0
						visible: reactionCount > 0
						text: UtilsCpp.encodeTextToQmlRichFormat(modelData + ' '+reactionCount)
						textFont.family: mainItem.textFont.family
						textFont.pointSize: ChatReactionsDetailsStyle.tabBar.pointSize
						
						onIsSelectedChanged: if(isSelected) chatReactionsList.filter = modelData
						displaySelector: true
						stretchContent: false
						style: TabButtonStyle.popup
						
						Connections{
							target: chatReactionsList
							onChatMessageModelChanged: reactionCount = chatReactionsList.getChatReactionCount(modelData)
						}
					}
				}
			}
			Rectangle{
				id: separator
				Layout.fillWidth: true
				Layout.preferredHeight: 2
				color: ChatReactionsDetailsStyle.separatorColorModel.color
			}
			Item{
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: 10
				ScrollableListView{
					id: listView
					anchors.fill: parent
					model: ChatReactionProxyModel{
						id: chatReactionsList
						groupBy: ChatReactionListModel.REACTIONS
					}
					delegate: RowLayout{
						width: listView.width
						Contact {
							Layout.fillWidth: true	
							showSubtitle: false
							property var sipObserver: SipAddressesModel.getSipAddressObserver($modelData.reaction.fromAddress, $modelData.reaction.fromAddress)
							entry: sipObserver
							Component.onDestruction: sipObserver=null// Need to set it to null because of not calling destructor if not.
						}
						Text{
							Layout.rightMargin: 20
							text: $modelData.reaction.body
							font.family: mainItem.emojiFont.family
							font.pointSize: mainItem.emojiFont.pointSize * 2
						}
					}
				}
			}
		}
	}
}
