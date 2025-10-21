import QtCore
import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

MessageInfosLayout {
	id: mainItem
	spacing: Utils.getSizeWithScreenRatio(25)
	//: Message status
	title: qsTr("message_details_status_title")
	tabbarModel: chatMessageGui ? chatMessageGui.core.imdnStatusListAsString : []
	listModel: ImdnStatusProxy {
		imdnStatusList: chatMessageGui ? chatMessageGui.core.imdnStatusList : []
		filter: chatMessageGui && chatMessageGui.core.imdnStatusAsSingletons[mainItem.tabbar.currentIndex]?.state || LinphoneEnums.ChatMessageState.StateIdle
	}

	listView.delegate: Item {
		id: listDelegate
		width: listView.width
		height: delegateIn.implicitHeight
		property var contactObj: modelData ? UtilsCpp.findFriendByAddress(modelData.address) : null
		property FriendGui contact: contactObj && contactObj.value || null
		property var nameObj: modelData ? UtilsCpp.getDisplayName(modelData.address) : null
		property string updateTime: UtilsCpp.isCurrentDay(modelData.lastUpdatedTime)
			? UtilsCpp.toTimeString(modelData.lastUpdatedTime, "hh:mm")
			: UtilsCpp.formatDate(modelData.lastUpdatedTime, true)
		RowLayout {
			id: delegateIn
			anchors.fill: parent
			spacing: Utils.getSizeWithScreenRatio(16)
			Avatar {
				Layout.alignment: Qt.AlignHCenter
				contact: listDelegate.contact
				_address: modelData.address
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
			}
			ColumnLayout {
				spacing: 0
				Text {
					text: nameObj?.value || ""
					font {
						pixelSize: Typography.p1.pixelSize
						weight: Typography.p1.weight
					}
				}
				Text {
					visible: listDelegate.contact
					horizontalAlignment: Text.AlignLeft
					Layout.fillWidth: true
					text: listDelegate.contact ? listDelegate.contact.core.presenceStatus : ""
					color: listDelegate.contact ? listDelegate.contact.core.presenceColor : 'transparent'
					font {
						pixelSize: Typography.p3.pixelSize
						weight: Typography.p3.weight
					}
				}
			}
			Item{Layout.fillWidth: true}
			Text {
				text: listDelegate.updateTime
				font {
					pixelSize: Typography.p3.pixelSize
					weight: Typography.p3.weight
				}
			}
		}
	}
}
