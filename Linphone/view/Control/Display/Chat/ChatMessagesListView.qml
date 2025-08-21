import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Qt.labs.qmlmodels
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ListView {
    id: mainItem
    spacing: Math.round(4 * DefaultStyle.dp)
    property ChatGui chat
    property color backgroundColor
    property bool lastItemVisible: false
    property int lastIndexFoundWithFilter: -1
    property real busyIndicatorSize: Math.round(60 * DefaultStyle.dp)
    property bool loading: false

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
        eventLogProxy.findIndexCorrespondingToFilter(currentIndex, forward, false)
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            var index = eventLogProxy.findFirstUnreadIndex()
            positionViewAtIndex(index, ListView.Beginning)
            eventLogProxy.markIndexAsRead(index)
        })
    }
    
    onChatChanged: {
        lastItemVisible = false
        forceActiveFocus()
    }

    Button {
        visible: !mainItem.lastItemVisible
        icon.source: AppIcons.downArrow
        leftPadding: Math.round(16 * DefaultStyle.dp)
        rightPadding: Math.round(16 * DefaultStyle.dp)
        topPadding: Math.round(16 * DefaultStyle.dp)
        bottomPadding: Math.round(16 * DefaultStyle.dp)
        anchors.bottom: parent.bottom
        style: ButtonStyle.main
        anchors.right: parent.right
        anchors.bottomMargin: Math.round(18 * DefaultStyle.dp)
        anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
        onClicked: {
            var index = eventLogProxy.findFirstUnreadIndex()
            mainItem.positionViewAtIndex(index, ListView.Beginning)
            eventLogProxy.markIndexAsRead(index)
        }
    }

    onAtYEndChanged: if (atYEnd && chat) {
        chat.core.lMarkAsRead()
    }
    onAtYBeginningChanged: if (atYBeginning) {
        if (eventLogProxy.haveMore)
            eventLogProxy.displayMore()
    }

    model: EventLogProxy {
        id: eventLogProxy
        chatGui: mainItem.chat
        filterText: mainItem.filterText
        initialDisplayItems: 10
        onEventInserted: (index, gui) => {
            if (!mainItem.visible) return
            if(mainItem.lastItemVisible) {
                mainItem.positionViewAtIndex(index, ListView.Beginning)
                markIndexAsRead(index)
            }
        }
        Component.onCompleted: loading = true
        onListAboutToBeReset: loading = true
        onModelReset: Qt.callLater(function() {
            loading = false
            var index = eventLogProxy.findFirstUnreadIndex()
            positionViewAtIndex(index, ListView.Beginning)
            eventLogProxy.markIndexAsRead(index)
        })
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
        visible: mainItem.chat && mainItem.chat.core.isEncrypted && !eventLogProxy.haveMore
        height: visible ? headerMessage.height + headerMessage.topMargin + headerMessage.bottomMargin : Math.round(30 * DefaultStyle.dp)
        width: headerMessage.width
        anchors.horizontalCenter: parent.horizontalCenter
        Control.Control {
            id: headerMessage
            property int topMargin: mainItem.contentHeight > mainItem.height ? Math.round(30 * DefaultStyle.dp) : Math.round(50 * DefaultStyle.dp)
            property int bottomMargin: Math.round(30 * DefaultStyle.dp)
            anchors.topMargin: topMargin
            anchors.bottomMargin: bottomMargin
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
    footerPositioning: ListView.PullBackFooter
    headerPositioning: ListView.OverlayHeader
    header: Control.Control {
        visible: composeLayout.composingName !== "" && composeLayout.composingName !== undefined
        width: mainItem.width
        // height: visible ? contentItem.implicitHeight + topPadding + bottomPadding : 0
        z: mainItem.z + 2
        topPadding: Math.round(5 * DefaultStyle.dp)
        bottomPadding: Math.round(5 * DefaultStyle.dp)
        background: Rectangle {
            anchors.fill: parent
            color: mainItem.backgroundColor
        }
        contentItem: RowLayout {
            id: composeLayout
            property var composingName: mainItem.chat?.core.composingName
            Avatar {
                Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
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
                property int yoff: Math.round(chatMessageDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                chatMessage: modelData.core.chatMessageGui
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                Component.onCompleted: {
                    if (index === 0) mainItem.lastItemVisible = isFullyVisible
                }
                onYChanged: if (index === 0) mainItem.lastItemVisible = isFullyVisible
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
                property int yoff: Math.round(eventDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                property bool showTopMargin: !header.visible && index == 0
                width: mainItem.width
                height: (showTopMargin ? 30 * DefaultStyle.dp : 0) + eventItem.implicitHeight
                Event {
                    id: eventItem
                    anchors.top: parent.top
                    anchors.topMargin: showTopMargin ? 30 : 0 * DefaultStyle.dp
                    width: parent.width
                    eventLogGui: modelData
                }
            }
        }
        
		DelegateChoice {
            roleValue: "ephemeralEvent"
            delegate: Item {
                id: ephemeralEventDelegate
                property int yoff: Math.round(ephemeralEventDelegate.y - mainItem.contentY)
                property bool isFullyVisible: (yoff > mainItem.y && yoff + height < mainItem.y + mainItem.height)
                onIsFullyVisibleChanged: {
                    if (index === 0) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                property bool showTopMargin: !header.visible && index == 0
                width: mainItem.width
                //height: 40 * DefaultStyle.dp
                height: (showTopMargin ? 30 : 0 * DefaultStyle.dp) + ephemeralEventItem.height
                EphemeralEvent {
                    id: ephemeralEventItem
                    anchors.top: parent.top
                    anchors.topMargin: showTopMargin ? 30 : 0 * DefaultStyle.dp
                    eventLogGui: modelData
                }
            }
        }
    }
}
