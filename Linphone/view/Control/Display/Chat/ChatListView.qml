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
    property real busyIndicatorSize: Math.round(60 * DefaultStyle.dp)

    property ChatGui currentChatGui
    onCurrentIndexChanged: currentChatGui = model.getAt(currentIndex) || null

    signal resultsReceived

    onResultsReceived: {
        loading = false
        // contentY = 0
    }

    model: ChatProxy {
        id: chatProxy
        Component.onCompleted: {
            loading = true
        }
        filterText: mainItem.searchText
        onFilterTextChanged: maxDisplayItems = initialDisplayItems
        initialDisplayItems: Math.max(
                                20,
                                2 * mainItem.height / (Math.round(56 * DefaultStyle.dp)))
        displayItemsStep: 3 * initialDisplayItems / 2
        onModelReset: {
            mainItem.resultsReceived()
        }
        onChatRemoved: {
            var indexToSelect = mainItem.currentIndex
            mainItem.currentIndex = -1
            mainItem.currentIndex = indexToSelect
        }
        onLayoutChanged: {
            var chatToSelect = getAt(mainItem.currentIndex)
            selectChat(mainItem.currentChatGui)
        }
    }
    // flickDeceleration: 10000
    spacing: Math.round(10 * DefaultStyle.dp)

    function selectChat(chatGui) {
        var index = chatProxy.findChatIndex(chatGui)
        mainItem.currentIndex = index
        // if the chat exists, it may not be displayed
        // in list if hide_empty_chatrooms is set. Thus, we need
        // to force adding it in the list so it is displayed
        if (index === -1 && chatGui) {
            chatProxy.addChatInList(chatGui)
            var index = chatProxy.findChatIndex(chatGui)
            mainItem.currentIndex = index
        }
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
        width: Math.round(14 * DefaultStyle.dp)
        height: Math.round(14 * DefaultStyle.dp)
        visible: unread > 0
        Rectangle {
            id: background
            anchors.fill: parent
            radius: width/2
            color: DefaultStyle.danger_500main
            Text{
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: DefaultStyle.grey_0
                fontSizeMode: Text.Fit
                font.pixelSize: Math.round(10 * DefaultStyle.dp)
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
        width: mainItem.width
        height: Math.round(63 * DefaultStyle.dp)
        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: Math.round(11 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(11 * DefaultStyle.dp)
            anchors.topMargin: Math.round(9 * DefaultStyle.dp)
            anchors.bottomMargin: Math.round(9 * DefaultStyle.dp)
            spacing: Math.round(10 * DefaultStyle.dp)
            Avatar {
                id: historyAvatar
                property var contactObj: UtilsCpp.findFriendByAddress(modelData.core.peerAddress)
                contact: contactObj?.value || null
                displayNameVal: contact ? "" : modelData.core.avatarUri
                // secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                // isConference: modelData.core.isConference
                shadowEnabled: false
                asynchronous: false
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Math.round(5 * DefaultStyle.dp)
                Text {
                    id: friendAddress
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    text: modelData.core.title
                    color: DefaultStyle.main2_800
                    font {
                        pixelSize: Typography.p1.pixelSize
                        weight: unreadCount.unread > 0 ? Typography.p2.weight : Typography.p1.weight
                        capitalization: Font.Capitalize
                    }
                }
                Text {
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    text: modelData.core.lastMessageText
                    color: DefaultStyle.main2_400
                    font {
                        pixelSize: Typography.p1.pixelSize
                        weight: unreadCount.unread > 0 ? Typography.p2.weight : Typography.p1.weight
                    }
                }
                
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignRight
                RowLayout {
                    Item{Layout.fillWidth: true}
                    Text {
                        color: DefaultStyle.main2_500main
                        text: UtilsCpp.formatDate(modelData.core.lastUpdatedTime, true, false)
                        font {
                            pixelSize: Typography.p3.pixelSize
                            weight: Typography.p3.weight
                            capitalization: Font.Capitalize
                        }
                    }
                }

                RowLayout {
                    spacing: Math.round(10 * DefaultStyle.dp)
                    Item {Layout.fillWidth: true}
                    //sourdine, éphémère
                    UnreadNotification {
                        id: unreadCount
                        unread: modelData.core.unreadMessagesCount
                    }
                    EffectImage {
                        visible: modelData?.core.lastMessage && modelData?.core.lastMessageState !== LinphoneEnums.ChatMessageState.StateIdle
                        && !modelData.core.lastMessage.core.isRemoteMessage
                        Layout.preferredWidth: visible ? 14 * DefaultStyle.dp : 0
                        Layout.preferredHeight: 14 * DefaultStyle.dp
                        colorizationColor: DefaultStyle.main1_500_main
                        imageSource: modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDelivered
                            ? AppIcons.envelope
                            : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDeliveredToUser
                                ? AppIcons.check
                                : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateNotDelivered
                                    ? AppIcons.warningCircle
                                    : modelData.core.lastMessageState === LinphoneEnums.ChatMessageState.StateDisplayed
                                        ? AppIcons.checks
                                        : ""
                    }
                }
            }
            PopupButton {
                id: chatroomPopup
                // z: 1
                popup.x: 0
                popup.padding: Math.round(10 * DefaultStyle.dp)
                visible: mouseArea.containsMouse || hovered || popup.opened
                enabled: visible
                popup.contentItem: ColumnLayout {
                    IconLabelButton {
                        //: "Supprimer"
                        text: qsTr("chat_room_delete")
                        icon.source: AppIcons.trashCan
                        spacing: Math.round(10 * DefaultStyle.dp)
                        Layout.fillWidth: true
                        onClicked: {
                            //: Delete the chat ?
                            mainWindow.showConfirmationLambdaPopup(qsTr("chat_list_delete_chat_popup_title"),
                                                                   //: This chat and all its messages will be deleted. Do You want to continue ?
                                qsTr("chat_list_delete_chat_popup_message"),
                                "",
                                function(confirmed) {
                                    if (confirmed) {
                                        modelData.core.lDelete()
                                        chatroomPopup.close()
                                    }
                                })
                        }
                        style: ButtonStyle.noBackgroundRed
                    }
                }
            }

        }
        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            focus: true
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
                radius: Math.round(8 * DefaultStyle.dp)
                color: mainItem.currentIndex === index ? DefaultStyle.main2_200 : DefaultStyle.main2_100
                visible: mainItem.lastMouseContainsIndex === index || mainItem.currentIndex === index
            }
            onPressed: {
                if (pressedButtons & Qt.RightButton) {
                    chatroomPopup.open()
                } else {
                    mainItem.currentIndex = model.index
                    mainItem.forceActiveFocus()
                }
            }
        }
    }
}
