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
    spacing: Math.round(4 * DefaultStyle.dp)
    property ChatGui chat
    property color backgroundColor

    Component.onCompleted: {
        var index = chatMessageProxy.findFirstUnreadIndex()
        positionViewAtIndex(index, ListView.End)
        var chatMessage = chatMessageProxy.getChatMessageAtIndex(index)
        if (chatMessage && !chatMessage.core.isRead) chatMessage.core.lMarkAsRead()
    }

    onCountChanged: if (atYEnd) {
        var index = chatMessageProxy.findFirstUnreadIndex()
        mainItem.positionViewAtIndex(index, ListView.End)
        var chatMessage = chatMessageProxy.getChatMessageAtIndex(index)
        if (chatMessage && !chatMessage.core.isRead) chatMessage.core.lMarkAsRead()
    }
    
    Button {
        visible: !mainItem.atYEnd
        icon.source: AppIcons.downArrow
        leftPadding: Math.round(16 * DefaultStyle.dp)
        rightPadding: Math.round(16 * DefaultStyle.dp)
        topPadding: Math.round(16 * DefaultStyle.dp)
        bottomPadding: Math.round(16 * DefaultStyle.dp)
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Math.round(18 * DefaultStyle.dp)
        anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
        onClicked: {
            var index = chatMessageProxy.findFirstUnreadIndex()
            mainItem.positionViewAtIndex(index, ListView.End)
            var chatMessage = chatMessageProxy.getChatMessageAtIndex(index)
            if (chatMessage && !chatMessage.core.isRead) chatMessage.core.lMarkAsRead()
        }
    }

    model: ChatMessageProxy {
        id: chatMessageProxy
        chatGui: mainItem.chat
        // scroll when in view and message inserted
        onMessageInserted: (index, gui) => {
            if (!mainItem.visible) return
            mainItem.positionViewAtIndex(index, ListView.End)
            if (!gui.core.isRead) gui.core.lMarkAsRead()
        }
    }

    header: Item {
        height: headerMessage.height + Math.round(50 * DefaultStyle.dp)
        width: headerMessage.width
        anchors.horizontalCenter: parent.horizontalCenter
        Control.Control {
            id: headerMessage
            anchors.topMargin: Math.round(30 * DefaultStyle.dp)
            anchors.top: parent.top
            padding: Math.round(10 * DefaultStyle.dp)
            background: Rectangle {
                color: "transparent"
                border.color: DefaultStyle.main2_200
                border.width: Math.round(2 * DefaultStyle.dp)
                radius: Math.round(10 * DefaultStyle.dp)
            }
            contentItem: RowLayout {
                EffectImage {
                    Layout.preferredWidth: Math.round(23 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(23 * DefaultStyle.dp)
                    imageSource: AppIcons.lockSimple
                    colorizationColor: DefaultStyle.info_500_main
                }
                ColumnLayout {
                    spacing: Math.round(2 * DefaultStyle.dp)
                    Text {
                        //: End to end encrypted chat
                        text: qsTr("chat_message_list_encrypted_header_title")
                        Layout.fillWidth: true
                        color: DefaultStyle.info_500_main
                        font {
                            pixelSize: Typography.p2.pixelSize
                            weight: Typography.p2.weight
                        }
                    }
                    Text {
                        //: Les messages de cette conversation sont chiffrés de bout \n en bout. Seul votre correspondant peut les déchiffrer.
                        text: qsTr("chat_message_list_encrypted_header_message")
                        Layout.fillWidth: true
                        color: DefaultStyle.grey_400
                        font {
                            pixelSize: Typography.p3.pixelSize
                            weight: Typography.p3.weight
                        }
                    }
                }
            }
        }
    }

    delegate: ChatMessage {
        chatMessage: modelData
        property real maxWidth: Math.round(mainItem.width * (3/4))
        onVisibleChanged: if (!modelData.core.isRead) modelData.core.lMarkAsRead()
        width: mainItem.width
        property var previousIndex: index - 1
        property var previousFromAddress: chatMessageProxy.getChatMessageAtIndex(index-1)?.core.fromAddress
        backgroundColor: isRemoteMessage ? DefaultStyle.main2_100 : DefaultStyle.main1_100
        isFirstMessage: !previousFromAddress || previousFromAddress !== modelData.core.fromAddress
        anchors.right: !isRemoteMessage && parent
            ? parent.right
            : undefined

        onMessageDeletionRequested: modelData.core.lDelete()
    }

    footerPositioning: ListView.OverlayFooter
    footer: Control.Control {
        visible: composeLayout.composingName !== ""
        width: mainItem.width
        z: mainItem.z + 2
        topPadding: Math.round(5 * DefaultStyle.dp)
        bottomPadding: Math.round(5 * DefaultStyle.dp)
        background: Rectangle {
            anchors.fill: parent
            color: mainItem.backgroundColor
        }
        contentItem: RowLayout {
            id: composeLayout
            property string composingName: mainItem.chat.core.composingName
            Avatar {
                Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
                _address: mainItem.chat.core.composingAddress
            }
            Text {
                Layout.fillWidth: true
                font {
                    pixelSize: Typography.p3.pixelSize
                    weight: Typography.p3.weight
                }
                //: %1 is writing…
                text: qsTr("chat_message_is_writing_info").arg(composeLayout.composingName)
            }
        }
    }
}
