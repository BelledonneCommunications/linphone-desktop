import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils


RowLayout {
    id: mainItem
    property color backgroundColor
    property bool isFirstMessage

    property string imgUrl
    spacing: 0

    property ChatMessageGui chatMessage
    property string fromAddress: chatMessage? chatMessage.core.fromAddress : ""
    property bool isRemoteMessage: chatMessage? chatMessage.core.isRemoteMessage : false
    property bool isFromChatGroup: chatMessage? chatMessage.core.isFromChatGroup : false

    signal messageDeletionRequested()

    Avatar {
        id: avatar
        visible: mainItem.isFromChatGroup
        opacity: mainItem.isRemoteMessage && mainItem.isFirstMessage ? 1 : 0
        Layout.preferredWidth: 26 * DefaultStyle.dp
        Layout.preferredHeight: 26 * DefaultStyle.dp
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: isFirstMessage ? 16 * DefaultStyle.dp : 0
        _address: chatMessage ? chatMessage.core.fromAddress : ""
    }
    Control.Control {
        Layout.topMargin: isFirstMessage ? 16 * DefaultStyle.dp : 0
        Layout.leftMargin: mainItem.isFromChatGroup ? Math.round(9 * DefaultStyle.dp) : 0
        Layout.preferredWidth: Math.min(implicitWidth, mainItem.maxWidth - avatar.implicitWidth)
        // Layout.topMargin: name.visible ? Math.round(7 * DefaultStyle.dp) : 0
        topPadding: Math.round(12 * DefaultStyle.dp)
        bottomPadding: Math.round(12 * DefaultStyle.dp)
        leftPadding: Math.round(18 * DefaultStyle.dp)
        rightPadding: Math.round(18 * DefaultStyle.dp)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: (mouse) => {
                console.log("message clicked")
                if (mouse.button === Qt.RightButton) {
                    optionsMenu.x = mouse.x
                    optionsMenu.open()
                }
            }
        }
        Popup {
            id: optionsMenu
            background: Item {
                anchors.fill: parent
                Rectangle {
                    id: popupBackground
                    anchors.fill: parent
                    color: DefaultStyle.grey_0
                    radius: Math.round(16 * DefaultStyle.dp)
                }
                MultiEffect {
                    source: popupBackground
                    anchors.fill: popupBackground
                    shadowEnabled: true
                    shadowBlur: 0.1
                    shadowColor: DefaultStyle.grey_1000
                    shadowOpacity: 0.4
                }
            }
            contentItem: ColumnLayout {
                IconLabelButton {
                    //: "Supprimer"
                    text: qsTr("chat_message_delete")
                    icon.source: AppIcons.trashCan
                    spacing: Math.round(10 * DefaultStyle.dp)
                    Layout.fillWidth: true
                    onClicked: {
                        mainItem.messageDeletionRequested()
                        optionsMenu.close()
                    }
                    style: ButtonStyle.noBackgroundRed
                }
            }
        }

        background: Item {
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                color: mainItem.backgroundColor
                radius: Math.round(16 * DefaultStyle.dp)
            }
            Rectangle {
                visible: mainItem.isFirstMessage && mainItem.isRemoteMessage
                anchors.top: parent.top
                anchors.left: parent.left
                width: Math.round(parent.width / 4)
                height: Math.round(parent.height / 4)
                color: mainItem.backgroundColor
            }
            Rectangle {
                visible: mainItem.isFirstMessage && !mainItem.isRemoteMessage
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: Math.round(parent.width / 4)
                height: Math.round(parent.height / 4)
                color: mainItem.backgroundColor
            }
        }
        contentItem: ColumnLayout {
            id: contentLayout
            Image {
                visible: mainItem.imgUrl != undefined
                id: contentimage
            }
            Text {
                visible: modelData.core.text != undefined
                text: modelData.core.text
                Layout.fillWidth: true
                color: DefaultStyle.main2_700
                font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
                }
            }
            Text {
                Layout.alignment: Qt.AlignRight
                text: UtilsCpp.formatDate(modelData.core.timestamp, true, false)
                color: DefaultStyle.main2_500main
                font {
                    pixelSize: Typography.p3.pixelSize
                    weight: Typography.p3.weight
                }
            }
        }
    }
}
