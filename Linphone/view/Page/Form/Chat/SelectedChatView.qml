import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

RowLayout {
    id: mainItem
    property ChatGui chat
    // used to show chat message reactions in details panel
    property ChatMessageGui chatMessage
	property var contactObj: chat ? UtilsCpp.findFriendByAddress(mainItem.chat.core.peerAddress) : null
	property var contact: contactObj?.value || null
    property CallGui call
    property alias callHeaderContent: splitPanel.headerContentItem
    property bool replyingToMessage: false
    property bool showSearchBar: false
    spacing: 0
    enum PanelType { MessageReactions, SharedFiles, Medias, ImdnStatus, ForwardToList, ManageParticipants, EphemeralSettings, None}
    
    signal oneOneCall(bool video)
	signal groupCall()

    onOneOneCall: {
		if (contact)
			mainWindow.startCallWithContact(contact, video, mainItem)
		else
			UtilsCpp.createCall(mainItem.chat?.core.peerAddress, {'localVideoEnabled':video})
	}
	
	onGroupCall: {
		mainWindow.showConfirmationLambdaPopup("",
		qsTr("chat_view_group_call_toast_message"),
		"",
		function(confirmed) {
			if (confirmed) {
				const sourceList = mainItem.chat?.core.participants
				let addresses = [];
				for (let i = 0; i < sourceList.length; ++i) {
					const participantGui = sourceList[i]
					const participantCore = participantGui.core
					addresses.push(participantCore.sipAddress)
				}
				UtilsCpp.createGroupCall(mainItem.chat?.core.title, addresses)
			}
		})
	}

    //onEventChanged: {
        // TODO : call when all messages read after scroll to unread feature available
        // if (chat) chat.core.lMarkAsRead()
    //}
    MainRightPanel {
        id: splitPanel
        Layout.fillWidth: true
        Layout.fillHeight: true
        panelColor: DefaultStyle.grey_0
        header.visible: !mainItem.call
        clip: true
        header.leftPadding: Math.round(32 * DefaultStyle.dp)
        header.rightPadding: Math.round(32 * DefaultStyle.dp)
        header.topPadding: Math.round(6 * DefaultStyle.dp)
	    header.bottomPadding: mainItem.showSearchBar ? Math.round(3 * DefaultStyle.dp) : Math.round(6 * DefaultStyle.dp)

        headerContentItem: ColumnLayout {
            anchors.left: parent?.left
            anchors.leftMargin: mainItem.call ? 0 : Math.round(31 * DefaultStyle.dp)
            anchors.verticalCenter: parent?.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Math.round(41 * DefaultStyle.dp)
            spacing: searchBarLayout.visible ? Math.round(9 * DefaultStyle.dp) : 0
            RowLayout {
                RowLayout {
                    id: chatHeader
                    spacing: Math.round(12 * DefaultStyle.dp)
                    Avatar {
                        property var contactObj: mainItem.chat ? UtilsCpp.findFriendByAddress(mainItem.chat?.core.peerAddress) : null
                        contact: contactObj?.value || null
                        displayNameVal: contact ? "" : mainItem.chat?.core.avatarUri
                        Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                    }
                    Text {
                        text: mainItem.chat?.core.title || ""
                        color: DefaultStyle.main2_600
                        Layout.fillWidth: true
                        maximumLineCount: 1
                        font {
                            pixelSize: Typography.h4.pixelSize
                            weight: Math.round(400 * DefaultStyle.dp)
                            capitalization: Font.Capitalize
                        }
                    }
                    EffectImage {
                        visible: mainItem.chat?.core.muted || false
                        Layout.preferredWidth: 20 * DefaultStyle.dp
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 20 * DefaultStyle.dp
                        colorizationColor: DefaultStyle.main1_500_main
                        imageSource: AppIcons.bellSlash
                    }
                }
                Item{Layout.fillWidth: true}
                RowLayout {
                    spacing: Math.round(16 * DefaultStyle.dp)
                    RoundButton {
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.phone
                        onPressed: {
                            if (mainItem.chat.core.isGroupChat) {
                                mainItem.groupCall()
                            } else {
                                mainItem.oneOneCall(false)
                            }
                        }
                    }
                    RoundButton {
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.videoCamera
                        visible: !mainItem.chat?.core.isGroupChat || false
                        onPressed: mainItem.oneOneCall(true)
                    }
                    RoundButton {
                        id: detailsPanelButton
                        style: ButtonStyle.noBackground
                        checkable: true
                        checkedImageColor: DefaultStyle.main1_500_main
                        icon.source: AppIcons.info
                        checked: detailsPanel.visible
                        onCheckedChanged: {
                            detailsPanel.visible = checked
                        }
                    }
                }
            }
            RowLayout {
                id: searchBarLayout
                visible: mainItem.showSearchBar
                onVisibleChanged: {
                    if(!visible) chatMessagesSearchBar.clearText()
                    else chatMessagesSearchBar.forceActiveFocus()
                }
                spacing: Math.round(50 * DefaultStyle.dp)
                height: Math.round(65 * DefaultStyle.dp)
                SearchBar {
                    id: chatMessagesSearchBar
                    Layout.fillWidth: true
                    Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
                    delaySearch: false
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            if (chatMessagesListView.filterText !== text) {
                                chatMessagesListView.filterText = text
                            } else {
                                if (event.modifiers & Qt.ShiftModifier) {
                                    chatMessagesListView.findIndexWithFilter(true)
                                } else {
                                    chatMessagesListView.findIndexWithFilter(false)
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: Math.round(10 * DefaultStyle.dp)
                    RoundButton {
                        icon.source: AppIcons.upArrow
                        style: ButtonStyle.noBackground
                        onClicked: chatMessagesListView.findIndexWithFilter(true)
                    }
                    RoundButton {
                        icon.source: AppIcons.downArrow
                        style: ButtonStyle.noBackground
                        onClicked: chatMessagesListView.findIndexWithFilter(false)
                    }
                }
                RoundButton {
                    icon.source: AppIcons.closeX
                    Layout.rightMargin: Math.round(20 * DefaultStyle.dp)
                    onClicked: mainItem.showSearchBar = false
                    style: ButtonStyle.noBackground
                }
            }
        }

        content: Control.SplitView {
            anchors.fill: parent
            orientation: Qt.Vertical
            handle: Rectangle {
                implicitHeight: Math.round(8 * DefaultStyle.dp)
                color: Control.SplitHandle.hovered ? DefaultStyle.grey_200 : DefaultStyle.grey_100
            }
            ColumnLayout {
                spacing: 0
                Control.SplitView.fillHeight: true
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ChatMessagesListView {
                        id: chatMessagesListView
                        clip: true
                        height: contentHeight
                        backgroundColor: splitPanel.panelColor
                        width: parent.width - anchors.leftMargin - anchors.rightMargin
                        chat: mainItem.chat
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(18 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
                        Control.ScrollBar.vertical: scrollbar
                        onShowReactionsForMessageRequested: (chatMessage) => {
                            mainItem.chatMessage = chatMessage
                            contentLoader.panelType = SelectedChatView.PanelType.MessageReactions
                            detailsPanel.visible = true
                        }
                        onShowImdnStatusForMessageRequested: (chatMessage) => {
                            mainItem.chatMessage = chatMessage
                            contentLoader.panelType = SelectedChatView.PanelType.ImdnStatus
                            detailsPanel.visible = true
                        }
                        onReplyToMessageRequested: (chatMessage) => {
                            mainItem.chatMessage = chatMessage
                            mainItem.replyingToMessage = true
                        }
                        onForwardMessageRequested: (chatMessage) => {
                            mainItem.chatMessage = chatMessage
                            contentLoader.panelType = SelectedChatView.PanelType.ForwardToList
                            detailsPanel.visible = true
                        }

                        Popup {
                            id: emojiPickerPopup
                            y: Math.round(chatMessagesListView.y + chatMessagesListView.height - height - 8*DefaultStyle.dp)
                            x: Math.round(chatMessagesListView.x + 8*DefaultStyle.dp)
                            width: Math.round(393 * DefaultStyle.dp)
                            height: Math.round(291 * DefaultStyle.dp)
                            visible: messageSender.emojiPickerButtonChecked
                            closePolicy: Popup.CloseOnPressOutside
                            onClosed: messageSender.emojiPickerButtonChecked = false
                            padding: 10 * DefaultStyle.dp
                            background: Item {
                                anchors.fill: parent
                                Rectangle {
                                    id: buttonBackground
                                    anchors.fill: parent
                                    color: DefaultStyle.grey_0
                                    radius: Math.round(20 * DefaultStyle.dp)
                                }
                                MultiEffect {
                                    anchors.fill: buttonBackground
                                    source: buttonBackground
                                    shadowEnabled: true
                                    shadowColor: DefaultStyle.grey_1000
                                    shadowBlur: 0.1
                                    shadowOpacity: 0.5
                                }
                            }
                            contentItem: EmojiPicker {
                                id: emojiPicker
                                editor: messageSender.textArea
                            }
                        }
                    }
                    ScrollBar {
                        id: scrollbar
                        visible: chatMessagesListView.contentHeight > parent.height
                        active: visible
                        anchors.top: chatMessagesListView.top
                        anchors.bottom: chatMessagesListView.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: Math.round(5 * DefaultStyle.dp)
                        policy: Control.ScrollBar.AsNeeded
                    }
                    Control.Control {
                        id: participantListPopup
                        width: parent.width
                        height: Math.min(participantInfoList.height, Math.round(200 * DefaultStyle.dp))
                        visible: false
                        anchors.bottom: chatMessagesListView.bottom
                        anchors.left: chatMessagesListView.left
                        anchors.right: chatMessagesListView.right
                        
                        background: Item {
                            anchors.fill: parent
                            Rectangle {
                                id: participantBg
                                color: DefaultStyle.grey_0
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                radius: Math.round(20 * DefaultStyle.dp)
                                height: parent.height
                            }
                            MultiEffect {
                                anchors.fill: participantBg
                                source: participantBg
                                shadowEnabled: true
                                shadowBlur: 0.5
                                shadowColor: DefaultStyle.grey_1000
				                shadowOpacity: 0.3
                            }
                            Rectangle {
                                id: bg
                                color: DefaultStyle.grey_0
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/2
                            }
                        }
                        contentItem: ParticipantInfoListView {
                            id: participantInfoList
                            height: contentHeight
                            width: participantListPopup.width
                            chatGui: mainItem.chat
                            onParticipantClicked: (username) => {
                                messageSender.text = messageSender.text + username + " "
                                messageSender.textArea.cursorPosition = messageSender.text.length
                            }
                        }
                    }
                }
                Control.Control {
                    id: selectedFilesArea
                    visible: selectedFiles.count > 0 || mainItem.replyingToMessage
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    topPadding: Math.round(12 * DefaultStyle.dp)
                    bottomPadding: Math.round(12 * DefaultStyle.dp)
                    leftPadding: Math.round(19 * DefaultStyle.dp)
                    rightPadding: Math.round(19 * DefaultStyle.dp)
                    
                    Button {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: selectedFilesArea.topPadding
                        anchors.rightMargin: selectedFilesArea.rightPadding
                        icon.source: AppIcons.closeX
                        style: ButtonStyle.noBackground
                        onClicked: {
                            contents.clear()
                            mainItem.replyingToMessage = false
                        }
                    }
                    background: Item{
                        anchors.fill: parent
                        Rectangle {
                            color: DefaultStyle.grey_0
                            border.color: DefaultStyle.main2_100
                            border.width: Math.round(2 * DefaultStyle.dp)
                            height: parent.height / 2
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 2 * parent.height / 3
                        }
                    }
                    contentItem: ColumnLayout {
                        spacing: Math.round(5 * DefaultStyle.dp)
                        ColumnLayout {
                            id: replyLayout
                            spacing: 0
                            visible: mainItem.chatMessage && mainItem.replyingToMessage
                            Text {
                                Layout.fillWidth: true
                                //: Reply to %1
                                text: mainItem.chatMessage ? qsTr("reply_to_label").arg(UtilsCpp.boldTextPart(mainItem.chatMessage.core.fromName, mainItem.chatMessage.core.fromName)) : ""
                                color: DefaultStyle.main2_500main
                                font {
                                    pixelSize: Typography.p3.pixelSize
                                    weight: Typography.p3.weight
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: mainItem.chatMessage ? mainItem.chatMessage.core.text : ""
                                color: DefaultStyle.main2_400
                                font {
                                    pixelSize: Typography.p3.pixelSize
                                    weight: Typography.p3.weight
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            visible: replyLayout.visible && selectedFiles.visible
                            color: DefaultStyle.main2_300
                            Layout.preferredHeight: Math.max(1, Math.round(1 * DefaultStyle.dp))
                        }
                        ListView {
                            id: selectedFiles
                            orientation: ListView.Horizontal
                            visible: count > 0
                            spacing: Math.round(16 * DefaultStyle.dp)
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.round(104 * DefaultStyle.dp)
                            model: ChatMessageContentProxy {
                                id: contents
                                filterType: ChatMessageContentProxy.FilterContentType.File
                            }
                            delegate: Item {
                                width: Math.round(80 * DefaultStyle.dp)
                                height: Math.round(80 * DefaultStyle.dp)
                                FileView {
                                    contentGui: modelData
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    width: Math.round(69 * DefaultStyle.dp)
                                    height: Math.round(69 * DefaultStyle.dp)
                                }
                                RoundButton {
                                    icon.source: AppIcons.closeX
                                    icon.width: Math.round(12 * DefaultStyle.dp)
                                    icon.height: Math.round(12 * DefaultStyle.dp)
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    style: ButtonStyle.numericPad
                                    shadowEnabled: true
                                    padding: Math.round(3 * DefaultStyle.dp)
                                    onClicked: contents.removeContent(modelData)
                                }
                            }
                            Control.ScrollBar.horizontal: selectedFilesScrollbar
                        }
                    }
                    ScrollBar {
                        id: selectedFilesScrollbar
                        active: true
                        anchors.bottom: selectedFilesArea.bottom
                        anchors.left: selectedFilesArea.left
                        anchors.right: selectedFilesArea.right
                    }
                }
            }
            ChatDroppableTextArea {
                id: messageSender
                Control.SplitView.preferredHeight: mainItem.chat?.core.isReadOnly ? 0 : height
                Control.SplitView.minimumHeight: mainItem.chat?.core.isReadOnly ? 0 : Math.round(79 * DefaultStyle.dp)
                chat: mainItem.chat
                selectedFilesCount: contents.count
                onChatChanged: {
                    if (chat) messageSender.text = mainItem.chat.core.sendingText
                }
                onTextChanged: {
                    if (text !== "" && mainItem.chat.core.composingName !== "") {
                        mainItem.chat.core.lCompose()
                    }
                    var lastChar = text.slice(-1)
                    if (lastChar == "@") participantListPopup.visible = true
                    else participantListPopup.visible = false
                    mainItem.chat.core.sendingText = text
                }
                onSendMessage: {
                    var filesContents = contents.getAll()
                    if (mainItem.replyingToMessage) {
                        mainItem.replyingToMessage = false
                        UtilsCpp.sendReplyMessage(mainItem.chatMessage, mainItem.chat, text, filesContents)
                    }
                    else if (filesContents.length === 0)
                        mainItem.chat.core.lSendTextMessage(text)
                    else mainItem.chat.core.lSendMessage(text, filesContents)
                    contents.clear()
                }
                onDropped: (files) => {
                    contents.addFiles(files)
                }
            }
        }
    }
    Rectangle {
        visible: detailsPanel.visible
        color: DefaultStyle.main2_200
        Layout.preferredWidth: Math.round(1 * DefaultStyle.dp)
        Layout.fillHeight: true
    }
	Control.Control {
		id: detailsPanel
		visible: false
		Layout.fillHeight: true
		Layout.preferredWidth: Math.round(387 * DefaultStyle.dp)
        onVisibleChanged: if(!visible) {
            contentLoader.panelType = SelectedChatView.PanelType.None
        }

		background: Rectangle {
			color: DefaultStyle.grey_0
			anchors.fill: parent
		}

		contentItem: Loader {
			id: contentLoader
            property int panelType: SelectedChatView.PanelType.None
			// anchors.top: parent.top
            anchors.fill: parent
			anchors.topMargin: Math.round(39 * DefaultStyle.dp)
			sourceComponent: panelType === SelectedChatView.PanelType.EphemeralSettings
				? ephemeralSettingsComponent
				: panelType === SelectedChatView.PanelType.MessageReactions
					? messageReactionsComponent
					: panelType === SelectedChatView.PanelType.ImdnStatus
						? messageImdnStatusComponent
                        : panelType === SelectedChatView.PanelType.SharedFiles || panelType === SelectedChatView.PanelType.Medias
					        ? sharedFilesComponent
                            : panelType === SelectedChatView.PanelType.ForwardToList
                                ? forwardToListsComponent
                                : panelType === SelectedChatView.PanelType.ManageParticipants
                                    ? manageParticipantsComponent
                                    : infoComponent
			active: detailsPanel.visible
			onLoaded: {
				if (contentLoader.item && contentLoader.item.parentView) {
					contentLoader.item.parentView = mainItem
				}
			}
		}

        Component {
            id: infoComponent
            ConversationInfos {
                chatGui: mainItem.chat

				onEphemeralSettingsRequested: contentLoader.panelType = SelectedChatView.PanelType.EphemeralSettings
                onShowSharedFilesRequested: (showMedias) => {
                    contentLoader.panelType = showMedias ? SelectedChatView.PanelType.Medias : SelectedChatView.PanelType.SharedFiles
                }
                onSearchInHistoryRequested: {
                    mainItem.showSearchBar = true
                    detailsPanel.visible = false
                }
				onManageParticipantsRequested: contentLoader.panelType = SelectedChatView.PanelType.ManageParticipants
            }
        }

        Component {
			id: messageReactionsComponent
			MessageReactionsInfos {
                chatMessageGui: mainItem.chatMessage
                onGoBackRequested: {
                    detailsPanel.visible = false
                    mainItem.chatMessage = null
                }
			}
		}
        Component {
			id: messageImdnStatusComponent
            MessageImdnStatusInfos {
                chatMessageGui: mainItem.chatMessage
                onGoBackRequested: {
                    detailsPanel.visible = false
                    mainItem.chatMessage = null
                }
			}
        }

        Component {
			id: sharedFilesComponent
			MessageSharedFilesInfos {
				chatGui: mainItem.chat
                title: contentLoader.panelType === SelectedChatView.PanelType.Medias 
                    //: Shared medias
                    ? qsTr("shared_medias_title") 
                    //: Shared documents
                    : qsTr("shared_documents_title")
                filter: contentLoader.panelType === SelectedChatView.PanelType.Medias ? ChatMessageFileProxy.FilterContentType.Medias : ChatMessageFileProxy.FilterContentType.Documents
                onGoBackRequested: {
                    // detailsPanel.visible = false
                    contentLoader.panelType = SelectedChatView.PanelType.None
                }
			}
		}
        
		Component {
			id: manageParticipantsComponent
			ManageParticipants {
				chatGui: mainItem.chat
				onDone: contentLoader.panelType = SelectedChatView.PanelType.None
			}
		}
		
		Component {
			id: ephemeralSettingsComponent
			EphemeralSettings {
				chatGui: mainItem.chat
				onDone: contentLoader.panelType = SelectedChatView.PanelType.None
			}
		}

        Component {
            id: forwardToListsComponent
            MessageInfosLayout {
                //: Forward to…
                title: qsTr("forward_to_title")
                // width: detailsPanel.width
                // RectangleTest{anchors.fill: parent}
                onGoBackRequested: {
                    detailsPanel.visible = false
                    mainItem.chatMessage = null
                }
                content: ColumnLayout {
                    spacing: Math.round(31 * DefaultStyle.dp)
                    SearchBar {
                        id: forwardSearchBar
                        Layout.fillWidth: true
                    }
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: parent.width
                        // width: parent.width
                        // Control.ScrollBar.vertical: ScrollBar {
                        //     id: scrollbar
                        //     topPadding: Math.round(24 * DefaultStyle.dp) // Avoid to be on top of collapse button
                        //     active: true
                        //     interactive: true
                        //     visible: parent.contentHeight > parent.height
                        //     policy: Control.ScrollBar.AsNeeded
                        // }
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: Math.round(8 * DefaultStyle.dp)
                            // width: parent.width //- scrollbar.width - Math.round(5 * DefaultStyle.dp)
                            RowLayout {
                                Text {
                                    //: Conversations
                                    text: qsTr("conversations_title")
                                    font {
                                        pixelSize: Typography.h4.pixelSize
                                        weight: Typography.h4.weight
                                    }
                                }
                                Item{Layout.fillWidth: true}
                                RoundButton {
                                    id: expandChatButton
                                    style: ButtonStyle.noBackground
                                    checkable: true
                                    checked: true
                                    icon.source: checked ? AppIcons.upArrow : AppIcons.downArrow
                                    KeyNavigation.down: contentControl
                                }
                            }
                            ChatListView {
                                visible: expandChatButton.checked
                                searchBar: forwardSearchBar
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentHeight
                                onChatClicked: (chat) => {
                                    UtilsCpp.forwardMessageTo(mainItem.chatMessage, chat)
                                    mainItem.chat = chat
                                    detailsPanel.visible = false
                                }
                            }
                            AllContactListView {
                                visible: expandContactButton.checked
                                Layout.fillWidth: true
                                itemsRightMargin: 0
                                showActions: false
                                showContactMenu: false
                                showFavorites: false
                                searchBarText: forwardSearchBar.text
                                Layout.preferredHeight: contentHeight
                                onContactSelected: contact => selectedFriend = contact
                                property FriendGui selectedFriend
                                property var chatForSelectedAddressObj: selectedFriend ? UtilsCpp.getChatForAddress(selectedFriend.core.defaultAddress) : null
                                property ChatGui chatForAddress: chatForSelectedAddressObj ? chatForSelectedAddressObj.value : null
                                onChatForAddressChanged: if(chatForAddress) {
                                    UtilsCpp.forwardMessageTo(mainItem.chatMessage, chatForAddress)
                                    mainItem.chat = chatForAddress
                                    detailsPanel.visible = false
                                }
                            }
                        }
                    }
                } 
            }
        }
	}
}
