import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Qt.labs.qmlmodels
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
    property bool lastItemVisible: false
    signal showReactionsForMessageRequested(ChatMessageGui chatMessage)
    signal showImdnStatusForMessageRequested(ChatMessageGui chatMessage)
    signal replyToMessageRequested(ChatMessageGui chatMessage)
    signal forwardMessageRequested(ChatMessageGui chatMessage)

    Component.onCompleted: {
        Qt.callLater(function() {
            var index = eventLogProxy.findFirstUnreadIndex()
            positionViewAtIndex(index, ListView.End)
        })
    }

    onCountChanged: if (atYEnd) {
        positionViewAtEnd()
    }

    Button {
        visible: !mainItem.lastItemVisible
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
            var index = eventLogProxy.findFirstUnreadIndex()
            mainItem.positionViewAtIndex(index, ListView.End)
        }
    }

    onAtYEndChanged: if (atYEnd) {
        if (eventLogProxy.haveMore)
            eventLogProxy.displayMore()
    }

    model: EventLogProxy {
        id: eventLogProxy
        chatGui: mainItem.chat
        // scroll when in view and message inserted
        onEventInserted: (index, gui) => {
            if (!mainItem.visible) return
            mainItem.positionViewAtIndex(index, ListView.End)
        }
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
                onIsFullyVisibleChanged: {
                    if (index === mainItem.count - 1) {
                        mainItem.lastItemVisible = isFullyVisible
                    }
                    if (isFullyVisible)
                        modelData.core.lMarkAsRead()
                }
                chatMessage: modelData
                chat: mainItem.chat
                maxWidth: Math.round(mainItem.width * (3/4))
                onVisibleChanged: {
                    if (visible) {
                        modelData.core.lMarkAsRead()
                    }
                }
                width: mainItem.width
                property var previousIndex: index - 1
                property var previousFromAddress: eventLogProxy.getEventAtIndex(index-1)?.core.chatMessage?.fromAddress
                backgroundColor: isRemoteMessage ? DefaultStyle.main2_100 : DefaultStyle.main1_100
                isFirstMessage: !previousFromAddress || previousFromAddress !== modelData.core.fromAddress
                anchors.right: !isRemoteMessage && parent
                    ? parent.right
                    : undefined

                onMessageDeletionRequested: modelData.core.lDelete()
                onShowReactionsForMessageRequested: mainItem.showReactionsForMessageRequested(modelData)
                onShowImdnStatusForMessageRequested: mainItem.showImdnStatusForMessageRequested(modelData)
                onReplyToMessageRequested: mainItem.replyToMessageRequested(modelData)
                onForwardMessageRequested: mainItem.forwardMessageRequested(modelData)
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
                height: (showTopMargin ? 30 : 0 * DefaultStyle.dp) + eventItem.height
                EphemeralEvent {
                    id: eventItem
                    anchors.top: parent.top
                    anchors.topMargin: showTopMargin ? 30 : 0 * DefaultStyle.dp
                    eventLogGui: modelData
                }
            }
        }
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
