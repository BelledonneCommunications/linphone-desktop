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

    property var selectedChatGui

    property string remoteAddress
    onRemoteAddressChanged: console.log("ChatPage : remote address changed :", remoteAddress)
    property var remoteChatObj: UtilsCpp.getChatForAddress(remoteAddress)
    property ChatGui remoteChat: remoteChatObj ? remoteChatObj.value : null
    onRemoteChatChanged: if (remoteChat) selectedChatGui = remoteChat

    onSelectedChatGuiChanged: {
        if (selectedChatGui)
            rightPanelStackView.replace(currentChatComp,
                                        Control.StackView.Immediate)
        else
            rightPanelStackView.replace(emptySelection,
                                        Control.StackView.Immediate)
    }

    rightPanelStackView.initialItem: emptySelection

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
                            visible: chatListView.count === 0
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
                            onCountChanged: {
                                mainItem.selectedChatGui = model.getAt(currentIndex)
                            }

                            Connections {
                                target: mainItem
                                onSelectedChatGuiChanged: chatListView.selectChat(mainItem.selectedChatGui)
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
            Control.StackView.onActivated: {
                callContactsList.forceActiveFocus()
            }
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
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                // NewCallForm {
                //     id: callContactsList
                //     Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     focus: true
                //     numPadPopup: numericPadPopupItem
                //     groupCallVisible: true
                //     searchBarColor: DefaultStyle.grey_100
                //     onContactClicked: contact => {
                //         mainWindow.startCallWithContact(contact, false, callContactsList)
                //     }
                //     onGroupCallCreationRequested: {
                //         console.log("groupe call requetsed")
                //         listStackView.push(groupCallItem)
                //     }
                //     Connections {
                //         target: mainItem
                //         function onCreateCallFromSearchBarRequested() {
                //             UtilsCpp.createCall(callContactsList.searchBar.text)
                //         }
                //     }
                // }
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
                chat: mainItem.selectedChatGui
            }
        }
    }
}
