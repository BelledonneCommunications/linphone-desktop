import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

MainRightPanel {
	id: mainItem

	property FriendGui contact
	property int filter
    contentTopPadding: Utils.getSizeWithScreenRatio(24)

    property string title: filter === ChatMessageFileProxy.FilterContentType.Medias
    //: "Shared medias"
    ? qsTr("contact_shared_medias_title") 
    //: "Shared documents"
    : qsTr("contact_shared_documents_title")
	
	signal close()

	headerContentItem: RowLayout {
		Text {
			text: mainItem.title
			font {
				pixelSize: Utils.getSizeWithScreenRatio(20)
				weight: Typography.h4.weight
			}
		}
		Item{Layout.fillWidth: true}
		Button {
			style: ButtonStyle.noBackground
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
			Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
			icon.source: AppIcons.closeX
			icon.width: Utils.getSizeWithScreenRatio(24)
			icon.height: Utils.getSizeWithScreenRatio(24)
			//: Close %1
			Accessible.name: qsTr("close_accessible_name").arg(mainItem.title)
			onClicked: {
                mainItem.close()
			}
		}
	}

    content: MessageSharedFilesInfos {
        showTitle: false
        property var chatObj: mainItem.contact 
            ? UtilsCpp.getChatForAddress(mainItem.contact.core.defaultAddress) 
            : null
        chatGui: chatObj && chatObj.value || null
        filter: mainItem.filter
    }
}