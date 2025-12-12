import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

Item {
    id: mainItem
    property var callObj
    property var contextualMenuOpenedComponent: undefined

    signal addAccountRequest
    signal openNewCallRequest
    signal callCreated
    signal openCallHistory
    signal openNumPadRequest
    signal displayContactRequested(string contactAddress)
    signal displayChatRequested(string contactAddress)
    signal openChatRequested(ChatGui chat)
    signal createContactRequested(string name, string address)
    signal scheduleMeetingRequested(string subject, list<string> addresses)
    signal accountRemoved

    function goToNewCall() {
        tabbar.currentIndex = 0;
        mainItem.openNewCallRequest();
    }
    function goToCallHistory() {
        tabbar.currentIndex = 0;
        mainItem.openCallHistory();
    }
    function displayContactPage(contactAddress) {
        tabbar.currentIndex = 1;
        mainItem.displayContactRequested(contactAddress);
    }
    function displayChatPage(contactAddress) {
        tabbar.currentIndex = 2;
        mainItem.displayChatRequested(contactAddress);
    }
    function openChat(chat) {
        tabbar.currentIndex = 2;
        mainItem.openChatRequested(chat);
    }
    function createContact(name, address) {
        tabbar.currentIndex = 1;
        mainItem.createContactRequested(name, address);
    }
    function scheduleMeeting(subject, addresses) {
        tabbar.currentIndex = 3;
        mainItem.scheduleMeetingRequested(subject, addresses);
    }

    function openContextualMenuComponent(component) {
        if (mainItem.contextualMenuOpenedComponent && mainItem.contextualMenuOpenedComponent != component) {
            mainStackView.pop();
            if (mainItem.contextualMenuOpenedComponent) {
                mainItem.contextualMenuOpenedComponent.destroy();
            }
            mainItem.contextualMenuOpenedComponent = undefined;
        }
        if (!mainItem.contextualMenuOpenedComponent) {
            mainStackView.push(component);
            mainItem.contextualMenuOpenedComponent = component;
        }
        settingsMenuButton.popup.close();
    }

    function closeContextualMenuComponent() {
        mainStackView.pop();
        if (mainItem.contextualMenuOpenedComponent)
            mainItem.contextualMenuOpenedComponent.destroy();
        mainItem.contextualMenuOpenedComponent = undefined;
    }

    function openAccountSettings(account) {
        var page = accountSettingsPageComponent.createObject(parent, {
            "account": account
        });
        openContextualMenuComponent(page);
    }

    AccountProxy {
        id: accountProxy
        sourceModel: AppCpp.accounts
        onDefaultAccountChanged: if (tabbar.currentIndex === 0 && defaultAccount)
            defaultAccount.core?.lResetMissedCalls()
    }

    CallProxy {
        id: callsModel
        sourceModel: AppCpp.calls
    }

    Item {
        anchors.fill: parent

        Popup {
            id: currentCallNotif
            background: Item {}
            closePolicy: Control.Popup.NoAutoClose
            visible: currentCall && currentCall.core.state != LinphoneEnums.CallState.Idle && currentCall.core.state != LinphoneEnums.CallState.IncomingReceived && currentCall.core.state != LinphoneEnums.CallState.PushIncomingReceived
            x: mainItem.width / 2 - width / 2
            y: contentItem.height / 2
            property var currentCall: callsModel.currentCall ? callsModel.currentCall : null
            property string remoteName: currentCall ? currentCall.core.remoteName : ""
            contentItem: MediumButton {
                style: ButtonStyle.toast
                text: currentCallNotif.currentCall ? currentCallNotif.currentCall.core.conference ? ("Réunion en cours : ") + currentCallNotif.currentCall.core.conference.core.subject : (("Appel en cours : ") + currentCallNotif.remoteName) : "appel en cours"
                onClicked: {
                    var callsWindow = UtilsCpp.getOrCreateCallsWindow(currentCallNotif.currentCall);
                    UtilsCpp.smartShowWindow(callsWindow);
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            anchors.topMargin: Utils.getSizeWithScreenRatio(25)

            VerticalTabBar {
                id: tabbar
                Layout.fillHeight: true
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(82)
                defaultAccount: accountProxy.defaultAccount
                currentIndex: 0
                onCountChanged: if (currentIndex >= count) currentIndex = 0
                Binding on currentIndex {
                    when: mainItem.contextualMenuOpenedComponent != undefined
                    value: -1
                }
                model: [
                    {
                        "icon": AppIcons.phone,
                        "selectedIcon": AppIcons.phoneSelected,
                        //: "Appels"
                        "label": qsTr("bottom_navigation_calls_label"),
                        //: "Open calls page"
                        "accessibilityLabel": qsTr("open_calls_page_accessible_name")
                    },
                    {
                        "icon": AppIcons.adressBook,
                        "selectedIcon": AppIcons.adressBookSelected,
                        //: "Contacts"
                        "label": qsTr("bottom_navigation_contacts_label"),
                        //: "Open contacts page"
                        "accessibilityLabel": qsTr("open_contacts_page_accessible_name")
                    },
                    {
                        "icon": AppIcons.chatTeardropText,
                        "selectedIcon": AppIcons.chatTeardropTextSelected,
                        //: "Conversations"
                        "label": qsTr("bottom_navigation_conversations_label"),
                        //: "Open conversations page"
                        "accessibilityLabel": qsTr("open_conversations_page_accessible_name"),
                        "visible": !SettingsCpp.disableChatFeature
                    },
                    {
                        "icon": AppIcons.videoconference,
                        "selectedIcon": AppIcons.videoconferenceSelected,
                        //: "Réunions"
                        "label": qsTr("bottom_navigation_meetings_label"),
                        //: "Open meetings page"
                        "accessibilityLabel": qsTr("open_contact_page_accessible_name"),
                        "visible": !SettingsCpp.disableMeetingsFeature
                    }
                ]
                onCurrentIndexChanged: {
                    if (currentIndex === -1 || currentIndex >= tabbar.visibleCount)
                        return;
                    if (currentIndex === 0 && accountProxy.defaultAccount)
                        accountProxy.defaultAccount.core?.lResetMissedCalls();
                    if (mainItem.contextualMenuOpenedComponent) {
                        closeContextualMenuComponent();
                    }
                }
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Right) {
                        mainStackView.currentItem.forceActiveFocus();
                    }
                }
                Component.onCompleted: {
                    if (SettingsCpp.shortcutCount > 0) {
                        var shortcuts = SettingsCpp.shortcuts;
                        shortcuts.forEach(shortcut => {
                            model.push({
                                "icon": shortcut.icon,
                                "selectedIcon": shortcut.icon,
                                "label": shortcut.name,
                                "colored": true,
                                "link": shortcut.link
                            });
                        });
                    }
                    initButtons();
                    currentIndex = SettingsCpp.getLastActiveTabIndex();
                    tabbar.updateVisibleCount()
                    if (currentIndex === -1 || currentIndex >= tabbar.visibleCount)
                        currentIndex = 0;
                }
            }
            ColumnLayout {
                spacing: 0

                RowLayout {
                    id: topRow
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                    Layout.leftMargin: Utils.getSizeWithScreenRatio(45)
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(41)
                    spacing: Utils.getSizeWithScreenRatio(25)
                    SearchBar {
                        id: magicSearchBar
                        Layout.fillWidth: true
                        //: "Rechercher un contact, appeler %1"
                        placeholderText: qsTr("searchbar_placeholder_text").arg(SettingsCpp.disableChatFeature ? "…" :
                        //: "ou envoyer un message …"
                        qsTr("searchbar_placeholder_text_chat_feature_enabled"))
                        focusedBorderColor: DefaultStyle.main1_500_main
                        numericPadButton.visible: text.length === 0
                        numericPadButton.checkable: false
                        handleNumericPadPopupButtonsPressed: false

                        onOpenNumericPadRequested: mainItem.goToNewCall()

                        Connections {
                            target: mainItem
                            function onCallCreated() {
                                magicSearchBar.focus = false;
                                magicSearchBar.clearText();
                            }
                        }

                        onTextChanged: {
                            if (text.length != 0)
                                listPopup.open();
                            else
                                listPopup.close();
                        }
                        KeyNavigation.down: contactList //contactLoader.item?.count > 0 || !contactLoader.item?.footerItem? contactLoader.item : contactLoader.item?.footerItem
                        KeyNavigation.up: contactList //contactLoader.item?.footerItem ? contactLoader.item?.footerItem : contactLoader.item

                        Popup {
                            id: listPopup
                            width: magicSearchBar.width
                            property real maxHeight: Utils.getSizeWithScreenRatio(400)
                            property bool displayScrollbar: contactList.height > maxHeight
                            height: Math.min(contactList.contentHeight, maxHeight) + topPadding + bottomPadding
                            y: magicSearchBar.height
                            //                            closePolicy: Popup.CloseOnEscape
                            topPadding: Utils.getSizeWithScreenRatio(20)
                            bottomPadding: Utils.getSizeWithScreenRatio(contactList.haveContacts ? 20 : 10)
                            rightPadding: Utils.getSizeWithScreenRatio(8)
                            leftPadding: Utils.getSizeWithScreenRatio(20)
                            visible: magicSearchBar.text.length != 0

                            background: Item {
                                anchors.fill: parent
                                Rectangle {
                                    id: popupBg
                                    radius: Utils.getSizeWithScreenRatio(16)
                                    color: DefaultStyle.grey_0
                                    anchors.fill: parent
                                    border.color: DefaultStyle.main1_500_main
                                    border.width: contactList.activeFocus ? 2 : 0
                                }
                                MultiEffect {
                                    source: popupBg
                                    anchors.fill: popupBg
                                    shadowEnabled: true
                                    shadowBlur: 0.1
                                    shadowColor: DefaultStyle.grey_1000
                                    shadowOpacity: 0.1
                                }
                            }

                            contentItem: AllContactListView {
                                id: contactList
                                width: listPopup.width - listPopup.leftPadding - listPopup.rightPadding
                                itemsRightMargin: Utils.getSizeWithScreenRatio(5) //(Actions have already 10 of margin)
                                showInitials: false
                                showContactMenu: false
                                showActions: true
                                showFavorites: false
                                selectionEnabled: false
                                searchOnEmpty: false

                                sectionsPixelSize: Typography.p2.pixelSize
                                sectionsWeight: Typography.p2.weight
                                sectionsSpacing: Utils.getSizeWithScreenRatio(5)

                                searchBarText: magicSearchBar.text
                            }
                        }
                    }
                    RowLayout {
                        spacing: Utils.getSizeWithScreenRatio(10)
                        PopupButton {
                            id: deactivateDndButton
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
                            popup.padding: Utils.getSizeWithScreenRatio(14)
                            //: "Do not disturb"
                            popUpTitle: qsTr("do_not_disturb_accessible_name")
                            visible: SettingsCpp.dnd
                            contentItem: EffectImage {
                                imageSource: AppIcons.bellDnd
                                width: Utils.getSizeWithScreenRatio(32)
                                height: Utils.getSizeWithScreenRatio(32)
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
                                fillMode: Image.PreserveAspectFit
                                colorizationColor: DefaultStyle.main1_500_main
                            }
                            popup.contentItem: ColumnLayout {
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    focus: visible
                                    icon.width: Utils.getSizeWithScreenRatio(32)
                                    icon.height: Utils.getSizeWithScreenRatio(32)
                                    //: "Désactiver ne pas déranger"
                                    text: qsTr("contact_presence_status_disable_do_not_disturb")
                                    icon.source: AppIcons.bellDnd
                                    onClicked: {
                                        deactivateDndButton.popup.close();
                                        SettingsCpp.dnd = false;
                                    }
                                }
                            }
                        }
                        Voicemail {
                            id: voicemail
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(42)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(36)
                            Repeater {
                                model: accountProxy
                                delegate: Item {
                                    Connections {
                                        target: modelData.core
                                        function onShowMwiChanged() {
                                            voicemail.updateCumulatedMwi();
                                        }
                                        function onVoicemailAddressChanged() {
                                            voicemail.updateCumulatedMwi();
                                        }
                                    }
                                }
                            }

                            function updateCumulatedMwi() {
                                var count = 0;
                                var showMwi = false;
                                var supportsVoiceMail = false;
                                for (var i = 0; i < accountProxy.count; i++) {
                                    var core = accountProxy.getAt(i).core;
                                    count += core.voicemailCount;
                                    showMwi |= core.showMwi;
                                    supportsVoiceMail |= core.voicemailAddress.length > 0;
                                }
                                voicemail.showMwi = showMwi;
                                voicemail.voicemailCount = count;
                                voicemail.visible = showMwi || supportsVoiceMail;
                            }

                            Component.onCompleted: {
                                updateCumulatedMwi();
                            }

                            onClicked: {
                                if (accountProxy.count > 1) {
                                    avatarButton.popup.open();
                                } else {
                                    if (accountProxy.defaultAccount.core.voicemailAddress.length > 0)
                                        UtilsCpp.createCall(accountProxy.defaultAccount.core.voicemailAddress);
                                    else
                                        UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                        //: "L'URI de messagerie vocale n'est pas définie."
                                        qsTr("no_voicemail_uri_error_message"), false);
                                }
                            }
                        }
                        PopupButton {
                            id: avatarButton
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(54)
                            Layout.preferredHeight: width
                            popup.topPadding: Utils.getSizeWithScreenRatio(23)
                            popup.bottomPadding: Utils.getSizeWithScreenRatio(23)
                            popup.leftPadding: Utils.getSizeWithScreenRatio(24)
                            popup.rightPadding: Utils.getSizeWithScreenRatio(24)
                            //: "Account list"
                            popUpTitle: qsTr("account_list_accessible_name")
                            contentItem: Item {
                                Avatar {
                                    id: avatar
                                    height: avatarButton.height
                                    width: avatarButton.width
                                    account: accountProxy.defaultAccount
                                }
                                Rectangle {
                                    // Black border for keyboard navigation
                                    visible: avatarButton.keyboardFocus
                                    width: avatar.width
                                    height: avatar.height
                                    color: "transparent"
                                    border.color: DefaultStyle.main2_900
                                    border.width: Utils.getSizeWithScreenRatio(3)
                                    radius: width / 2
                                }
                            }
                            popup.contentItem: AccountListView {
                                id: accounts
                                popupId: avatarButton
                                onAddAccountRequest: mainItem.addAccountRequest()
                                onEditAccount: function (account) {
                                    avatarButton.popup.close();
                                    openAccountSettings(account);
                                }
                                getPreviousItem: avatarButton.getPreviousItem
                                getNextItem: avatarButton.getNextItem
                            }
                        }
                        PopupButton {
                            id: settingsMenuButton
                            icon.width: Utils.getSizeWithScreenRatio(24)
                            icon.height: Utils.getSizeWithScreenRatio(24)
                            popup.width: Utils.getSizeWithScreenRatio(271)
                            popup.padding: Utils.getSizeWithScreenRatio(14)
                            //: "Application options"
                            popUpTitle: qsTr("application_options_accessible_name")
                            popup.contentItem: FocusScope {
                                id: popupFocus
                                implicitHeight: settingsButtons.implicitHeight
                                implicitWidth: settingsButtons.implicitWidth
                                Keys.onPressed: event => {
                                    if (event.key == Qt.Key_Left || event.key == Qt.Key_Escape) {
                                        settingsMenuButton.popup.close();
                                        event.accepted = true;
                                    }
                                }

                                ColumnLayout {
                                    id: settingsButtons
                                    spacing: Utils.getSizeWithScreenRatio(16)
                                    anchors.fill: parent

                                    IconLabelButton {
                                        id: accountButton
                                        Layout.fillWidth: true
                                        visible: !SettingsCpp.hideAccountSettings
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)

                                        //: Mon compte
                                        text: qsTr("drawer_menu_manage_account")
                                        icon.source: AppIcons.manageProfile
                                        onClicked: openAccountSettings(accountProxy.defaultAccount ? accountProxy.defaultAccount : accountProxy.firstAccount())
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(0) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(0) : null
                                    }
                                    IconLabelButton {
                                        id: dndButton
                                        Layout.fillWidth: true
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        text: SettingsCpp.dnd ? qsTr("contact_presence_status_disable_do_not_disturb") :
                                        //: "Activer ne pas déranger"
                                        qsTr("contact_presence_status_enable_do_not_disturb")
                                        icon.source: AppIcons.bellDnd
                                        onClicked: {
                                            settingsMenuButton.popup.close();
                                            SettingsCpp.dnd = !SettingsCpp.dnd;
                                        }
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(1) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(1) : null
                                    }
                                    IconLabelButton {
                                        id: settingsButton
                                        Layout.fillWidth: true
                                        visible: !SettingsCpp.hideSettings
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        text: qsTr("settings_title")
                                        icon.source: AppIcons.settings
                                        onClicked: {
                                            var page = settingsPageComponent.createObject(parent);
                                            openContextualMenuComponent(page)
                                        }
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(2) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(2) : null
                                    }
                                    IconLabelButton {
                                        id: recordsButton
                                        Layout.fillWidth: true
                                        visible: false// !SettingsCpp.disableCallRecordings
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        //: "Enregistrements"
                                        text: qsTr("recordings_title")
                                        icon.source: AppIcons.micro
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(3) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(3) : null
                                    }
                                    IconLabelButton {
                                        id: helpButton
                                        Layout.fillWidth: true
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        //: "Aide"
                                        text: qsTr("help_title")
                                        icon.source: AppIcons.question
                                        onClicked: {
                                            var page = helpPageComponent.createObject(parent);
                                            openContextualMenuComponent(page)
                                        }
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(4) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(4) : null
                                    }
                                    IconLabelButton {
                                        id: quitButton
                                        Layout.fillWidth: true
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        //: "Quitter l'application"
                                        text: qsTr("help_quit_title")
                                        icon.source: AppIcons.power
                                        onClicked: {
                                            settingsMenuButton.popup.close();
                                            //: "Quitter %1 ?"
                                            UtilsCpp.getMainWindow().showConfirmationLambdaPopup("", qsTr("quit_app_question").arg(applicationName), "", function (confirmed) {
                                                if (confirmed) {
                                                    console.info("Exiting App from Top Menu");
                                                    Qt.quit();
                                                }
                                            });
                                        }
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(5) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(5) : null
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                        visible: addAccountButton.visible
                                        color: DefaultStyle.main2_400
                                    }
                                    IconLabelButton {
                                        id: addAccountButton
                                        Layout.fillWidth: true
                                        visible: SettingsCpp.maxAccount == 0 || SettingsCpp.maxAccount > accountProxy.count
                                        icon.width: Utils.getSizeWithScreenRatio(32)
                                        icon.height: Utils.getSizeWithScreenRatio(32)
                                        //: "Ajouter un compte"
                                        text: qsTr("drawer_menu_add_account")
                                        icon.source: AppIcons.plusCircle
                                        onClicked: mainItem.addAccountRequest()
                                        KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(7) : null
                                        KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(7) : null
                                    }
                                }
                            }
                        }
                    }
                }
                Component {
                    id: mainStackLayoutComponent
                    StackLayout {
                        id: mainStackLayout
                        objectName: "mainStackLayout"
                        property int _currentIndex: tabbar.currentIndex
                        currentIndex: -1
                        onActiveFocusChanged: if (activeFocus && currentIndex >= 0)
                            children[currentIndex].forceActiveFocus()
                        on_CurrentIndexChanged: {
                            if (count > 0) {
                                if (_currentIndex >= count && tabbar.model[_currentIndex].link) {
                                    Qt.openUrlExternally(tabbar.model[_currentIndex].link);
                                } else if (_currentIndex >= 0) {
                                    currentIndex = _currentIndex;
                                    SettingsCpp.setLastActiveTabIndex(currentIndex);
                                }
                            }
                        }
                        Loader {
                            active: mainStackLayout.currentIndex === 0
                            sourceComponent: CallPage {
                                id: callPage
                                Connections {
                                    target: mainItem
                                    function onOpenNewCallRequest() {
                                        callPage.goToNewCall();
                                    }
                                    function onCallCreated() {
                                        callPage.goToCallHistory();
                                    }
                                    function onOpenCallHistory() {
                                        callPage.goToCallHistory();
                                    }
                                    function onOpenNumPadRequest() {
                                        callPage.openNumPadRequest();
                                    }
                                }
                                onCreateContactRequested: (name, address) => {
                                    mainItem.createContact(name, address);
                                }
                                Component.onCompleted: {
                                    magicSearchBar.numericPadPopup = callPage.numericPadPopup;
                                }
                                onGoToCallForwardSettings: {
                                    var page = settingsPageComponent.createObject(parent, {
                                        defaultIndex: 1
                                    });
                                    openContextualMenuComponent(page);
                                }
                            }
                        }
                        Loader {
                            active: mainStackLayout.currentIndex === 1
                            sourceComponent: ContactPage {
                                id: contactPage
                                Connections {
                                    target: mainItem
                                    function onCreateContactRequested(name, address) {
                                        contactPage.createContact(name, address);
                                    }
                                    function onDisplayContactRequested(contactAddress) {
                                        contactPage.initialFriendToDisplay = contactAddress;
                                    }
                                }
                            }
                        }
                        Loader {
                            active: mainStackLayout.currentIndex === 2
                            sourceComponent: ChatPage {
                                id: chatPage
                                Connections {
                                    target: mainItem
                                    function onDisplayChatRequested(contactAddress) {
                                        console.log("display chat requested, open with address", contactAddress);
                                        chatPage.remoteAddress = "";
                                        chatPage.remoteAddress = contactAddress;
                                    }
                                    function onOpenChatRequested(chat) {
                                        console.log("open chat requested, open", chat.core.title);
                                        chatPage.openChatRequested(chat);
                                    }
                                }
                            }
                        }

                        Loader {
                            active: mainStackLayout.currentIndex === 3
                            sourceComponent: Component {
                                id: meetingComp
                                MeetingPage {
                                    id: meetingPage
                                    Connections {
                                        target: mainItem
                                        function onScheduleMeetingRequested(subject, addresses) {
                                            meetingPage.createPreFilledMeeting(subject, addresses);
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
                Component {
                    id: accountSettingsPageComponent
                    AccountSettingsPage {
                        onGoBack: closeContextualMenuComponent()
                        onAccountRemoved: {
                            closeContextualMenuComponent();
                            mainItem.accountRemoved();
                        }
                    }
                }
                Component {
                    id: settingsPageComponent
                    SettingsPage {
                        onGoBack: closeContextualMenuComponent()
                    }
                }
                Component {
                    id: helpPageComponent
                    HelpPage {
                        onGoBack: closeContextualMenuComponent()
                    }
                }
                Control.StackView {
                    id: mainStackView
                    property Transition noTransition: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to: 1
                            duration: 0
                        }
                    }
                    pushEnter: noTransition
                    pushExit: noTransition
                    popEnter: noTransition
                    popExit: noTransition
                    Layout.topMargin: Utils.getSizeWithScreenRatio(24)
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    initialItem: mainStackLayoutComponent
                }
            }
        }
    }
}
