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

    property var selectedChatGui
    property string remoteAddress
    onRemoteAddressChanged: console.log("ChatPage : remote address changed :", remoteAddress)
    property var remoteChatObj: UtilsCpp.getChatForAddress(remoteAddress)
    property var remoteChat: remoteChatObj ? remoteChatObj.value : null
    onRemoteChatChanged: {
        selectedChatGui = remoteChat
    }

    onSelectedChatGuiChanged: {
        if (selectedChatGui) {
            if (!listStackView.currentItem || listStackView.currentItem.objectName !== "chatListItem") {
                listStackView.popToIndex(0)
                if (listStackView.depth === 0 || listStackView.currentItem.objectName !== "chatListItem") listStackView.push(chatListItem)
            }
            rightPanelStackView.replace(currentChatComp,
                                        Control.StackView.Immediate)
        }
        else {
            rightPanelStackView.replace(emptySelection,
                                        Control.StackView.Immediate)
        }
    }

    rightPanelStackView.initialItem: emptySelection
    rightPanelStackView.visible: listStackView.currentItem && listStackView.currentItem.objectName === "chatListItem"

    onNoItemButtonPressed: goToNewChat()

    showDefaultItem: listStackView.currentItem
                     && listStackView.currentItem.objectName == "chatListItem"
                     && listStackView.currentItem.listView.count === 0 || false

    function goToNewChat() {
        if (listStackView.currentItem
                && listStackView.currentItem.objectName != "newChatItem")
            listStackView.push(newChatItem)
    }

    Dialog {
        id: deleteChatPopup
        width: Math.round(637 * DefaultStyle.dp)
        //: Supprimer la conversation ?
        title: qsTr("chat_dialog_delete_chat_title")
        //: "La conversation et tous ses messages seront supprimés."
        text: qsTr("chat_dialog_delete_chat_message")
    }

    leftPanelContent: Control.StackView {
        id: listStackView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Math.round(45 * DefaultStyle.dp)
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
                RowLayout {
                    spacing: Math.round(16 * DefaultStyle.dp)
                    Text {
                        Layout.fillWidth: true
                        //: "Conversations"
                        text: qsTr("chat_list_title")
                        color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PopupButton {
                        id: chatListMenu
                        width: Math.round(24 * DefaultStyle.dp)
                        height: Math.round(24 * DefaultStyle.dp)
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
                        Layout.preferredWidth: Math.round(28 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
                        Layout.rightMargin: Math.round(39 * DefaultStyle.dp)
                        icon.width: Math.round(28 * DefaultStyle.dp)
                        icon.height: Math.round(28 * DefaultStyle.dp)
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
                    Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                    Layout.rightMargin: Math.round(39 * DefaultStyle.dp)
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
                        anchors.rightMargin: Math.round(39 * DefaultStyle.dp)
                        Text {
                            visible: chatListView.count === 0 && chatListView.loading === false
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: Math.round(137 * DefaultStyle.dp)
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
                            Layout.topMargin: Math.round(39 * DefaultStyle.dp)
                            searchBar: searchBar
                            Control.ScrollBar.vertical: scrollbar

                            onCurrentIndexChanged: {
                                mainItem.selectedChatGui = model.getAt(currentIndex)
                            }

                            Connections {
                                target: mainItem
                                onSelectedChatGuiChanged: {
                                    chatListView.selectChat(mainItem.selectedChatGui)
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
                        anchors.rightMargin: Math.round(8 * DefaultStyle.dp)
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
                    spacing: Math.round(10 * DefaultStyle.dp)
                    Button {
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                    onGroupCreationRequested: {
                        console.log("groupe call requetsed")
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
                        mainItem.selectedChatGui = chatCreationLayout.groupChat
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
                if (groupName.text.length === 0) {
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                    //: "Un nom doit être donné au groupe
                                                    qsTr("group_chat_error_must_have_name"), false)
                } else if (!mainItem.isRegistered) {
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                //: "Vous n'etes pas connecté"
                                qsTr("group_call_error_not_connected"), false)
                } else {
                    console.log("create group chat")
                    chatCreationLayout.groupChatObj = UtilsCpp.createGroupChat(chatCreationLayout.groupName.text, addParticipantsLayout.selectedParticipants)
                }
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
            SelectedChatView {
                anchors.fill: parent
                chat: mainItem.selectedChatGui || null
                onChatChanged: if (mainItem.selectedChatGui !== chat) mainItem.selectedChatGui = chat
            }
        }
    }
}
