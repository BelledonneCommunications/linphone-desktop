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
    signal showReactionsForMessageRequested(ChatMessageGui chatMessage)
    signal showImdnStatusForMessageRequested(ChatMessageGui chatMessage)
    signal replyToMessageRequested(ChatMessageGui chatMessage)
    signal forwardMessageRequested(ChatMessageGui chatMessage)
    signal requestHighlight(int indexToHighlight)
    signal requestAutoPlayVoiceRecording(int indexToPlay)

    property string filterText
    onFilterTextChanged: {
        if (filterText === "") return
        eventLogProxy.filterText = filterText
        var indexVisible = indexAt(contentX, contentY)
        var found = eventLogProxy.findIndexCorrespondingToFilter(indexVisible)
        if (found !== -1) {
            currentIndex = found
            positionViewAtIndex(found, ListView.Center)
            requestHighlight(found)
        } else {
            //: Find message
            UtilsCpp.showInformationPopup(qsTr("popup_info_find_message_title"),
            //: No result found
            qsTr("info_popup_no_result_message"), false)
        }
    }
    signal findIndexWithFilter(bool goingBackward)
    onFindIndexWithFilter: (goingBackward) => {
        var nextIndex = eventLogProxy.findIndexCorrespondingToFilter(currentIndex, goingBackward)
        if (nextIndex !== -1 && nextIndex !== currentIndex) {
            currentIndex = nextIndex
            positionViewAtIndex(nextIndex, ListView.Center)
            requestHighlight(nextIndex)
        } else if (currentIndex !== -1) {
            //: Find message
            UtilsCpp.showInformationPopup(qsTr("popup_info_find_message_title"),
            //: First result reached
            goingBackward ? qsTr("info_popup_first_result_message")
            //: Last result reached
            : qsTr("info_popup_last_result_message"), false)
        }
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            var index = eventLogProxy.findFirstUnreadIndex()
            positionViewAtIndex(index, ListView.End)
            eventLogProxy.markIndexAsRead(index)
        })
    }

    onCountChanged: if (atYEnd) {
        positionViewAtEnd()
    }
    onChatChanged: lastItemVisible = false

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
            mainItem.positionViewAtIndex(index, ListView.End)
            eventLogProxy.markIndexAsRead(index)
        }
    }

    onAtYEndChanged: if (atYEnd) {
        if (eventLogProxy.haveMore)
            eventLogProxy.displayMore()
        else chat.core.lMarkAsRead()
    }

    model: EventLogProxy {
        id: eventLogProxy
        chatGui: mainItem.chat
        // scroll when in view and message inserted
        filterText: mainItem.filterText
        onEventInserted: (index, gui) => {
            if (!mainItem.visible) return
            if(mainItem.lastItemVisible) mainItem.positionViewAtIndex(index, ListView.End)
        }
        onModelReset: Qt.callLater(function() {
            var index = eventLogProxy.findFirstUnreadIndex()
            positionViewAtIndex(index, ListView.End)
            eventLogProxy.markIndexAsRead(index)
        })
    }

    header: Item {
        visible: mainItem.chat && mainItem.chat.core.isEncrypted
        height: visible ? headerMessage.height + Math.round(50 * DefaultStyle.dp) : Math.round(30 * DefaultStyle.dp)
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
                    if (index === mainItem.count - 1) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                Component.onCompleted: if (index === mainItem.count - 1) mainItem.lastItemVisible = isFullyVisible
                chat: mainItem.chat
                searchedTextPart: mainItem.filterText
                maxWidth: Math.round(mainItem.width * (3/4))
                width: mainItem.width
                property var previousIndex: index - 1
                property ChatMessageGui nextChatMessage: index >= (mainItem.count - 1) 
                    ? null 
                    : eventLogProxy.getEventAtIndex(index+1)
                        ? eventLogProxy.getEventAtIndex(index+1).core.chatMessageGui
                        : null
                property var previousFromAddress: eventLogProxy.getEventAtIndex(index-1)?.core.chatMessage?.fromAddress
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
                    if (nextChatMessage && nextChatMessage.core.isVoiceRecording) mainItem.requestAutoPlayVoiceRecording(index + 1)
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
                    if (index === mainItem.count - 1) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                }
                property bool showTopMargin: !header.visible && index == 0
                width: mainItem.width
                height: (showTopMargin ? 30 : 0 * DefaultStyle.dp) + eventItem.implicitHeight
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
                    if (index === mainItem.count - 1) {
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
    
    footerPositioning: ListView.OverlayFooter
    footer: Control.Control {
        visible: composeLayout.composingName !== "" && composeLayout.composingName !== undefined
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
}
