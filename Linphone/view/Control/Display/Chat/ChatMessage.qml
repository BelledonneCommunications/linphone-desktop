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
    property ChatGui chat
    property string searchedTextPart
    property string ownReaction: chatMessage? chatMessage.core.ownReaction : ""
    property string fromAddress: chatMessage? chatMessage.core.fromAddress : ""
    property bool isRemoteMessage: chatMessage? chatMessage.core.isRemoteMessage : false
    property bool isFromChatGroup: chatMessage? chatMessage.core.isFromChatGroup : false
    property bool isReply: chatMessage? chatMessage.core.isReply : false
    property bool isForward: chatMessage? chatMessage.core.isForward : false
    property string replyText: chatMessage? chatMessage.core.replyText : false
    property var msgState: chatMessage ? chatMessage.core.messageState : LinphoneEnums.ChatMessageState.StateIdle
    hoverEnabled: true
    property bool linkHovered: false
    property real maxWidth: parent ? parent.width : Utils.getSizeWithScreenRatio(300)

    leftPadding: isRemoteMessage ? Utils.getSizeWithScreenRatio(5) : 0

    signal messageDeletionRequested()
	signal isFileHoveringChanged(bool isFileHovering)
    signal showReactionsForMessageRequested()
    signal showImdnStatusForMessageRequested()
    signal replyToMessageRequested()
    signal forwardMessageRequested()
    signal endOfVoiceRecordingReached()
    signal requestAutoPlayVoiceRecording()
    onRequestAutoPlayVoiceRecording: chatBubbleContent.requestAutoPlayVoiceRecording()

    Timer {
        id: hightlightTimer
        interval: 1000
        repeat: false
        onTriggered: highlightRectangle.opacity = 0
    }
    function requestHighlight() {
        highlightRectangle.opacity = 0.8
        hightlightTimer.start()
    }

    background: Item {
        anchors.fill: parent
    }
    
    function handleDefaultMouseEvent(event) {
		if (event.button === Qt.RightButton) {
			optionsMenu.open()
		}
	}

    contentItem: ColumnLayout {
        spacing: Utils.getSizeWithScreenRatio(5)
        Text {
            id: fromNameText
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: mainItem.isFromChatGroup ? Utils.getSizeWithScreenRatio(9) + avatar.width : 0
            visible: mainItem.isFromChatGroup && mainItem.isRemoteMessage && mainItem.isFirstMessage && !replyLayout.visible
            maximumLineCount: 1
            width: implicitWidth
            x: mapToItem(this, chatBubble.x, chatBubble.y).x
            text: mainItem.chatMessage.core.fromName
            color: DefaultStyle.main2_500_main
            font {
                pixelSize: Typography.p4.pixelSize
                weight: Typography.p4.weight
            }
        }
        RowLayout {
            id: forwardLayout
            spacing: Utils.getSizeWithScreenRatio(8)
            visible: mainItem.isForward
            Layout.leftMargin: mainItem.isFromChatGroup ? Utils.getSizeWithScreenRatio(9) + avatar.width : 0
            Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft: Qt.AlignRight
            EffectImage {
                imageSource: AppIcons.forward
                colorizationColor: DefaultStyle.main2_500_main
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(12)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(12)
            }
            Text {
                //: Forwarded
                text: qsTr("chat_message_forwarded")
                color: DefaultStyle.main2_600
                font {
                    pixelSize: Typography.p4.pixelSize
                    weight: Typography.p4.weight
                }
            }
        }
        RowLayout {
            id: replyLayout
            visible: mainItem.isReply
            Layout.leftMargin: mainItem.isFromChatGroup ? Utils.getSizeWithScreenRatio(9) + avatar.width : 0
            layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft
            ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(5)
                RowLayout {
                    id: replyLabel
                    spacing: Utils.getSizeWithScreenRatio(8)
                    Layout.fillWidth: false
                    Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft : Qt.AlignRight
                    EffectImage {
                        imageSource: AppIcons.reply
                        colorizationColor: DefaultStyle.main2_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(12)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(12)
                    }
                    Text {
                        Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft: Qt.AlignRight
                        text: mainItem.isRemoteMessage 
                            ? mainItem.chatMessage.core.repliedToName !== "" 
                                //: %1 replied to %2
                                ? qsTr("chat_message_remote_replied_to").arg(mainItem.chatMessage.core.fromName).arg(mainItem.chatMessage.core.repliedToName)
                                //: %1 replied
                                : qsTr("chat_message_remote_replied").arg(mainItem.chatMessage.core.fromName)
                            : mainItem.chatMessage.core.repliedToName !== "" 
                                //: You replied to %1
                                ? qsTr("chat_message_user_replied_to").arg(mainItem.chatMessage.core.repliedToName)
                                //: You replied
                                : qsTr("chat_message_user_replied")
                        color: DefaultStyle.main2_600
                        font {
                            pixelSize: Typography.p4.pixelSize
                            weight: Typography.p4.weight
                        }
                    }
                }
                Control.Control {
                    id: replyMessage
                    visible: mainItem.replyText !== ""
                    Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft : Qt.AlignRight
                    spacing: Utils.getSizeWithScreenRatio(5)
                    topPadding: Utils.getSizeWithScreenRatio(12)
                    bottomPadding: Utils.getSizeWithScreenRatio(19)
                    leftPadding: Utils.getSizeWithScreenRatio(18)
                    rightPadding: Utils.getSizeWithScreenRatio(18)
                    Layout.preferredWidth: Math.min(implicitWidth, mainItem.maxWidth - avatar.implicitWidth)
                    background: Rectangle {
                        anchors.fill: parent
                        color: DefaultStyle.grey_200
                        radius: Utils.getSizeWithScreenRatio(16)
                    }
                    contentItem: Text {
                        Layout.fillWidth: true
                        text: mainItem.replyText
                        color: DefaultStyle.main2_800
                        font {
                            pixelSize: Typography.p1.pixelSize
                            weight: Typography.p1.weight
                        }
                    }
                }
            }
            Item{Layout.fillWidth: true}
        }
        RowLayout {
            id: bubbleLayout
            z: replyLayout.z + 1
            spacing: 0
            layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft
            Layout.topMargin: replyMessage.visible ? Utils.getSizeWithScreenRatio(-20) : 0

            Avatar {
                id: avatar
                visible: mainItem.isFromChatGroup && mainItem.isRemoteMessage
                Layout.preferredWidth: mainItem.isRemoteMessage ? 26 : 0
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignTop
                _address: chatMessage ? chatMessage.core.fromAddress : ""
            }
            Item {
                id: bubbleContainer
                // Layout.topMargin: isFirstMessage ? 16 : 0
                Layout.leftMargin: mainItem.isFromChatGroup ? Utils.getSizeWithScreenRatio(9) : 0
                Layout.preferredHeight: childrenRect.height
                Layout.preferredWidth: childrenRect.width

                Control.Control {
                    id: chatBubble
                    spacing: Utils.getSizeWithScreenRatio(2)
                    topPadding: Utils.getSizeWithScreenRatio(12)
                    bottomPadding: Utils.getSizeWithScreenRatio(6)
                    leftPadding: Utils.getSizeWithScreenRatio(18)
                    rightPadding: Utils.getSizeWithScreenRatio(18)
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
                            radius: Utils.getSizeWithScreenRatio(16)
                        }
                        Rectangle {
                            visible: mainItem.isFirstMessage && mainItem.isRemoteMessage
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: Utils.getSizeWithScreenRatio(parent.width / 4)
                            height: Utils.getSizeWithScreenRatio(parent.height / 4)
                            color: mainItem.backgroundColor
                        }
                        Rectangle {
                            visible: mainItem.isFirstMessage && !mainItem.isRemoteMessage
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            width: Utils.getSizeWithScreenRatio(parent.width / 4)
                            height: Utils.getSizeWithScreenRatio(parent.height / 4)
                            color: mainItem.backgroundColor
                        }
                        Rectangle {
                            id: highlightRectangle
                            anchors.fill: parent
                            radius: Utils.getSizeWithScreenRatio(16)
                            color: Qt.lighter(mainItem.backgroundColor, 2)
                            border.color: mainItem.backgroundColor
                            border.width: Utils.getSizeWithScreenRatio(2)
                            opacity: 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                    contentItem: ColumnLayout {
                        spacing: Utils.getSizeWithScreenRatio(5)
                        ChatMessageContent {
                            id: chatBubbleContent
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chatGui: mainItem.chat
                            searchedTextPart: mainItem.searchedTextPart
                            chatMessageGui: mainItem.chatMessage
                            maxWidth: mainItem.maxWidth
                            onMouseEvent: (event) => {
                                mainItem.handleDefaultMouseEvent(event)
                            }
                            onEndOfVoiceRecordingReached: mainItem.endOfVoiceRecordingReached()
                        }
                        RowLayout {
                            Layout.preferredHeight: childrenRect.height
                            Layout.alignment: mainItem.isRemoteMessage ? Qt.AlignLeft : Qt.AlignRight
                            layoutDirection: mainItem.isRemoteMessage ? Qt.RightToLeft : Qt.LeftToRight
                            spacing: Utils.getSizeWithScreenRatio(7)
                            RowLayout {
                                spacing: Utils.getSizeWithScreenRatio(3)
                                Layout.preferredHeight: childrenRect.height
                                Text {
                                    id: ephemeralTime
                                    visible: mainItem.chatMessage.core.isEphemeral
                                    color: DefaultStyle.main2_500_main
                                    text: UtilsCpp.formatDuration(mainItem.chatMessage.core.ephemeralDuration * 1000)
                                    font {
                                        pixelSize: Typography.p3.pixelSize
                                        weight: Typography.p3.weight
                                    }
                                }
                                EffectImage {
                                    visible: mainItem.chatMessage.core.isEphemeral
                                    imageSource: AppIcons.clockCountDown
                                    colorizationColor: DefaultStyle.main2_500_main
                                    Layout.preferredWidth: visible ? 14 : 0
                                    Layout.preferredHeight: visible ? 14 : 0
                                }
                            }
                            RowLayout {
                                spacing: mainItem.isRemoteMessage ? 0 : Utils.getSizeWithScreenRatio(5)
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredHeight: childrenRect.height
                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: UtilsCpp.formatDate(mainItem.chatMessage.core.timestamp, true, false, "dd/MM")
                                    color: DefaultStyle.main2_500_main
                                    font {
                                        pixelSize: Typography.p3.pixelSize
                                        weight: Typography.p3.weight
                                    }
                                }
                                EffectImage {
                                    // Imdn status icon
                                    visible: !mainItem.isRemoteMessage
                                    Layout.preferredWidth: visible ? 14 : 0
                                    Layout.preferredHeight: visible ? 14 : 0
                                    Layout.alignment: Qt.AlignVCenter
                                    colorizationColor: DefaultStyle.main1_500_main
                                    imageSource: mainItem.msgState === LinphoneEnums.ChatMessageState.StateDelivered
                                        ? AppIcons.envelope
                                        : mainItem.msgState === LinphoneEnums.ChatMessageState.StateDeliveredToUser
                                            ? AppIcons.check
                                            : mainItem.msgState === LinphoneEnums.ChatMessageState.StateNotDelivered
                                                ? AppIcons.warningCircle
                                                : mainItem.msgState === LinphoneEnums.ChatMessageState.StateDisplayed
                                                    ? AppIcons.checks
                                                    : mainItem.msgState === LinphoneEnums.ChatMessageState.StatePendingDelivery
                                                        ? AppIcons.hourglass
                                                        : ""
                                    BusyIndicator {
                                        anchors.fill: parent
                                        Layout.preferredWidth: visible ? 14 : 0
                                        Layout.preferredHeight: visible ? 14 : 0
                                        visible: mainItem.msgState === LinphoneEnums.ChatMessageState.StateIdle
                                            || mainItem.msgState === LinphoneEnums.ChatMessageState.StateInProgress
                                            || mainItem.msgState === LinphoneEnums.ChatMessageState.StateFileTransferInProgress
                                    }
                                }
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
                    anchors.topMargin: Utils.getSizeWithScreenRatio(-6)
                    topPadding: Utils.getSizeWithScreenRatio(8)
                    bottomPadding: Utils.getSizeWithScreenRatio(8)
                    leftPadding: Utils.getSizeWithScreenRatio(8)
                    rightPadding: Utils.getSizeWithScreenRatio(8)
                    background: Rectangle {
                        color: DefaultStyle.grey_100
                        border.color: DefaultStyle.grey_0
                        border.width: Utils.getSizeWithScreenRatio(2)
                        radius: Utils.getSizeWithScreenRatio(20)
                    }
                    contentItem: RowLayout {
                        spacing: Utils.getSizeWithScreenRatio(6)
                        Repeater {
                            id: reactionList
                            model: mainItem.chatMessage ? mainItem.chatMessage.core.reactionsSingleton : []
                            delegate: RowLayout {
                                spacing: Utils.getSizeWithScreenRatio(3)
                                Text {
                                    text: UtilsCpp.encodeEmojiToQmlRichFormat(modelData.body)
                                    textFormat: Text.RichText
                                    font {
                                        pixelSize: Utils.getSizeWithScreenRatio(15)
                                        weight: Utils.getSizeWithScreenRatio(400)
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
            RowLayout {
                id: actionsLayout
                visible: mainItem.hovered || optionsMenu.hovered || optionsMenu.popup.opened || emojiButton.hovered || emojiButton.popup.opened
                Layout.leftMargin: Utils.getSizeWithScreenRatio(8)
                Layout.rightMargin: Utils.getSizeWithScreenRatio(8)
                Layout.alignment: Qt.AlignVCenter
                // Layout.fillWidth: true
                spacing: Utils.getSizeWithScreenRatio(7)
                layoutDirection: mainItem.isRemoteMessage ? Qt.LeftToRight : Qt.RightToLeft
                PopupButton {
                    id: optionsMenu
                    popup.padding: 0
                    popup.contentItem: ColumnLayout {
                        spacing: 0
                        IconLabelButton {
                            visible: mainItem.msgStatev === LinphoneEnums.ChatMessageState.StateNotDelivered
                            inverseLayout: true
                            //: "Re-send"
                            text: qsTr("chat_message_send_again")
                            icon.source: AppIcons.chatTeardropText
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                mainItem.chatMessage.lSend()
                            }
                        }
                        IconLabelButton {
                            inverseLayout: true
                            //: "Reception info"
                            text: qsTr("chat_message_reception_info")
                            icon.source: AppIcons.chatTeardropText
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                mainItem.showImdnStatusForMessageRequested()
                                optionsMenu.close()
                            }
                        }
                        IconLabelButton {
                            inverseLayout: true
                            //: Reply
                            text: qsTr("chat_message_reply")
                            icon.source: AppIcons.reply
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                mainItem.replyToMessageRequested()
                                optionsMenu.close()
                            }
                        }
                        IconLabelButton {
                            inverseLayout: true
                            text: chatBubbleContent.selectedText != ""
                                //: "Copy selection"
                                ? qsTr("chat_message_copy_selection")
                                //: "Copy"
                                : qsTr("chat_message_copy")
                            icon.source: AppIcons.copy
                            // spacing: Utils.getSizeWithScreenRatio(10)
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                var success = UtilsCpp.copyToClipboard(chatBubbleContent.selectedText != "" ? chatBubbleContent.selectedText : mainItem.chatMessage.core.text)
                                //: Copied
                                if (success) UtilsCpp.showInformationPopup(qsTr("chat_message_copied_to_clipboard_title"),
                                                //: "to clipboard"
                                                qsTr("chat_message_copied_to_clipboard_toast"))
                                optionsMenu.close()
                            }
                        }
                        IconLabelButton {
                            inverseLayout: true
                            //: Forward
                            text: qsTr("chat_message_forward")
                            icon.source: AppIcons.forward
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                mainItem.forwardMessageRequested()
                                optionsMenu.close()
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                            color: DefaultStyle.main2_400
                        }
                        IconLabelButton {
                            inverseLayout: true
                            //: "Delete"
                            text: qsTr("chat_message_delete")
                            icon.source: AppIcons.trashCan
                            // spacing: Utils.getSizeWithScreenRatio(10)
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                            onClicked: {
                                mainItem.messageDeletionRequested()
                                optionsMenu.close()
                            }
                            style: ButtonStyle.hoveredBackgroundRed
                        }
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
                                textFormat: Text.RichText
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
                            popup.width: Utils.getSizeWithScreenRatio(393)
                            popup.height: Utils.getSizeWithScreenRatio(291)
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
}
