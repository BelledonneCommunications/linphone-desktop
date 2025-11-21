import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractMainPage {
    id: mainItem
    //: "Nouvelle conversation"
    noItemButtonText: qsTr("chat_start_title")
    //: "Aucune conversation"
    emptyListText: qsTr("chat_empty_title")
    newItemIconSource: AppIcons.plusCircle

    property AccountProxy accounts: AccountProxy {
        id: accountProxy
        sourceModel: AppCpp.accounts
    }
    property AccountGui account: accountProxy.defaultAccount
    property var state: account && account.core?.registrationState || 0
    property bool isRegistered: account ? account.core?.registrationState
                                          == LinphoneEnums.RegistrationState.Ok : false

    property var selectedChatGui: null
    property string remoteAddress
    onRemoteAddressChanged: console.log("ChatPage : remote address changed :", remoteAddress)
    property var remoteChatObj: UtilsCpp.getChatForAddress(remoteAddress)
    property var remoteChat: remoteChatObj ? remoteChatObj.value : null
    onRemoteChatChanged: {
        if (remoteChat) selectedChatGui = remoteChat
    }

    onSelectedChatGuiChanged: {
        if (selectedChatGui) {
            if (!listStackView.currentItem || listStackView.currentItem.objectName !== "chatListItem") {
                listStackView.popToIndex(0)
                if (listStackView.depth === 0 || listStackView.currentItem.objectName !== "chatListItem") listStackView.push(chatListItem)
            }
        }
        AppCpp.currentChat = visible ? selectedChatGui : null
    }
    onVisibleChanged: {
        AppCpp.currentChat = visible ? selectedChatGui : null
    }

    rightPanelStackView.initialItem: currentChatComp
    // Only play on the visible property of the right panel as there is only one item pushed
    // and the sending TextArea must be instantiated only once, otherwise it looses focus
    // when the chat list order is updated
    rightPanelStackView.visible: false//listStackView.currentItem && listStackView.currentItem.objectName === "chatListItem" && selectedChatGui !== null

    onNoItemButtonPressed: goToNewChat()

    showDefaultItem: listStackView.currentItem
                     && listStackView.currentItem.objectName == "chatListItem"
                     && listStackView.currentItem.listView.count === 0 || false

    function goToNewChat() {
        if (listStackView.currentItem
                && listStackView.currentItem.objectName != "newChatItem")
            listStackView.push(newChatItem)
    }
    signal openChatRequested(ChatGui chat)

    Dialog {
        id: deleteChatPopup
        width: Utils.getSizeWithScreenRatio(637)
        //: Supprimer la conversation ?
        title: qsTr("chat_dialog_delete_chat_title")
        //: "La conversation et tous ses messages seront supprimés."
        text: qsTr("chat_dialog_delete_chat_message")
    }

    leftPanelContent: Control.StackView {
        id: listStackView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Utils.getSizeWithScreenRatio(45)
        clip: true
        initialItem: chatListItem
        focus: true
        onActiveFocusChanged: if (activeFocus) {
            currentItem.forceActiveFocus()
        }
    }

    Component {
        id: chatListItem
        FocusScope {
            objectName: "chatListItem"
            property alias listView: chatListView
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                FlexboxLayout {
                    direction: FlexboxLayout.Row
                    gap: Utils.getSizeWithScreenRatio(16)
                    alignItems: FlexboxLayout.AlignCenter
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(39)
                    Layout.fillHeight: false
                    Text {
                        Layout.fillWidth: true
                        //: "Conversations"
                        text: qsTr("chat_list_title")
                        color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
                    }
                    PopupButton {
                        id: chatListMenu
                        width: Utils.getSizeWithScreenRatio(24)
                        height: Utils.getSizeWithScreenRatio(24)
                        focus: true
                        popup.x: 0
                        KeyNavigation.right: newChatButton
                        KeyNavigation.down: listStackView
                        popup.contentItem: ColumnLayout {
                            IconLabelButton {
                                Layout.fillWidth: true
                                focus: visible
                                //: "mark all as read"
                                text: qsTr("menu_mark_all_as_read")
                                icon.source: AppIcons.checks
                                onClicked: {
                                    chatListView.markAllAsRead()
                                    chatListMenu.close()
                                }
                            }
                        }
                    }
                    Button {
                        id: newChatButton
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.plusCircle
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(28)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
                        icon.width: Utils.getSizeWithScreenRatio(28)
                        icon.height: Utils.getSizeWithScreenRatio(28)
                        KeyNavigation.down: searchBar
                        onClicked: {
                            console.debug("[ChatPage]User: create new chat")
                            mainItem.goToNewChat()
                        }
                    }
                }
                SearchBar {
                    id: searchBar
                    Layout.fillWidth: true
                    Layout.topMargin: Utils.getSizeWithScreenRatio(18)
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(39)
                    //: "Rechercher une conversation"
                    placeholderText: qsTr("chat_search_in_history")
                    visible: chatListView.count !== 0 || text.length !== 0
                    focus: true
                    KeyNavigation.up: newChatButton
                    KeyNavigation.down: chatListView
                    Binding {
                        target: mainItem
                        property: "showDefaultItem"
                        when: searchBar.text.length != 0
                        value: false
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.rightMargin: Utils.getSizeWithScreenRatio(39)
                        Text {
                            visible: chatListView.count === 0 && chatListView.loading === false
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: Utils.getSizeWithScreenRatio(137)
                            //: "Aucun résultat…"
                            text: searchBar.text.length != 0 ? qsTr("list_filter_no_result_found")
                                                                //: "Aucune conversation dans votre historique"
                                                                : qsTr("chat_list_empty_history")
                            font {
                                pixelSize: Typography.h4.pixelSize
                                weight: Typography.h4.weight
                            }
                        }
                        ChatListView {
                            id: chatListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.topMargin: Utils.getSizeWithScreenRatio(39)
                            searchBar: searchBar
                            Control.ScrollBar.vertical: scrollbar

                            onCurrentChatGuiChanged: {
                                mainItem.selectedChatGui = currentChatGui
                            }

                            Connections {
                                target: mainItem
                                function onRemoteChatChanged() {
                                    if (mainItem.remoteChat) chatListView.chatToSelect = mainItem.remoteChat
                                }
                                function onOpenChatRequested(chat) {
                                    chatListView.chatToSelect = chat
                                }
                            }
                        }
                    }
                    ScrollBar {
                        id: scrollbar
                        visible: chatListView.contentHeight > parent.height
                        active: visible
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: Utils.getSizeWithScreenRatio(8)
                        policy: Control.ScrollBar.AsNeeded
                    }
                }
            }
        }
    }

    Component {
        id: newChatItem
        FocusScope {
            objectName: "newChatItem"
            width: parent?.width
            height: parent?.height
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(10)
                    Button {
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.leftArrow
                        focus: true
                        KeyNavigation.down: listStackView
                        onClicked: {
                            console.debug(
                                        "[CallPage]User: return to call history")
                            listStackView.pop()
                            listStackView.forceActiveFocus()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        //: "New chat"
                        text: qsTr("chat_action_start_new_chat")
                        color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2m.pixelSize
                        font.weight: Typography.h2m.weight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                NewChatForm {
                    id: newChatForm
                    startGroupButtonVisible: mainItem.account && mainItem.account.core.conferenceFactoryAddress !== ""
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(8)
                    Layout.topMargin: Utils.getSizeWithScreenRatio(18)
                    onGroupCreationRequested: {
                        console.log("groupe call requested")
                        listStackView.push(groupChatItem)
                    }
                    onContactClicked: (contact) => {
                        if (contact) {
                            mainItem.remoteAddress = ""
                            mainItem.remoteAddress = contact.core.defaultAddress
                        }
                    }
                }
            }
        }
    }

    Component {
        id: groupChatItem
        GroupCreationFormLayout {
            id: chatCreationLayout

            objectName: "groupChatItem"
            //: "Nouveau groupe"
            formTitle: qsTr("chat_start_group_chat_title")
            //: "Créer"
            createGroupButtonText: qsTr("chat_action_start_group_chat")

            property var groupChatObj
            property var groupChat: groupChatObj ? groupChatObj.value : null
            onGroupChatChanged: if (groupChat && groupChat.core.state === LinphoneEnums.ChatRoomState.Created) {
                mainItem.selectedChatGui = groupChat
            }
            Connections {
                enabled: groupChat || false
                target: groupChat?.core || null
                function onChatRoomStateChanged() {
                    if (chatCreationLayout.groupChat.core.state === LinphoneEnums.ChatRoomState.Created) {
                        mainWindow.closeLoadingPopup()
                        mainItem.selectedChatGui = chatCreationLayout.groupChat
                    } else if (chatCreationLayout.groupChat.core.state === LinphoneEnums.ChatRoomState.CreationFailed) {
                        mainWindow.closeLoadingPopup()
                        mainWindow.showInformationPopup(qsTr("information_popup_error_title"),
                                                        //: "La création a échoué"
                                                        qsTr("information_popup_chat_creation_failed_message"), false)
                        chatCreationLayout.groupChat.core.lDelete()
                    }
                }
            }

            Control.StackView.onActivated: {
                addParticipantsLayout.forceActiveFocus()
            }
            onReturnRequested: {
                listStackView.pop()
                listStackView.currentItem?.forceActiveFocus()
            }

            onGroupCreationRequested: {
                var hasError = false
                if (groupName.text.length === 0) {
                    //: "Un nom doit être donné au groupe
                    groupNameItem.errorMessage = qsTr("group_chat_error_must_have_name")
                    hasError = true
                } if (addParticipantsLayout.selectedParticipantsCount === 0) {
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                    //: "Please select at least one participant
                                                    qsTr("group_chat_error_no_participant"), false)
                    hasError = true
                } if (!mainItem.isRegistered) {
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                //: "Vous n'etes pas connecté"
                                qsTr("group_call_error_not_connected"), false)
                    hasError = true
                } 
                if (hasError) return
                console.log("Create group chat")
                //: Creation de la conversation en cours …
                mainWindow.showLoadingPopup(qsTr("chat_creation_in_progress"), true, function () {
                    if (chatCreationLayout.groupChat) chatCreationLayout.groupChat.core.lDelete()
                })
                chatCreationLayout.groupChatObj = UtilsCpp.createGroupChat(chatCreationLayout.groupName.text, addParticipantsLayout.selectedParticipants)
            }
        }
    }

    Component {
        id: emptySelection
        Item {
            objectName: "emptySelection"
        }
    }
    Component {
        id: currentChatComp
        FocusScope {
            BusyIndicator {
                anchors.centerIn: parent
                visible: selectedChatView.chat && !selectedChatView.visible
                indicatorHeight: visible ? Utils.getSizeWithScreenRatio(60) : 0
                indicatorWidth: Utils.getSizeWithScreenRatio(60)
                indicatorColor: DefaultStyle.main1_500_main
            }
            SelectedChatView {
                id: selectedChatView
                visible: chat != undefined //&& (chat.core.isBasic || chat.core.conferenceJoined)
                anchors.fill: parent
                chat: mainItem.selectedChatGui ? mainItem.selectedChatGui : null

                // Reset current chat when switching account, otherwise the binding makes
                // the last chat from last account the current chat for the new default account
                Connections {
                    target: AppCpp
                    function onDefaultAccountChanged() {
                        selectedChatView.chat = null
                    }
                }
                // Binding is destroyed when forward message is done so
                // we need this connection in addition
                Connections {
                    target: mainItem
                    function onSelectedChatGuiChanged() {
                        selectedChatView.chat = mainItem.selectedChatGui ? mainItem.selectedChatGui : null
                    }
                }
                Binding {
                    target: mainItem
                    property: "showDefaultItem"
                    when: selectedChatView.messagesLoading
                    value: false
                }
            }
        }
    }
}
