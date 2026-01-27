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
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

FocusScope {
    id: mainItem
    property ChatGui chat
    // used to show chat message reactions in details panel
    property ChatMessageGui chatMessage
    property var contactObj: chat ? UtilsCpp.findFriendByAddress(mainItem.chat.core.peerAddress) : null
    property var contact: contactObj?.value || null
    property alias messagesLoading: chatMessagesListView.loading
    property CallGui call
    property alias callHeaderContent: splitPanel.header.contentItem
    property bool replyingToMessage: false
    property bool editingMessage: false
    property string lastChar
    enum PanelType { MessageReactions, SharedFiles, Medias, ImdnStatus, ForwardToList, ManageParticipants, EphemeralSettings, None}
    
    signal oneOneCall(bool video)
    signal groupCall()

    onActiveFocusChanged: if(activeFocus) {
        if (chatMessagesListView.lastItemVisible) chat.core.lMarkAsRead()
    }
    MouseArea{
        anchors.fill: parent
        onPressed: {
            forceActiveFocus()
        }
    }

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
                    addresses.push(participantGui.core.sipAddress)
                }
                UtilsCpp.createGroupCall(mainItem.chat?.core.title, addresses)
            }
        })
    }

    Keys.onPressed: (event) => {
        event.accepted = false
        if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_F) {
            searchBarLayout.visible = true
            event.accepted = true
        }
    }


    RowLayout {
        anchors.fill: parent
        spacing: 0

        MainRightPanel {
            id: splitPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            panelColor: DefaultStyle.grey_0
            header.visible: !mainItem.call
            clip: true
            header.leftPadding: Utils.getSizeWithScreenRatio(32)
            header.rightPadding: Utils.getSizeWithScreenRatio(32)
            header.topPadding: Utils.getSizeWithScreenRatio(6)
            header.bottomPadding: Utils.getSizeWithScreenRatio(searchBarLayout.visible ? 3 : 6)

            header.contentItem: ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: mainItem.call ? 0 : Utils.getSizeWithScreenRatio(31)
                Layout.rightMargin: Utils.getSizeWithScreenRatio(41)
                spacing: searchBarLayout.visible ? Utils.getSizeWithScreenRatio(9) : 0
                RowLayout {
                    RowLayout {
                        id: chatHeader
                        spacing: Utils.getSizeWithScreenRatio(12)
                        Avatar {
                            property var contactObj: mainItem.chat ? UtilsCpp.findFriendByAddress(mainItem.chat?.core.peerAddress) : null
                            contact: contactObj?.value || null
                            displayNameVal: mainItem.chat?.core.avatarUri
                            secured: mainItem.chat && mainItem.chat.core.isSecured
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
                        }
                        ColumnLayout {
                            Text {
                                text: mainItem.chat?.core.title || ""
                                color: DefaultStyle.main2_600
                                maximumLineCount: 1
                                font {
                                    pixelSize: Typography.h4.pixelSize
                                    weight: Utils.getSizeWithScreenRatio(400)
                                }
                            }
                            RowLayout {
                                visible: mainItem.chat?.core.ephemeralEnabled || false
                                EffectImage {
                                    colorizationColor: DefaultStyle.main1_500_main
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                                    imageSource: AppIcons.clockCountDown
                                }
                                Text {
                                    text: mainItem.chat ? UtilsCpp.getEphemeralFormatedTime(mainItem.chat.core.ephemeralLifetime) : ""
                                }
                            }
                        }
                        RowLayout {
                            visible: mainItem.chat != undefined && mainItem.chat.core.isBasic
                            spacing: Utils.getSizeWithScreenRatio(8)
                            EffectImage {
                                Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(14) : 0
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                                colorizationColor: DefaultStyle.warning_700
                                imageSource: AppIcons.lockSimpleOpen
                            }
                            Text {
                                // hiding text if in call cause te view
                                // has smaller width
                                visible: !mainItem.call
                                Layout.fillWidth: true
                                color: DefaultStyle.warning_700
                                //: This conversation is not encrypted !
                                text: qsTr("unencrypted_conversation_warning")
                                font: Typography.p2
                            }
                        }
                        EffectImage {
                            visible: mainItem.chat?.core.muted || false
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                            colorizationColor: DefaultStyle.main1_500_main
                            imageSource: AppIcons.bellSlash
                        }
                    }
                    Item{Layout.fillWidth: true}
                    RowLayout {
                        spacing: Utils.getSizeWithScreenRatio(16)
                        RoundButton {
                            visible: !mainItem.call && !mainItem.chat?.core.isReadOnly
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
                            id: searchInHistoryButton
                            style: ButtonStyle.noBackground
                            icon.source: AppIcons.search
                            checkable: true
                            checkedImageColor: DefaultStyle.main1_500_main
                            onCheckedChanged: searchBarLayout.visible = checked
                            Connections {
                                target: searchBarLayout
                                function onVisibleChanged() {searchInHistoryButton.checked = searchBarLayout.visible}
                            }
                        }
                        RoundButton {
                            style: ButtonStyle.noBackground
                            icon.source: AppIcons.videoCamera
                            visible: !mainItem.chat?.core.isGroupChat && !mainItem.call
                            onPressed: mainItem.oneOneCall(true)
                        }
                        RoundButton {
                            id: detailsPanelButton
                            visible: !mainItem.call
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
                    visible: searchInHistoryButton.checked
                    onVisibleChanged: {
                        if(!visible) chatMessagesSearchBar.clearText()
                        else chatMessagesSearchBar.forceActiveFocus()
                    }
                    spacing: Utils.getSizeWithScreenRatio(50)
                    height: Utils.getSizeWithScreenRatio(65)
                    Connections {
                        target: mainItem
                        function onChatChanged() {searchBarLayout.visible = false}
                    }
                    SearchBar {
                        id: chatMessagesSearchBar
                        Layout.fillWidth: true
                        Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
                        property ChatMessageGui messageFound
                        delaySearch: false
                        Keys.onPressed: (event) => {
                            event.accepted = false
                            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (chatMessagesListView.filterText !== text) {
                                    chatMessagesListView.filterText = text
                                } else {
                                    if (event.modifiers & Qt.ShiftModifier) {
                                        chatMessagesListView.findIndexWithFilter(false)
                                    } else {
                                        chatMessagesListView.findIndexWithFilter(true)
                                    }
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                searchBarLayout.visible = false
                                event.accepted = true
                            }
                        }
                    }
                    RowLayout {
                        spacing: Utils.getSizeWithScreenRatio(10)
                        RoundButton {
                            icon.source: AppIcons.upArrow
                            style: ButtonStyle.noBackground
                            onClicked: {
                                if (chatMessagesListView.filterText !== chatMessagesSearchBar.text)
                                    chatMessagesListView.filterText = chatMessagesSearchBar.text
                                else
                                    chatMessagesListView.findIndexWithFilter(false)
                            }
                        }
                        RoundButton {
                            icon.source: AppIcons.downArrow
                            style: ButtonStyle.noBackground
                            onClicked: {
                                if (chatMessagesListView.filterText !== chatMessagesSearchBar.text)
                                    chatMessagesListView.filterText = chatMessagesSearchBar.text
                                else
                                    chatMessagesListView.findIndexWithFilter(true)
                            }
                        }
                    }
                    RoundButton {
                        icon.source: AppIcons.closeX
                        Layout.rightMargin: Utils.getSizeWithScreenRatio(20)
                        onClicked: {
                            chatMessagesListView.filterText = ""
                            searchBarLayout.visible = false
                        }
                        style: ButtonStyle.noBackground
                    }
                }
            }

            content: Control.SplitView {
                anchors.fill: parent
                orientation: Qt.Vertical
                handle: Rectangle {
                    visible: !mainItem.chat?.core.isReadOnly
                    enabled: visible
                    implicitHeight: Utils.getSizeWithScreenRatio(8)
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
                            backgroundColor: splitPanel.panelColor
                            width: parent.width - anchors.leftMargin - anchors.rightMargin
                            chat: mainItem.chat
                            anchors.fill: parent
                            anchors.leftMargin: Utils.getSizeWithScreenRatio(18)
                            anchors.rightMargin: Utils.getSizeWithScreenRatio(18)
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
                                if (mainItem.editingMessage) mainItem.editingMessage = false
                            }
                            onForwardMessageRequested: (chatMessage) => {
                                mainItem.chatMessage = chatMessage
                                contentLoader.panelType = SelectedChatView.PanelType.ForwardToList
                                detailsPanel.visible = true
                                if (mainItem.editingMessage) mainItem.editingMessage = false
                            }
                            onEditMessageRequested: (chatMessage) => {
                                mainItem.chatMessage = chatMessage
                                mainItem.editingMessage = true
                                if (mainItem.replyingToMessage) mainItem.replyingToMessage = false
                                messageSender.text = chatMessage.core.text
                            }
                        }
                        ScrollBar {
                            id: scrollbar
                            visible: chatMessagesListView.contentHeight > parent.height
                            active: visible
                            anchors.top: chatMessagesListView.top
                            anchors.bottom: chatMessagesListView.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: Utils.getSizeWithScreenRatio(5)
                            policy: Control.ScrollBar.AsNeeded
                        }
                        Control.Control {
                            id: participantListPopup
                            width: parent.width
                            height: Math.min(participantInfoList.height, Utils.getSizeWithScreenRatio(200))
                            visible: mainItem.lastChar === "@"
                            onVisibleChanged: console.log("participant list visible changed", visible, height)
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
                                    radius: Utils.getSizeWithScreenRatio(20)
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
                                delegateHoverRectangleRadius: Utils.getSizeWithScreenRatio(20)
                                onParticipantClicked: (username) => {
                                    messageSender.text = messageSender.text + username + " "
                                    messageSender.textArea.cursorPosition = messageSender.text.length
                                }
                            }
                        }
                    }
                    Control.Control {
                        id: selectedFilesArea
                        visible: selectedFiles.count > 0 || mainItem.replyingToMessage || mainItem.editingMessage
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        topPadding: Utils.getSizeWithScreenRatio(12)
                        bottomPadding: Utils.getSizeWithScreenRatio(12)
                        leftPadding: Utils.getSizeWithScreenRatio(19)
                        rightPadding: Utils.getSizeWithScreenRatio(19)
                        
                        Button {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: selectedFilesArea.topPadding
                            anchors.rightMargin: selectedFilesArea.rightPadding
                            icon.source: AppIcons.closeX
                            style: ButtonStyle.noBackground
                            onClicked: {
                                contents.clear()
                                if (mainItem.replyingToMessage)
                                	mainItem.replyingToMessage = false
								else if (mainItem.editingMessage) {
									mainItem.editingMessage = false
									messageSender.text = ""
								}
                            }
                        }
                        background: Item{
                            anchors.fill: parent
                            Rectangle {
                                color: DefaultStyle.grey_0
                                border.color: DefaultStyle.main2_100
                                border.width: Utils.getSizeWithScreenRatio(2)
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
                            spacing: Utils.getSizeWithScreenRatio(5)
                            ColumnLayout {
                                id: replyLayout
                                spacing: 0
                                visible: mainItem.chatMessage && (mainItem.replyingToMessage || mainItem.editingMessage)
                                Text {
                                    Layout.fillWidth: true
                                    //: Reply to %1
                                    text: mainItem.replyingToMessage ?
                                    	(mainItem.chatMessage ? qsTr("reply_to_label").arg(UtilsCpp.boldTextPart(mainItem.chatMessage.core.fromName, mainItem.chatMessage.core.fromName)) : "")
                                    	: qsTr("conversation_editing_message_title")
                                    color: DefaultStyle.main2_500_main
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
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                            }
                            ListView {
                                id: selectedFiles
                                orientation: ListView.Horizontal
                                visible: count > 0
                                spacing: Utils.getSizeWithScreenRatio(16)
                                Layout.fillWidth: true
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(104)
                                model: ChatMessageContentProxy {
                                    id: contents
                                    filterType: ChatMessageContentProxy.FilterContentType.File
                                }
                                delegate: Item {
                                    width: Utils.getSizeWithScreenRatio(80)
                                    height: Utils.getSizeWithScreenRatio(80)
                                    FileView {
                                        contentGui: modelData
                                        anchors.left: parent.left
                                        anchors.bottom: parent.bottom
                                        width: Utils.getSizeWithScreenRatio(69)
                                        height: Utils.getSizeWithScreenRatio(69)
                                    }
                                    RoundButton {
                                        icon.source: AppIcons.closeX
                                        icon.width: Utils.getSizeWithScreenRatio(12)
                                        icon.height: Utils.getSizeWithScreenRatio(12)
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        style: ButtonStyle.numericPad
                                        shadowEnabled: true
                                        padding: Utils.getSizeWithScreenRatio(3)
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
                    Control.SplitView.minimumHeight: mainItem.chat?.core.isReadOnly ? 0 : Utils.getSizeWithScreenRatio(79)
                    chat: mainItem.chat
                    selectedFilesCount: contents.count
                    callOngoing: mainItem.call != null
                    isEditing: mainItem.editingMessage
                    onChatChanged: {
                        if (chat) messageSender.text = mainItem.chat.core.sendingText
                    }
                    onTextChanged: {
                        if (text !== "") {
                            mainItem.chat.core.lCompose()
                        }
                        mainItem.lastChar = text.slice(-1)
                        mainItem.chat.core.sendingText = text
                    }
                    onSendMessage: {
                        var filesContents = contents.getAll()
                        if (mainItem.replyingToMessage) {
                            mainItem.replyingToMessage = false
                            UtilsCpp.sendReplyMessage(mainItem.chatMessage, mainItem.chat, text, filesContents)
                        }
                        else if (mainItem.editingMessage) {
                            UtilsCpp.sendReplaceMessage(mainItem.chatMessage, mainItem.chat, text, filesContents)
                            mainItem.editingMessage = false
                        }
                        else if (filesContents.length === 0)
                            mainItem.chat.core.lSendTextMessage(text)
                        else mainItem.chat.core.lSendMessage(text, filesContents)
                        contents.clear()
                    }
                    onDropped: (files) => {
                        contents.addFiles(files)
                    }
                    Connections {
                        target: mainItem
                        function onReplyingToMessageChanged() {
                            if (mainItem.replyingToMessage) messageSender.focusTextArea()
                        }
                        function onChatChanged() {messageSender.focusTextArea()}
                    }
                }
            }
        }
        Rectangle {
            visible: detailsPanel.visible
            color: DefaultStyle.main2_200
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(1)
            Layout.fillHeight: true
        }
        Control.Control {
            id: detailsPanel
            visible: false
            Layout.fillHeight: true
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(387)
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
                anchors.topMargin: Utils.getSizeWithScreenRatio(39)
                anchors.rightMargin: Utils.getSizeWithScreenRatio(15)
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
                Connections {
                    target: mainItem
                    function onChatChanged() {
                        detailsPanel.visible = false
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
                    onManageParticipantsRequested: contentLoader.panelType = SelectedChatView.PanelType.ManageParticipants
                    onOneOneCall: (video) => mainItem.oneOneCall(video)
                    onGroupCall: mainItem.groupCall()
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
                    showAsSquare: contentLoader.panelType === SelectedChatView.PanelType.Medias 
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
                        spacing: Utils.getSizeWithScreenRatio(31)
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
                            //     topPadding: Utils.getSizeWithScreenRatio(24) // Avoid to be on top of collapse button
                            //     active: true
                            //     interactive: true
                            //     visible: parent.contentHeight > parent.height
                            //     policy: Control.ScrollBar.AsNeeded
                            // }
                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Utils.getSizeWithScreenRatio(8)
                                // width: parent.width //- scrollbar.width - Utils.getSizeWithScreenRatio(5)
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
                                    Layout.fillWidth: true
                                    itemsRightMargin: 0
                                    showActions: false
                                    showContactMenu: false
                                    showFavorites: false
                                    searchBarText: forwardSearchBar.text
                                    Layout.preferredHeight: contentHeight
                                    onContactSelected: contact => selectedFriend = contact
                                    property FriendGui selectedFriend: null
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
}
