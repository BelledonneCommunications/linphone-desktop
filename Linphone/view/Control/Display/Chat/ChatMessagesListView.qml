import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Qt.labs.qmlmodels
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
    id: mainItem
    spacing: Utils.getSizeWithScreenRatio(4)
    property ChatGui chat
    property color backgroundColor
    property bool lastItemVisible: false
    property int lastIndexFoundWithFilter: -1
    property real busyIndicatorSize: Utils.getSizeWithScreenRatio(60)
    property bool loading: false
    property bool isEncrypted: chat && chat.core.isEncrypted
    highlightFollowsCurrentItem: false

    verticalLayoutDirection: ListView.BottomToTop
    signal showReactionsForMessageRequested(ChatMessageGui chatMessage)
    signal showImdnStatusForMessageRequested(ChatMessageGui chatMessage)
    signal replyToMessageRequested(ChatMessageGui chatMessage)
    signal forwardMessageRequested(ChatMessageGui chatMessage)
    signal requestHighlight(int indexToHighlight)
    signal requestAutoPlayVoiceRecording(int indexToPlay)
    currentIndex: -1

    property string filterText
    onFilterTextChanged: {
        lastIndexFoundWithFilter = -1
        if (filterText === "") return
        eventLogProxy.filterText = filterText
        var indexVisible = indexAt(contentX, contentY)
        eventLogProxy.findIndexCorrespondingToFilter(indexVisible, true, true)
    }
    signal findIndexWithFilter(bool forward)
    property bool searchForward: true
    onFindIndexWithFilter: (forward) => {
        searchForward = forward
        eventLogProxy.findIndexCorrespondingToFilter(currentIndex, searchForward, false)
    }

    Button {
        visible: !mainItem.lastItemVisible
        icon.source: AppIcons.downArrow
        leftPadding: Utils.getSizeWithScreenRatio(20)
        rightPadding: Utils.getSizeWithScreenRatio(20)
        topPadding: Utils.getSizeWithScreenRatio(20)
        bottomPadding: Utils.getSizeWithScreenRatio(20)
        anchors.bottom: parent.bottom
        style: ButtonStyle.main
        anchors.right: parent.right
        anchors.bottomMargin: Utils.getSizeWithScreenRatio(18)
        anchors.rightMargin: Utils.getSizeWithScreenRatio(18)
        onClicked: {
            var index = eventLogProxy.findFirstUnreadIndex()
            mainItem.positionViewAtIndex(index, ListView.Contain)
            eventLogProxy.markIndexAsRead(index)
        }
        UnreadNotification {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Utils.getSizeWithScreenRatio(-5)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(-5)
            unread: mainItem.chat?.core.unreadMessagesCount || 0
        }
    }

    onAtYBeginningChanged: if (atYBeginning && count !== 0) {
        eventLogProxy.displayMore()
    }
    onAtYEndChanged: if (atYEnd && chat) {
        chat.core.lMarkAsRead()
    }

    model: EventLogProxy {
        id: eventLogProxy
        chatGui: mainItem.chat
        filterText: mainItem.filterText
        initialDisplayItems: 20
        displayItemsStep: 20
        onModelAboutToBeReset: {
            loading = true
        }
        onModelReset: {
            loading = false
            var index = eventLogProxy.findFirstUnreadIndex()
            mainItem.positionViewAtIndex(index, ListView.Contain)
            eventLogProxy.markIndexAsRead(index)
        }
        onEventInsertedByUser: (index) => {
            mainItem.positionViewAtIndex(index, ListView.Beginning)
        }
        onIndexWithFilterFound: (index) => {
            if (index !== -1) {
                currentIndex = index
                mainItem.positionViewAtIndex(index, ListView.Center)
                mainItem.requestHighlight(index)
                mainItem.lastIndexFoundWithFilter = index
            } else {
                if (mainItem.lastIndexFoundWithFilter !== index) {
                    //: Find message
                    UtilsCpp.showInformationPopup(qsTr("popup_info_find_message_title"),
                    mainItem.searchForward 
                        //: Last result reached
                        ? qsTr("info_popup_last_result_message")
                        //: First result reached
                        : qsTr("info_popup_first_result_message"), false)
                    mainItem.positionViewAtIndex(mainItem.lastIndexFoundWithFilter, ListView.Center)
                    mainItem.requestHighlight(mainItem.lastIndexFoundWithFilter)
                }
                else {
                    //: Find message
                    UtilsCpp.showInformationPopup(qsTr("popup_info_find_message_title"),
                    //: No result found
                    qsTr("info_popup_no_result_message"), false)
                }
            }
        }
    }

    footer: Item {
        visible: mainItem.chat && !mainItem.loading
        height: visible ? (headerMessage.height + headerMessage.topMargin + headerMessage.bottomMargin) : Utils.getSizeWithScreenRatio(30)
        width: headerMessage.width
        anchors.horizontalCenter: parent.horizontalCenter
        Control.Control {
            id: headerMessage
            property int topMargin: Utils.getSizeWithScreenRatio(mainItem.contentHeight > mainItem.height ? 30 : 50)
            property int bottomMargin: Utils.getSizeWithScreenRatio(30)
            anchors.topMargin: topMargin
            anchors.bottomMargin: bottomMargin
            anchors.top: parent.top
            padding: Utils.getSizeWithScreenRatio(10)
            background: Rectangle {
                color: "transparent"
                border.color: DefaultStyle.main2_200
                border.width: Utils.getSizeWithScreenRatio(2)
                radius: Utils.getSizeWithScreenRatio(10)
            }
            contentItem: RowLayout {
                EffectImage {
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(23)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(23)
                    imageSource: mainItem.isEncrypted ? AppIcons.lockSimple : AppIcons.lockSimpleOpen
                    colorizationColor: mainItem.isEncrypted ? DefaultStyle.info_500_main : DefaultStyle.warning_700
                }
                ColumnLayout {
                    spacing: Utils.getSizeWithScreenRatio(2)
                    Text {
                        text: mainItem.isEncrypted
                            //: End to end encrypted chat
                            ? qsTr("chat_message_list_encrypted_header_title")
                            //: This conversation is not encrypted !
                            : qsTr("unencrypted_conversation_warning")
                        Layout.fillWidth: true
                        color: mainItem.isEncrypted ? DefaultStyle.info_500_main : DefaultStyle.warning_700
                        font {
                            pixelSize: Typography.p2.pixelSize
                            weight: Typography.p2.weight
                        }
                    }
                    Text {
                        text: mainItem.isEncrypted
                            //: Messages in this conversation are e2e encrypted. \n Only your correspondent can decrypt them.
                            ? qsTr("chat_message_list_encrypted_header_message")
                            //: Messages are not end to end encrypted, \n may sure you don't share any sensitive information !
                            : qsTr("chat_message_list_not_encrypted_header_message")
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
    footerPositioning: mainItem.contentHeight > mainItem.height ? ListView.InlineFooter : ListView.PullBackFooter
    headerPositioning: ListView.OverlayHeader
    header: Control.Control {
        visible: composeLayout.composingName !== "" && composeLayout.composingName !== undefined
        width: mainItem.width
        // height: visible ? contentItem.implicitHeight + topPadding + bottomPadding : 0
        z: mainItem.z + 2
        topPadding: Utils.getSizeWithScreenRatio(5)
        bottomPadding: Utils.getSizeWithScreenRatio(5)
        background: Rectangle {
            anchors.fill: parent
            color: mainItem.backgroundColor
        }
        contentItem: RowLayout {
            id: composeLayout
            property var composingName: mainItem.chat?.core.composingName
            Avatar {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                _address: mainItem.chat?.core.composingAddress
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

    BusyIndicator {
        anchors.horizontalCenter: mainItem.horizontalCenter
        anchors.verticalCenter: mainItem.verticalCenter
        visible: mainItem.loading
        height: visible ? mainItem.busyIndicatorSize : 0
        width: mainItem.busyIndicatorSize
        indicatorHeight: mainItem.busyIndicatorSize
        indicatorWidth: mainItem.busyIndicatorSize
        indicatorColor: DefaultStyle.main1_500_main
    }
    
    delegate: DelegateChooser {
        role: "eventType"
        DelegateChoice {
            roleValue: "chatMessage"
            delegate: ChatMessage {
                id: chatMessageDelegate
                visible: !mainItem.loading
                property int yoff: Math.round(chatMessageDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                chatMessage: modelData.core.chatMessageGui
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                Component.onCompleted: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                chat: mainItem.chat
                searchedTextPart: mainItem.filterText
                maxWidth: Math.round(mainItem.width * (3/4))
                width: mainItem.width
                property var previousIndex: index - 1
                property ChatMessageGui nextChatMessage: index <= 0 
                    ? null 
                    : eventLogProxy.getEventAtIndex(index-1)
                        ? eventLogProxy.getEventAtIndex(index-1).core.chatMessageGui
                        : null
                property var previousFromAddress: eventLogProxy.getEventAtIndex(index+1)?.core.chatMessage?.fromAddress
                backgroundColor: isRemoteMessage ? DefaultStyle.main2_100 : DefaultStyle.main1_100
                isFirstMessage: !previousFromAddress || previousFromAddress !== chatMessage.core.fromAddress
                anchors.right: !isRemoteMessage && parent
                    ? parent.right
                    : undefined

                onMessageDeletionRequested: chatMessage.core.lDelete()
                onShowReactionsForMessageRequested: mainItem.showReactionsForMessageRequested(chatMessage)
                onShowImdnStatusForMessageRequested: mainItem.showImdnStatusForMessageRequested(chatMessage)
                onReplyToMessageRequested: mainItem.replyToMessageRequested(chatMessage)
                onForwardMessageRequested: mainItem.forwardMessageRequested(chatMessage)
                onEndOfVoiceRecordingReached: {
                    if (nextChatMessage && nextChatMessage.core.isVoiceRecording) mainItem.requestAutoPlayVoiceRecording(index - 1)
                }
                Connections {
                    target: mainItem
                    function onRequestHighlight(indexToHighlight) {
                        if (indexToHighlight === index) {
                            requestHighlight()
                        }
                    }
                    function onRequestAutoPlayVoiceRecording(indexToPlay) {
                        if (indexToPlay === index) {
                            chatMessageDelegate.requestAutoPlayVoiceRecording()
                        }
                    }
                }
            }
        }

        DelegateChoice {
            roleValue: "event"
            delegate: Item {
                id: eventDelegate
                visible: !mainItem.loading
                property int yoff: Math.round(eventDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                property bool showTopMargin: !header.visible && index == 0
                width: mainItem.width
                height: (showTopMargin ? Utils.getSizeWithScreenRatio(30) : 0) + eventItem.implicitHeight
                Event {
                    id: eventItem
                    anchors.top: parent.top
                    anchors.topMargin: showTopMargin ? Utils.getSizeWithScreenRatio(30) : 0
                    width: parent.width
                    eventLogGui: modelData
                }
            }
        }
        
		DelegateChoice {
            roleValue: "ephemeralEvent"
            delegate: Item {
                id: ephemeralEventDelegate
                visible: !mainItem.loading
                property int yoff: Math.round(ephemeralEventDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                property bool showTopMargin: !header.visible && index == 0
                width: mainItem.width
                //height: Utils.getSizeWithScreenRatio(40)
                height: (showTopMargin ? Utils.getSizeWithScreenRatio(30) : 0) + ephemeralEventItem.height
                EphemeralEvent {
                    id: ephemeralEventItem
                    anchors.top: parent.top
                    anchors.topMargin: showTopMargin ? Utils.getSizeWithScreenRatio(30) : 0
                    eventLogGui: modelData
                }
            }
        }
    }
}
