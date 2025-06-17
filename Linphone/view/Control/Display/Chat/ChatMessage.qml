import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import ConstantsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
    id: mainItem
    property color backgroundColor
    property bool isFirstMessage

    property ChatMessageGui chatMessage
    property string ownReaction: chatMessage? chatMessage.core.ownReaction : ""
    property string fromAddress: chatMessage? chatMessage.core.fromAddress : ""
    property bool isRemoteMessage: chatMessage? chatMessage.core.isRemoteMessage : false
    property bool isFromChatGroup: chatMessage? chatMessage.core.isFromChatGroup : false
    property var msgState: chatMessage ? chatMessage.core.messageState : LinphoneEnums.ChatMessageState.StateIdle
    hoverEnabled: true
    property bool linkHovered: false
    property real maxWidth: parent?.width || Math.round(300 * DefaultStyle.dp)

    leftPadding: isRemoteMessage ? Math.round(5 * DefaultStyle.dp) : 0

    signal messageDeletionRequested()
	signal isFileHoveringChanged(bool isFileHovering)
    signal showReactionsForMessageRequested()

    background: Item {
        anchors.fill: parent
    }
    
    function handleDefaultMouseEvent(event) {
		if (event.button === Qt.RightButton) {
			optionsMenu.open()
		}
	}

    contentItem: RowLayout {
        spacing: 0
        layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft

        Avatar {
            id: avatar
            visible: mainItem.isFromChatGroup && mainItem.isRemoteMessage
            Layout.preferredWidth: mainItem.isRemoteMessage ? 26 * DefaultStyle.dp : 0
            Layout.preferredHeight: 26 * DefaultStyle.dp
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: isFirstMessage ? 16 * DefaultStyle.dp : 0
            _address: chatMessage ? chatMessage.core.fromAddress : ""
        }
        ColumnLayout  {
            Layout.alignment: Qt.AlignTop
            spacing: 0
            Text {
                id: fromNameText
                Layout.alignment: Qt.AlignTop
                visible: mainItem.isFromChatGroup && mainItem.isRemoteMessage && mainItem.isFirstMessage
                // anchors.top: parent.top
                // anchors.left: parent.left
                // anchors.leftMargin: avatar.width// mainItem.isFromChatGroup ? Math.round(9 * DefaultStyle.dp) : 0
                maximumLineCount: 1
                Layout.leftMargin: mainItem.isFromChatGroup ? Math.round(9 * DefaultStyle.dp) : 0
                width: implicitWidth
                x: mapToItem(this, chatBubble.x, chatBubble.y).x
                text: mainItem.chatMessage.core.fromName
                color: DefaultStyle.main2_500main
                font {
                    pixelSize: Typography.p4.pixelSize
                    weight: Typography.p4.weight
                }
            }
            Item {
                // Layout.topMargin: isFirstMessage ? 16 * DefaultStyle.dp : 0
                Layout.leftMargin: mainItem.isFromChatGroup ? Math.round(9 * DefaultStyle.dp) : 0
                Layout.preferredHeight: childrenRect.height
                Layout.preferredWidth: childrenRect.width
                Control.Control {
                    id: chatBubble
                    spacing: Math.round(2 * DefaultStyle.dp)
                    topPadding: Math.round(12 * DefaultStyle.dp)
                    bottomPadding: Math.round(6 * DefaultStyle.dp)
                    leftPadding: Math.round(12 * DefaultStyle.dp)
                    rightPadding: Math.round(12 * DefaultStyle.dp)
                    width: Math.min(implicitWidth, mainItem.maxWidth - avatar.implicitWidth)

                    MouseArea { // Default mouse area. Each sub bubble can control the mouse and pass on to the main mouse handler. Child bubble mouse area must cover the entire bubble.
                        id: defaultMouseArea
                        // visible: invitationLoader.status !== Loader.Ready // Add other bubbles here that could control the mouse themselves, then add in bubble a signal onMouseEvent
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked:  (mouse) => mainItem.handleDefaultMouseEvent(mouse)
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
                        spacing: Math.round(5 * DefaultStyle.dp)
                        ChatMessageContent {
                            id: chatBubbleContent
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chatMessageGui: mainItem.chatMessage
                            onMouseEvent: (event) => {
                                mainItem.handleDefaultMouseEvent(event)
                            }
                        }
                        RowLayout {
                            Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft : Qt.AlignRight
                            Text {
                                text: UtilsCpp.formatDate(mainItem.chatMessage.core.timestamp, true, false, "dd/MM")
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
                Button {
                    id: reactionsButton
                    visible: reactionList.count > 0
                    anchors.top: chatBubble.bottom
                    Binding {
                        target: reactionsButton
                        when: !mainItem.isRemoteMessage
                        property: "anchors.left"
                        value: chatBubble.left
                    }
                    Binding {
                        target: reactionsButton
                        when: mainItem.isRemoteMessage
                        property: "anchors.right"
                        value: chatBubble.right
                    }
                    onClicked: mainItem.showReactionsForMessageRequested()
                    anchors.topMargin: Math.round(-6 * DefaultStyle.dp)
                    topPadding: Math.round(8 * DefaultStyle.dp)
                    bottomPadding: Math.round(8 * DefaultStyle.dp)
                    leftPadding: Math.round(8 * DefaultStyle.dp)
                    rightPadding: Math.round(8 * DefaultStyle.dp)
                    background: Rectangle {
                        color: DefaultStyle.grey_100
                        border.color: DefaultStyle.grey_0
                        border.width: Math.round(2 * DefaultStyle.dp)
                        radius: Math.round(20 * DefaultStyle.dp)
                    }
                    contentItem: RowLayout {
                        spacing: Math.round(6 * DefaultStyle.dp)
                        Repeater {
                            id: reactionList
                            model: mainItem.chatMessage ? mainItem.chatMessage.core.reactionsSingleton : []
                            delegate: RowLayout {
                                spacing: Math.round(3 * DefaultStyle.dp)
                                Text {
                                    text: UtilsCpp.encodeEmojiToQmlRichFormat(modelData.body)
                                    textFormat: Text.RichText
                                    font {
                                        pixelSize: Math.round(15 * DefaultStyle.dp)
                                        weight: Math.round(400 * DefaultStyle.dp)
                                    }
                                }
                                Text {
                                    visible: modelData.count > 1
                                    text: modelData.count
                                    verticalAlignment: Text.AlignBottom
                                    font {
                                        pixelSize: Typography.p4.pixelSize
                                        weight: Typography.p4.weight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        RowLayout {
            id: actionsLayout
            visible: mainItem.hovered || optionsMenu.hovered || optionsMenu.popup.opened || emojiButton.hovered || emojiButton.popup.opened
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
                        text: chatBubbleContent.selectedText != ""
                            //: "Copy selection"
                            ? qsTr("chat_message_copy_selection")
                            //: "Copy"
                            : qsTr("chat_message_copy")
                        icon.source: AppIcons.copy
                        // spacing: Math.round(10 * DefaultStyle.dp)
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45 * DefaultStyle.dp
                        onClicked: {
                            var success = UtilsCpp.copyToClipboard(chatBubbleContent.selectedText != "" ? chatBubbleContent.selectedText : mainItem.chatMessage.core.text)
                            //: Copied
                            if (success) UtilsCpp.showInformationPopup(qsTr("chat_message_copied_to_clipboard_title"),
                                            //: "to clipboard"
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
                    // Rectangle {
                    //     Layout.fillWidth: true
                    //     Layout.preferredHeight: Math.round(1 * DefaultStyle.dp)
                    //     color: DefaultStyle.main2_200
                    // }
                }
            }
            PopupButton {
                id: emojiButton
                style: ButtonStyle.noBackground
                icon.source: AppIcons.smiley
                popup.contentItem: RowLayout {
                    Repeater {
                        model: ConstantsCpp.reactionsList
                        delegate: Button {
                            text: UtilsCpp.encodeEmojiToQmlRichFormat(modelData)
                            background: Rectangle {
                                anchors.fill: parent
                                color: DefaultStyle.grey_200
                                radius: parent.width * 4
                                visible: mainItem.ownReaction === modelData
                            }
                            onClicked: {
                                if(modelData) {
                                    if (mainItem.ownReaction === modelData) mainItem.chatMessage.core.lRemoveReaction()
                                    else mainItem.chatMessage.core.lSendReaction(modelData)
                                }
                                emojiButton.close()
                            }
                        }
                    }
                    PopupButton {
                        id: emojiPickerButton
                        icon.source: AppIcons.plusCircle
                        popup.width: Math.round(393 * DefaultStyle.dp)
                        popup.height: Math.round(291 * DefaultStyle.dp)
                        popup.contentItem: EmojiPicker {
                            id: emojiPicker
                            onEmojiClicked: (emoji) => {
                                if (mainItem.chatMessage) {
                                    if (mainItem.ownReaction === emoji) mainItem.chatMessage.core.lRemoveReaction()
                                        else mainItem.chatMessage.core.lSendReaction(emoji)
                                }
                                emojiPickerButton.close()
                                emojiButton.close()
                            }
                        }
                    }
                }
            }
        }
        Item{Layout.fillWidth: true}
    }
}
