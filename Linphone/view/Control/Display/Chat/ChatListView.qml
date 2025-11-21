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
    clip: true

    property SearchBar searchBar
    property bool loading: false
    property string searchText: searchBar?.text
    property real busyIndicatorSize: Utils.getSizeWithScreenRatio(60)

    property ChatGui currentChatGui: model.getAt(currentIndex) || null
    onCurrentChatGuiChanged: positionViewAtIndex(currentIndex, ListView.Center)
    property ChatGui chatToSelect: null
    property ChatGui chatToSelectLater: null
    onChatToSelectChanged: {
        var index = chatProxy.findChatIndex(chatToSelect)
        if (index != -1) {
            currentIndex = index
            chatToSelect = null
        }
    }

    onChatClicked: (chat) => {selectChat(chat)}
    
    signal markAllAsRead()
    signal chatClicked(ChatGui chat)

    model: ChatProxy {
        id: chatProxy
        Component.onCompleted: {
            loading = true
        }
        filterText: mainItem.searchText
        onFilterTextChanged: {
            chatToSelectLater = currentChatGui
        }
        initialDisplayItems: Math.max(20, Math.round(2 * mainItem.height / Utils.getSizeWithScreenRatio(56)))
        displayItemsStep: 3 * initialDisplayItems / 2
        onModelAboutToBeReset: {
            loading = true
        }
        onRowsRemoved: {
            var index = mainItem.currentIndex
            mainItem.currentIndex = -1
            mainItem.currentIndex = index
        }
        onLayoutChanged: {
            loading = false
            if (mainItem.chatToSelectLater) {
                selectChat(mainItem.chatToSelectLater)
                mainItem.chatToSelectLater = null
            }
            else if (mainItem.chatToSelect) {
                selectChat(mainItem.chatToSelect)
                mainItem.chatToSelect = null
            }
            else {
                selectChat(mainItem.currentChatGui)
            }
        }
        onChatCreated: (chat) => {
            selectChat(chat)
        }
    }
    // flickDeceleration: 10000
    spacing: Utils.getSizeWithScreenRatio(10)

    function selectChat(chatGui) {
        var index = chatProxy.findChatIndex(chatGui)
        mainItem.currentIndex = index
    }

    Component.onCompleted: cacheBuffer = Math.max(contentHeight, 0) //contentHeight>0 ? contentHeight : 0// cache all items
    // remove binding loop
    onContentHeightChanged: Qt.callLater(function () {
        if (mainItem)
            mainItem.cacheBuffer = Math?.max(contentHeight, 0) || 0
    })

    onActiveFocusChanged: if (activeFocus && currentIndex < 0 && count > 0)
                              currentIndex = 0

    onAtYEndChanged: {
        if (atYEnd && count > 0) {
            chatProxy.displayMore()
        }
    }

//----------------------------------------------------------------
    function moveToCurrentItem() {
        if (mainItem.currentIndex >= 0)
            Utils.updatePosition(mainItem, mainItem)
    }
    onCurrentItemChanged: {
        moveToCurrentItem()
    }
    // Update position only if we are moving to current item and its position is changing.
    property var _currentItemY: currentItem?.y
    on_CurrentItemYChanged: if (_currentItemY && moveAnimation.running) {
        moveToCurrentItem()
    }
    Behavior on contentY {
        NumberAnimation {
            id: moveAnimation
            duration: 500
            easing.type: Easing.OutExpo
            alwaysRunToEnd: true
        }
    }

//    //----------------------------------------------------------------

    BusyIndicator {
        anchors.horizontalCenter: mainItem.horizontalCenter
        visible: mainItem.loading
        height: visible ? mainItem.busyIndicatorSize : 0
        width: mainItem.busyIndicatorSize
        indicatorHeight: mainItem.busyIndicatorSize
        indicatorWidth: mainItem.busyIndicatorSize
        indicatorColor: DefaultStyle.main1_500_main
    }

    // Qt bug: sometimes, containsMouse may not be send and update on each MouseArea.
    // So we need to use this variable to switch off all hovered items.
    property int lastMouseContainsIndex: -1

    component UnreadNotification: Item {
        id: unreadNotif
        property int unread: 0
        width: Utils.getSizeWithScreenRatio(14)
        height: Utils.getSizeWithScreenRatio(14)
        visible: unread > 0
        Rectangle {
            id: background
            anchors.fill: parent
            radius: width/2
            color: DefaultStyle.danger_500_main
            Text{
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: DefaultStyle.grey_0
                fontSizeMode: Text.Fit
                font.pixelSize: Utils.getSizeWithScreenRatio(10)
                text: parent.unreadNotif > 100 ? '99+' : unreadNotif.unread
            }
        }
        MultiEffect {
            id: shadow
            anchors.fill: background
            source: background
            // Crash : https://bugreports.qt.io/browse/QTBUG-124730?
            shadowEnabled: true
            shadowColor: DefaultStyle.grey_1000
            shadowBlur: 1
            shadowOpacity: 0.15
            z: unreadNotif.z - 1
        }
    }

    delegate: FocusScope {
        visible: !mainItem.loading
        width: mainItem.width
        height: Utils.getSizeWithScreenRatio(63)
        Connections {
            target: mainItem
            function onMarkAllAsRead() {modelData.core.lMarkAsRead()}
        }
        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: Utils.getSizeWithScreenRatio(11)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(11)
            anchors.topMargin: Utils.getSizeWithScreenRatio(9)
            anchors.bottomMargin: Utils.getSizeWithScreenRatio(9)
            spacing: Utils.getSizeWithScreenRatio(10)
            Avatar {
                property var contactObj: modelData ? UtilsCpp.findFriendByAddress(modelData.core.peerAddress) : null
                contact: contactObj?.value || null
                displayNameVal: modelData && modelData.core.avatarUri || ""
                secured: modelData?.core.isSecured || false
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                // isConference: modelData.core.isConference
                shadowEnabled: false
                asynchronous: false
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Utils.getSizeWithScreenRatio(5)
                Text {
                    id: friendAddress
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    text: modelData? modelData.core.title : ""
                    color: DefaultStyle.main2_800
                    font {
                        pixelSize: Typography.p1.pixelSize
                        weight: unreadCount.unread > 0 ? Typography.p2.weight : Typography.p1.weight
                    }
                }
                
                RowLayout {
                	spacing: Utils.getSizeWithScreenRatio(5)
					Layout.fillWidth: true
					
					EffectImage {
						visible: modelData != undefined && modelData.core.lastMessage && modelData.core.lastMessage.core.isReply && !remoteComposingInfo.visible
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.reply
                        colorizationColor: DefaultStyle.main2_500
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					}
					
					EffectImage {
						visible: modelData != undefined && modelData.core.lastMessage && modelData.core.lastMessage.core.isForward && !remoteComposingInfo.visible
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.forward
						colorizationColor: DefaultStyle.main2_500
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					}
					
					EffectImage {
						visible: modelData != undefined && modelData.core.lastMessage && modelData.core.lastMessage.core.hasFileContent && !remoteComposingInfo.visible
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.paperclip
						colorizationColor: DefaultStyle.main2_500
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					}
					
					EffectImage {
						visible: modelData != undefined && modelData.core.lastMessage && modelData.core.lastMessage.core.isVoiceRecording && !remoteComposingInfo.visible
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.waveform
						colorizationColor: DefaultStyle.main2_500
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					}
					
					EffectImage {
						visible: modelData != undefined && modelData.core.lastMessage && modelData.core.lastMessage.core.isCalendarInvite && !remoteComposingInfo.visible
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.calendarBlank
						colorizationColor: DefaultStyle.main2_500
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					}
					
					Text {
						id: lastMessageText
						Layout.fillWidth: true
						maximumLineCount: 1
						visible: !remoteComposingInfo.visible
						text: modelData ? modelData.core.lastMessageText : ""
						color: DefaultStyle.main2_400
						font {
							pixelSize: Typography.p1.pixelSize
							weight: unreadCount.unread > 0 ? Typography.p2.weight : Typography.p1.weight
						}
					}
					Text {
						id: remoteComposingInfo
						visible: modelData ? (modelData.core.composingName !== "" || modelData.core.sendingText !== "") : false
						Layout.fillWidth: true
						maximumLineCount: 1
						font {
							pixelSize: Typography.p3.pixelSize
							weight: Typography.p3.weight
                            italic: modelData?.core.sendingText !== ""
						}
						//: %1 is writing…
						text: modelData
                            ? modelData.core.composingName !== ""
                                ? qsTr("chat_message_is_writing_info").arg(modelData.core.composingName)
                                : modelData.core.sendingText !== ""
                                    ? qsTr("chat_message_draft_sending_text").arg(modelData.core.sendingText)
                                    : ""
                            : ""
					}
                }
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignRight
                RowLayout {
                    Item{Layout.fillWidth: true}
                    Text {
                        color: DefaultStyle.main2_500_main
                        text: modelData ? UtilsCpp.formatDate(modelData.core.lastUpdatedTime, true, false) : ""
                        font {
                            pixelSize: Typography.p3.pixelSize
                            weight: Typography.p3.weight
                            capitalization: Font.Capitalize
                        }
                    }
                }

                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(10)
                    Item {Layout.fillWidth: true}
					EffectImage {
						visible: modelData?.core.ephemeralEnabled || false
                        Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(14) : 0
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                        colorizationColor: DefaultStyle.main2_400
                        imageSource: AppIcons.clockCountDown
                    }
					EffectImage {
						visible: modelData != undefined && modelData?.core.isBasic
                        Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(14) : 0
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                        colorizationColor: DefaultStyle.warning_700
                        imageSource: AppIcons.lockSimpleOpen
                    }
                    EffectImage {
						visible: modelData != undefined && modelData?.core.muted
                        Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(14) : 0
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                        colorizationColor: DefaultStyle.main2_400
                        imageSource: AppIcons.bellSlash
                    }
					UnreadNotification {
                        id: unreadCount
                        unread: modelData?.core.unreadMessagesCount || false
                    }
                    EffectImage {
                        visible: modelData?.core.lastMessage && modelData?.core.lastMessageState !== LinphoneEnums.ChatMessageState.StateIdle
                        && !modelData.core.lastMessage.core.isRemoteMessage || false
                        Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(14) : 0
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                        colorizationColor: DefaultStyle.main1_500_main
                        imageSource: modelData
                            ? modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDelivered
                                ? AppIcons.envelope
                                : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDeliveredToUser
                                    ? AppIcons.check
                                    : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateNotDelivered
                                        ? AppIcons.warningCircle
                                        : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDisplayed
                                            ? AppIcons.checks
                                            : ""
                            : ""
                    }
                }
            }
            PopupButton {
                id: chatroomPopup
                // z: 1
                popup.x: 0
                popup.padding: Utils.getSizeWithScreenRatio(10)
                visible: mouseArea.containsMouse || hovered || popup.opened
                enabled: visible
                popup.contentItem: ColumnLayout {
					IconLabelButton {
                        //: "Mute"
                        text: modelData 
                            ? modelData.core.muted 
                                ? qsTr("chat_room_unmute") 
                                : qsTr("chat_room_mute")
                            : ""
						icon.source: modelData ? modelData.core.muted ? AppIcons.bell : AppIcons.bellSlash : ""
                        spacing: Utils.getSizeWithScreenRatio(10)
                        Layout.fillWidth: true
                        onClicked:  {
							modelData.core.muted = !modelData.core.muted
							chatroomPopup.close()
						}
                    }
                    IconLabelButton {
                        visible: modelData && modelData.core.unreadMessagesCount !== 0 || false
                        //: "Mark as read"
                        text: qsTr("chat_room_mark_as_read")
                        icon.source: AppIcons.checks
                        spacing: Utils.getSizeWithScreenRatio(10)
                        Layout.fillWidth: true
                        onClicked: {
                            modelData.core.lMarkAsRead()
                            chatroomPopup.close()
                        }
                    }
                    ColumnLayout {
                        spacing: parent.spacing
                        visible: modelData && !modelData.core.isReadOnly && modelData.core.isGroupChat || false
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                            color: DefaultStyle.main2_400
                        }
                        IconLabelButton {
                            //: "leave"
                            text: qsTr("chat_room_leave")
                            icon.source: AppIcons.trashCan
                            spacing: Utils.getSizeWithScreenRatio(10)
                            Layout.fillWidth: true
                            onClicked: {
                                //: leave the conversation ?
                                mainWindow.showConfirmationLambdaPopup(qsTr("chat_list_leave_chat_popup_title"),
                                    //: You will not be able to send or receive messages in this conversation anymore. Do You want to continue ?
                                    qsTr("chat_list_leave_chat_popup_message"),
                                    "",
                                    function(confirmed) {
                                        if (confirmed) {
                                            modelData.core.lLeave()
                                            chatroomPopup.close()
                                        }
                                    })
                            }
                            style: ButtonStyle.hoveredBackground
                        }
                    }
                    Rectangle {
                        visible: deleteButton.visible
                        Layout.fillWidth: true
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                        color: DefaultStyle.main2_400
                    }
                    IconLabelButton {
                        id: deleteButton
                        //: "Delete"
                        text: qsTr("chat_room_delete")
                        icon.source: AppIcons.trashCan
                        spacing: Utils.getSizeWithScreenRatio(10)
                        Layout.fillWidth: true
                        onClicked: {
                            //: Delete the conversation ?
                            mainWindow.showConfirmationLambdaPopup(qsTr("chat_list_delete_chat_popup_title"),
                                                                   //: This conversation and all its messages will be deleted. Do You want to continue ?
                                qsTr("chat_list_delete_chat_popup_message"),
                                "",
                                function(confirmed) {
                                    if (confirmed) {
                                        modelData.core.lDelete()
                                        chatroomPopup.close()
                                    }
                                })
                        }
                        style: ButtonStyle.hoveredBackgroundRed
                    }
                }
            }

        }
        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            onContainsMouseChanged: {
                if (containsMouse)
                    mainItem.lastMouseContainsIndex = index
                else if (mainItem.lastMouseContainsIndex == index)
                    mainItem.lastMouseContainsIndex = -1
            }
            Rectangle {
                anchors.fill: parent
                opacity: 0.7
                radius: Utils.getSizeWithScreenRatio(8)
                color: mainItem.currentIndex === index ? DefaultStyle.main2_200 : DefaultStyle.main2_100
                visible: mainItem.lastMouseContainsIndex === index || mainItem.currentIndex === index
            }
            onPressed: {
                if (pressedButtons & Qt.RightButton) {
                    chatroomPopup.open()
                } else {
                    mainItem.chatClicked(modelData)
                }
            }
        }
    }
}
