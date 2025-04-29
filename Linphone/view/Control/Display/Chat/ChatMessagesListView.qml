import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
    id: mainItem
    property ChatGui chat
    spacing: Math.round(20 * DefaultStyle.dp)

    Component.onCompleted: positionViewAtEnd()

    model: ChatMessageProxy {
        chatGui: mainItem.chat
    }

    header: Item {
        height: Math.round(18 * DefaultStyle.dp)
    }

    delegate: ChatMessage {
        id: chatMessage
        width: Math.min(implicitWidth, Math.round(mainItem.width * (3/4)))
        // height: childrenRect.height
        backgroundColor: isRemoteMessage ? DefaultStyle.main2_100 : DefaultStyle.main1_100
        contentText: modelData.core.text
        isFirstMessage: true
        isRemoteMessage: modelData.core.isRemoteMessage
        anchors.right: !isRemoteMessage && parent
            ? parent.right
            : undefined
    }
}
