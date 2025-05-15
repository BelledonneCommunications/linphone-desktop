import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
    id: mainItem
    property color backgroundColor
    property bool isFirstMessage

    property string imgUrl

    property ChatMessageGui chatMessage
    property string fromAddress: chatMessage? chatMessage.core.fromAddress : ""
    property bool isRemoteMessage: chatMessage? chatMessage.core.isRemoteMessage : false
    property bool isFromChatGroup: chatMessage? chatMessage.core.isFromChatGroup : false
    property var msgState: chatMessage ? chatMessage.core.messageState : LinphoneEnums.ChatMessageState.StateIdle
	property string richFormatText: UtilsCpp.encodeTextToQmlRichFormat(modelData.core.text)
    hoverEnabled: true
    property bool linkHovered: false

    signal messageDeletionRequested()

    background: Item {
        anchors.fill: parent
        Text {
            id: fromNameText
            visible: mainItem.isFromChatGroup && mainItem.isRemoteMessage && mainItem.isFirstMessage
            anchors.top: parent.top
            maximumLineCount: 1
            width: implicitWidth
            x: chatBubble.x
            text: mainItem.chatMessage.core.fromName
            color: DefaultStyle.main2_500main
            font {
                pixelSize: Typography.p4.pixelSize
                weight: Typography.p4.weight
            }
        }
    }

    contentItem: RowLayout {
        spacing: 0
        layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft

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
            id: chatBubble
            Layout.topMargin: isFirstMessage ? 16 * DefaultStyle.dp : 0
            Layout.leftMargin: mainItem.isFromChatGroup ? Math.round(9 * DefaultStyle.dp) : 0
            Layout.preferredWidth: Math.min(implicitWidth, mainItem.maxWidth - avatar.implicitWidth)
            spacing: Math.round(2 * DefaultStyle.dp)
            topPadding: Math.round(12 * DefaultStyle.dp)
            bottomPadding: Math.round(6 * DefaultStyle.dp)
            leftPadding: Math.round(12 * DefaultStyle.dp)
            rightPadding: Math.round(12 * DefaultStyle.dp)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        optionsMenu.open()
                    }
                }
                cursorShape: mainItem.linkHovered ? Qt.PointingHandCursor : Qt.IBeamCursor
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
					id: textElement
					visible: mainItem.richFormatText !== ""
					text: mainItem.richFormatText
					textFormat: Text.RichText
					wrapMode: Text.Wrap
					Layout.fillWidth: true
					Layout.fillHeight: true
					horizontalAlignment: modelData.core.isRemoteMessage ? Text.AlignLeft : Text.AlignRight
					color: DefaultStyle.main2_700
					font {
						pixelSize: Typography.p1.pixelSize
						weight: Typography.p1.weight
					}
					onLinkActivated: {
						if (link.startsWith('sip'))
							UtilsCpp.createCall(link)
						else
							Qt.openUrlExternally(link)
					}
					onHoveredLinkChanged: {
						mainItem.linkHovered = hoveredLink !== ""
					}
				}
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Text {
                        text: UtilsCpp.formatDate(modelData.core.timestamp, true, false)
                        color: DefaultStyle.main2_500main
                        font {
                            pixelSize: Typography.p3.pixelSize
                            weight: Typography.p3.weight
                        }
                    }
                    EffectImage {
                        visible: !mainItem.isRemoteMessage
                        Layout.preferredWidth: visible ? 14 * DefaultStyle.dp : 0
                        Layout.preferredHeight: 14 * DefaultStyle.dp
                        colorizationColor: DefaultStyle.main1_500_main
                        imageSource: mainItem.msgState === LinphoneEnums.ChatMessageState.StateDelivered
                            ? AppIcons.envelope
                            : mainItem.msgState === LinphoneEnums.ChatMessageState.StateDeliveredToUser
                                ? AppIcons.check
                                : mainItem.msgState === LinphoneEnums.ChatMessageState.StateNotDelivered
                                    ? AppIcons.warningCircle
                                    : mainItem.msgState === LinphoneEnums.ChatMessageState.StateDisplayed
                                        ? AppIcons.checks
                                        : ""
                    }
                }
            }
        }
        RowLayout {
            id: actionsLayout
            visible: mainItem.hovered || optionsMenu.hovered || optionsMenu.popup.opened || emojiButton.hovered
            Layout.leftMargin: Math.round(8 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(8 * DefaultStyle.dp)
            Layout.alignment: Qt.AlignVCenter
            // Layout.fillWidth: true
            spacing: Math.round(7 * DefaultStyle.dp)
            layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft
            PopupButton {
                id: optionsMenu
                popup.padding: 0
                popup.contentItem: ColumnLayout {
                    spacing: 0
                    IconLabelButton {
                        inverseLayout: true
                        //: "Copy"
                        text: qsTr("chat_message_copy")
                        icon.source: AppIcons.copy
                        // spacing: Math.round(10 * DefaultStyle.dp)
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45 * DefaultStyle.dp
                        onClicked: {
                            var success = UtilsCpp.copyToClipboard(modelData.core.text)
                            //: Copied
                            if (success) UtilsCpp.showInformationPopup(qsTr("chat_message_copied_to_clipboard_title"),
                                            //: "in clipboard"
                                            qsTr("chat_message_copied_to_clipboard_toast"))
                            }
                    }
                    IconLabelButton {
                        inverseLayout: true
                        //: "Delete"
                        text: qsTr("chat_message_delete")
                        icon.source: AppIcons.trashCan
                        // spacing: Math.round(10 * DefaultStyle.dp)
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45 * DefaultStyle.dp
                        onClicked: {
                            mainItem.messageDeletionRequested()
                            optionsMenu.close()
                        }
                        style: ButtonStyle.hoveredBackgroundRed
                    }
                }
            }
            BigButton {
                id: emojiButton
                style: ButtonStyle.noBackground
                icon.source: AppIcons.smiley
            }
        }
        Item{Layout.fillWidth: true}
    }
}
