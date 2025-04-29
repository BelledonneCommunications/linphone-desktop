import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import EnumsToStringCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

AbstractMainPage {
    id: mainItem
    //: "Ajouter un contact"
    noItemButtonText: qsTr("contacts_add")
    //: "Aucun contact pour le moment"
    emptyListText: qsTr("contacts_list_empty")
    newItemIconSource: AppIcons.plusCircle

    // disable left panel contact list interaction while a contact is being edited
    property bool leftPanelEnabled: !rightPanelStackView.currentItem
                                    || rightPanelStackView.currentItem.objectName
                                    != "contactEdition"
    property FriendGui selectedContact
    property string initialFriendToDisplay
    onInitialFriendToDisplayChanged: {
        if (initialFriendToDisplay != '' && contactList.selectContact(initialFriendToDisplay) != -1)
            initialFriendToDisplay = ""
        else if (initialFriendToDisplay != '')
            console.warn("Abstract not selected yet: ", initialFriendToDisplay)
    }

    onVisibleChanged: if (!visible) {
                          rightPanelStackView.clear()
                          contactList.resetSelections()
                      }
    function goToContactDetails() {
        if (selectedContact) {
            var firstItem = rightPanelStackView.get(0)
            if (firstItem && firstItem.objectName == "contactDetail")
                // Go directly to detail
                rightPanelStackView.popToIndex(0)
            else {
                if (rightPanelStackView.depth >= 1) {
                    // Replace in background and go back to it
                    rightPanelStackView.replace(firstItem, contactDetail)
                    rightPanelStackView.popToIndex(0)
                } else {
                    // empty
                    rightPanelStackView.push(contactDetail)
                }
            }
        } else {
            rightPanelStackView.clear()
        }
    }
    onSelectedContactChanged: {
        goToContactDetails()
    }

    onNoItemButtonPressed: createContact("", "")

    function createContact(name, address) {
        var friendGui = Qt.createQmlObject('import Linphone
FriendGui{
}', mainItem)
        friendGui.core.givenName = UtilsCpp.getGivenNameFromFullName(name)
        friendGui.core.familyName = UtilsCpp.getFamilyNameFromFullName(name)
        friendGui.core.appendAddress(address)
        if (!rightPanelStackView.currentItem
                || rightPanelStackView.currentItem.objectName != "contactEdition")
            rightPanelStackView.push(contactEdition, {
                                         "contact": friendGui,
                                         //: "Nouveau contact"
                                         "title": qsTr("contact_new_title"),
                                         // "Créer"
                                         "saveButtonText": qsTr("create")
                                     })
    }

    function editContact(friendGui) {
        rightPanelStackView.push(contactEdition, {
                                     "contact": friendGui,
                                     //: "Modifier contact"
                                     "title": qsTr("contact_edit_title"),
                                     "saveButtonText": qsTr("save")
                                 })
    }

    // rightPanelStackView.initialItem: contactDetail
    showDefaultItem: rightPanelStackView.depth == 0 && !contactList.haveContacts
                     && searchBar.text.length === 0

    function deleteContact(contact) {
        if (!contact)
            return
        var mainWin = UtilsCpp.getMainWindow()
        mainWin.showConfirmationLambdaPopup(
                    //: Supprimer %1 ?"
                    qsTr("contact_dialog_delete_title").arg(contact.core.fullName),
                    //: Ce contact sera définitivement supprimé.
                    qsTr("contact_dialog_delete_message"), "", function (confirmed) {
                        if (confirmed) {
                            var name = contact.core.fullName
                            contact.core.remove()
                            contactList.resetSelections()
                            UtilsCpp.showInformationPopup(
                                        //: "Contact supprimé"
                                        qsTr("contact_deleted_toast"),
                                        //: "%1 a été supprimé"
                                        qsTr("contact_deleted_message").arg(name))
                        }
                    })
    }

    Dialog {
        id: verifyDevicePopup
        property string deviceName
        property string deviceAddress
        padding: Math.round(30 * DefaultStyle.dp)
        width: Math.round(637 * DefaultStyle.dp)
        anchors.centerIn: parent
        closePolicy: Control.Popup.CloseOnEscape
        modal: true
        onAboutToHide: neverDisplayAgainCheckbox.checked = false
        //: "Augmenter la confiance"
        title: qsTr("contact_dialog_devices_trust_popup_title")
        //: "Pour augmenter le niveau de confiance vous devez appeler les différents appareils de votre contact et valider un code.<br><br>Vous êtes sur le point d’appeler “%1” voulez vous continuer ?"
        text: qsTr("contact_dialog_devices_trust_popup_message").arg(verifyDevicePopup.deviceName)
        buttons: RowLayout {
            RowLayout {
                spacing: Math.round(7 * DefaultStyle.dp)
                CheckBox {
                    id: neverDisplayAgainCheckbox
                }
                Text {
                    //: Ne plus afficher
                    text: qsTr("popup_do_not_show_again")
                    font.pixelSize: Math.round(14 * DefaultStyle.dp)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: neverDisplayAgainCheckbox.toggle()
                    }
                }
            }
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: Math.round(15 * DefaultStyle.dp)
                BigButton {
                    style: ButtonStyle.secondary
                    text: qsTr("cancel")
                    onClicked: verifyDevicePopup.close()
                }
                BigButton {
                    style: ButtonStyle.main
                    //: "Appeler"
                    text: qsTr("dialog_call")
                    onClicked: {
                        SettingsCpp.setDisplayDeviceCheckConfirmation(
                                    !neverDisplayAgainCheckbox.checked)
                        UtilsCpp.createCall(verifyDevicePopup.deviceAddress,
                                            {},
                                            LinphoneEnums.MediaEncryption.Zrtp)
                        onClicked: verifyDevicePopup.close()
                    }
                }
            }
        }
    }
    Dialog {
        id: trustInfoDialog
        width: Math.round(637 * DefaultStyle.dp)
        //: "Niveau de confiance"
        title: qsTr("contact_dialog_devices_trust_help_title")
        //: "Vérifiez les appareils de votre contact pour confirmer que vos communications seront sécurisées et sans compromission. <br>Quand tous seront vérifiés, vous atteindrez le niveau de confiance maximal."
        text: qsTr("contact_dialog_devices_trust_help_message")
        content: RowLayout {
            spacing: Math.round(50 * DefaultStyle.dp)
            Avatar {
                _address: "sip:a.c@sip.linphone.org"
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
            }
            EffectImage {
                imageSource: AppIcons.arrowRight
                colorizationColor: DefaultStyle.main2_600
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
            }
            Avatar {
                _address: "sip:a.c@sip.linphone.org"
                secured: true
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
            }
        }
        buttons: Button {
            //: "Ok"
            text: qsTr("dialog_ok")
            style: ButtonStyle.main
            leftPadding: Math.round(30 * DefaultStyle.dp)
            rightPadding: Math.round(30 * DefaultStyle.dp)
            onClicked: trustInfoDialog.close()
        }
    }

    leftPanelContent: FocusScope {
        id: leftPanel
        property real leftMargin: Math.round(45 * DefaultStyle.dp)
        property real rightMargin: Math.round(39 * DefaultStyle.dp)
        Layout.fillHeight: true
        Layout.fillWidth: true

        RowLayout {
            id: title
            spacing: 0
            anchors.top: leftPanel.top
            anchors.right: leftPanel.right
            anchors.left: leftPanel.left
            anchors.leftMargin: leftPanel.leftMargin
            anchors.rightMargin: leftPanel.rightMargin

            Text {
                //: "Contacts"
                text: qsTr("bottom_navigation_contacts_label")
                color: DefaultStyle.main2_700
                font.pixelSize: Typography.h2.pixelSize
                font.weight: Typography.h2.weight
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                id: createContactButton
                visible: !rightPanelStackView.currentItem
                         || rightPanelStackView.currentItem.objectName !== "contactEdition"
                style: ButtonStyle.noBackground
                icon.source: AppIcons.plusCircle
                Layout.preferredWidth: Math.round(28 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
                icon.width: Math.round(28 * DefaultStyle.dp)
                icon.height: Math.round(28 * DefaultStyle.dp)
                onClicked: {
                    mainItem.createContact("", "")
                }
                KeyNavigation.down: searchBar
            }
        }

        ColumnLayout {
            anchors.top: title.bottom
            anchors.right: leftPanel.right
            anchors.left: leftPanel.left
            anchors.leftMargin: leftPanel.leftMargin
            anchors.bottom: leftPanel.bottom
            enabled: mainItem.leftPanelEnabled
            spacing: Math.round(38 * DefaultStyle.dp)
            SearchBar {
                id: searchBar
                visible: contactList.haveContacts || text.length !== 0
                Layout.rightMargin: leftPanel.rightMargin
                Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                Layout.fillWidth: true
                //: Rechercher un contact
                placeholderText: qsTr("search_bar_look_for_contact_text")
                KeyNavigation.up: createContactButton
                KeyNavigation.down: contactList
            }
            ColumnLayout {
                id: content
                spacing: Math.round(15 * DefaultStyle.dp)
                Text {
                    visible: !contactList.loading && !contactList.haveContacts
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Math.round(137 * DefaultStyle.dp)
                    //: Aucun résultat…
                    text: searchBar.text.length !== 0 ? qsTr("list_filter_no_result_found")
                                                      //: Aucun contact pour le moment
                                                      : qsTr("contact_list_empty")
                    font {
                        pixelSize: Typography.h4.pixelSize
                        weight: Typography.h4.weight
                    }
                }
                AllContactListView {
                    id: contactList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: Math.round(8 * DefaultStyle.dp)
                    searchBarText: searchBar.text
                    hideSuggestions: true
                    showDefaultAddress: false
                    sourceFlags: LinphoneEnums.MagicSearchSource.Friends
                                 | LinphoneEnums.MagicSearchSource.FavoriteFriends
                                 | LinphoneEnums.MagicSearchSource.LdapServers
                                 | LinphoneEnums.MagicSearchSource.RemoteCardDAV
                    onHighlightedContactChanged: mainItem.selectedContact = highlightedContact
                    onContactDeletionRequested: contact => {
                                                    mainItem.deleteContact(
                                                        contact)
                                                }
                    onLoadingChanged: {
                        if (!loading && initialFriendToDisplay.length !== 0) {
                            Qt.callLater(function () {
                                if (selectContact(initialFriendToDisplay) != -1)
                                    initialFriendToDisplay = ""
                            })
                        }
                    }
                }
            }
        }
    }

    Component {
        id: contactDetail
        Item {
            width: parent?.width
            height: parent?.height
            property string objectName: "contactDetail"
            component ContactDetailLayout: ColumnLayout {
                id: contactDetailLayout
                spacing: Math.round(15 * DefaultStyle.dp)
                property string label
                property var icon
                property alias content: contentControl.contentItem
                signal titleIconClicked
                RowLayout {
                    spacing: Math.round(10 * DefaultStyle.dp)
                    Text {
                        text: contactDetailLayout.label
                        color: DefaultStyle.main1_500_main
                        font {
                            pixelSize: Typography.h4.pixelSize
                            weight: Typography.h4.weight
                        }
                    }
                    RoundButton {
                        visible: contactDetailLayout.icon != undefined
                        icon.source: contactDetailLayout.icon
                        style: ButtonStyle.noBackgroundOrange
                        onClicked: contactDetailLayout.titleIconClicked()
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    RoundButton {
                        id: expandButton
                        style: ButtonStyle.noBackground
                        checkable: true
                        checked: true
                        icon.source: checked ? AppIcons.upArrow : AppIcons.downArrow
                        KeyNavigation.down: contentControl
                    }
                }
                RoundedPane {
                    id: contentControl
                    visible: expandButton.checked
                    Layout.fillWidth: true
                    leftPadding: Math.round(20 * DefaultStyle.dp)
                    rightPadding: Math.round(20 * DefaultStyle.dp)
                    topPadding: Math.round(17 * DefaultStyle.dp)
                    bottomPadding: Math.round(17 * DefaultStyle.dp)
                }
            }
            ContactLayout {
                id: contactDetail
                anchors.fill: parent
                contact: mainItem.selectedContact
                button.color: DefaultStyle.main1_100
                button.text: qsTr("contact_details_edit")
                button.style: ButtonStyle.tertiary
                button.icon.source: AppIcons.pencil
                button.onClicked: mainItem.editContact(mainItem.selectedContact)
                button.visible: !mainItem.selectedContact?.core.readOnly
                property string contactAddress: contact ? contact.core.defaultAddress : ""
                property var computedContactNameObj: UtilsCpp.getDisplayName(
                                                         contactAddress)
                property string computedContactName: computedContactNameObj ? computedContactNameObj.value : ""
                property string contactName: contact ? contact.core.fullName : computedContactName
                component LabelButton: ColumnLayout {
                    id: labelButton
                    // property alias image: buttonImg
                    property alias button: button
                    property string label
                    spacing: Math.round(8 * DefaultStyle.dp)
                    RoundButton {
                        id: button
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.round(56 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(56 * DefaultStyle.dp)
                        style: ButtonStyle.grey
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: labelButton.label
                        font {
                            pixelSize: Typography.p1.pixelSize
                            weight: Typography.p1.weight
                        }
                    }
                }
                component ActionsButtons: RowLayout {
                    spacing: Math.round(58 * DefaultStyle.dp)
                    LabelButton {
                        button.icon.source: AppIcons.phone
                        //: "Appel"
                        label: qsTr("contact_call_action")
                        width: Math.round(56 * DefaultStyle.dp)
                        height: Math.round(56 * DefaultStyle.dp)
                        button.icon.width: Math.round(24 * DefaultStyle.dp)
                        button.icon.height: Math.round(24 * DefaultStyle.dp)
                        button.onClicked: mainWindow.startCallWithContact(contactDetail.contact, false, mainItem)
                    }
                    LabelButton {
                        button.icon.source: AppIcons.chatTeardropText
                        visible: !SettingsCpp.disableChatFeature
                        //: "Message"
                        label: qsTr("contact_message_action")
                        width: Math.round(56 * DefaultStyle.dp)
                        height: Math.round(56 * DefaultStyle.dp)
                        button.icon.width: Math.round(24 * DefaultStyle.dp)
                        button.icon.height: Math.round(24 * DefaultStyle.dp)
                        button.onClicked: {
                            console.debug("[ContactLayout.qml] Open conversation")
                            mainWindow.displayChatPage(contactDetail.contact.core.defaultAddress)
                        }
                    }
                    LabelButton {
                        visible: SettingsCpp.videoEnabled
                        button.icon.source: AppIcons.videoCamera
                        //: "Appel vidéo"
                        label: qsTr("contact_video_call_action")
                        width: Math.round(56 * DefaultStyle.dp)
                        height: Math.round(56 * DefaultStyle.dp)
                        button.icon.width: Math.round(24 * DefaultStyle.dp)
                        button.icon.height: Math.round(24 * DefaultStyle.dp)
                        button.onClicked: mainWindow.startCallWithContact(contactDetail.contact, true, mainItem)
                    }
                }
                bannerContent: [
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: contactDetail.contactName
                            Layout.fillWidth: true
                            maximumLineCount: 1
                            font {
                                pixelSize: Typography.h2.pixelSize
                                weight: Typography.h2.weight
                                capitalization: Font.Capitalize
                            }
                        }
                        Text {
                            visible: contactDetail.contact
                            property var mode: contactDetail.contact ? contactDetail.contact.core.consolidatedPresence : -1
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            text: mode === LinphoneEnums.ConsolidatedPresence.Online
                                //: "En ligne"
                                ? qsTr("contact_presence_status_online")
                                : mode === LinphoneEnums.ConsolidatedPresence.Busy
                                    //: "Occupé"
                                    ? qsTr("contact_presence_status_busy")
                                    : mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
                                        //: "Ne pas déranger"
                                        ? qsTr("contact_presence_status_do_not_disturb")
                                          //: "Hors ligne"
                                        : qsTr("contact_presence_status_offline")
                            color: mode === LinphoneEnums.ConsolidatedPresence.Online
                                ? DefaultStyle.success_500main
                                : mode === LinphoneEnums.ConsolidatedPresence.Busy
                                    ? DefaultStyle.warning_600
                                    : mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
                                        ? DefaultStyle.danger_500main
                                        : DefaultStyle.main2_500main
                            font.pixelSize: Math.round(14 * DefaultStyle.dp)
                        }
                    },
                    ActionsButtons {
                        visible: !contactDetail.useVerticalLayout
                    }
                ]
                secondLineContent: ActionsButtons {}
                content: Flickable {
                    contentWidth: parent.width
                    ColumnLayout {
                        spacing: Math.round(32 * DefaultStyle.dp)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        ColumnLayout {
                            spacing: Math.round(15 * DefaultStyle.dp)
                            Layout.fillWidth: true
                            ContactDetailLayout {
                                id: infoLayout
                                Layout.fillWidth: true
                                //: "Coordonnées"
                                label: qsTr("contact_details_numbers_and_addresses_title")
                                content: ListView {
                                    id: addrList
                                    height: contentHeight
                                    implicitHeight: contentHeight
                                    width: parent.width
                                    clip: true
                                    spacing: Math.round(9 * DefaultStyle.dp)
                                    model: VariantList {
                                        model: (mainItem.selectedContact ? UtilsCpp.append(mainItem.selectedContact.core.addresses, mainItem.selectedContact.core.phoneNumbers) : [])
                                    }
                                    delegate: Item {
                                        property var listViewModelData: modelData
                                        width: addrList.width
                                        height: Math.round(46 * DefaultStyle.dp)

                                        ColumnLayout {
                                            anchors.fill: parent
                                            // anchors.topMargin: Math.round(5 * DefaultStyle.dp)
                                            RowLayout {
                                                Layout.fillWidth: true
                                                // Layout.fillHeight: true
                                                // Layout.alignment: Qt.AlignVCenter
                                                // Layout.topMargin: Math.round(10 * DefaultStyle.dp)
                                                // Layout.bottomMargin: Math.round(10 * DefaultStyle.dp)
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: listViewModelData.label
                                                        font {
                                                            pixelSize: Typography.p2.pixelSize
                                                            weight: Typography.p2.weight
                                                        }
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        property string _text: listViewModelData.address
                                                        text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_text) : _text
                                                        font {
                                                            pixelSize: Typography.p1.pixelSize
                                                            weight: Typography.p1.weight
                                                        }
                                                    }
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                                RoundButton {
                                                    style: ButtonStyle.noBackground
                                                    icon.source: AppIcons.phone
                                                    onClicked: {
                                                        UtilsCpp.createCall(
                                                                    listViewModelData.address)
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                visible: index != addrList.model.count - 1
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                                Layout.rightMargin: Math.round(3 * DefaultStyle.dp)
                                                Layout.leftMargin: Math.round(3 * DefaultStyle.dp)
                                                color: DefaultStyle.main2_200
                                                clip: true
                                            }
                                        }
                                    }
                                }
                            }
                            RoundedPane {
                                visible: infoLayout.visible
                                         && companyText.text.length != 0
                                         || jobText.text.length != 0
                                Layout.fillWidth: true
                                topPadding: Math.round(17 * DefaultStyle.dp)
                                bottomPadding: Math.round(17 * DefaultStyle.dp)
                                leftPadding: Math.round(20 * DefaultStyle.dp)
                                rightPadding: Math.round(20 * DefaultStyle.dp)

                                contentItem: ColumnLayout {
                                    RowLayout {
                                        height: Math.round(50 * DefaultStyle.dp)
                                        visible: companyText.text.length != 0
                                        Text {
                                            //: "Société :"
                                            text: qsTr("contact_details_company_name")
                                            font {
                                                pixelSize: Typography.p2.pixelSize
                                                weight: Typography.p2.weight
                                            }
                                        }
                                        Text {
                                            id: companyText
                                            text: mainItem.selectedContact
                                                  && mainItem.selectedContact.core.organization
                                            font {
                                                pixelSize: Typography.p1.pixelSize
                                                weight: Typography.p1.weight
                                            }
                                        }
                                    }
                                    RowLayout {
                                        height: Math.round(50 * DefaultStyle.dp)
                                        visible: jobText.text.length != 0
                                        Text {
                                            //: "Poste :"
                                            text: qsTr("contact_details_job_title")
                                            font {
                                                pixelSize: Typography.p2.pixelSize
                                                weight: Typography.p2.weight
                                            }
                                        }
                                        Text {
                                            id: jobText
                                            text: mainItem.selectedContact
                                                  && mainItem.selectedContact.core.job
                                            font {
                                                pixelSize: Typography.p1.pixelSize
                                                weight: Typography.p1.weight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ContactDetailLayout {
                            visible: !SettingsCpp.disableChatFeature
                            //: "Medias"
                            label: qsTr("contact_details_medias_title")
                            Layout.fillWidth: true
                            content: Button {
                                style: ButtonStyle.noBackground
                                contentItem: RowLayout {
                                    EffectImage {
                                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                                        imageSource: AppIcons.shareNetwork
                                        colorizationColor: DefaultStyle.main2_600
                                    }
                                    Text {
                                        //: "Afficher les medias partagés"
                                        text: qsTr("contact_details_medias_subtitle")
                                        font {
                                            pixelSize: Typography.p1.pixelSize
                                            weight: Typography.p1.weight
                                        }
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    EffectImage {
                                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                                        imageSource: AppIcons.rightArrow
                                        colorizationColor: DefaultStyle.main2_600
                                    }
                                }
                                onClicked: console.debug(
                                               "TODO : go to shared media")
                            }
                        }
                        ContactDetailLayout {
                            Layout.fillWidth: true
                            //: "Confiance"
                            label: qsTr("contact_details_trust_title")
                            icon: AppIcons.question
                            onTitleIconClicked: trustInfoDialog.open()
                            content: ColumnLayout {
                                spacing: Math.round(13 * DefaultStyle.dp)
                                Text {
                                    //: "Niveau de confiance - Appareils vérifiés"
                                    text: qsTr("contact_dialog_devices_trust_title")
                                    font {
                                        pixelSize: Typography.p2.pixelSize
                                        weight: Typography.p2.weight
                                    }
                                }
                                Text {
                                    visible: deviceList.count === 0
                                    //: "Aucun appareil"
                                    text: qsTr("contact_details_no_device_found")
                                }
                                ProgressBar {
                                    visible: deviceList.count > 0
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
                                    value: mainItem.selectedContact ? mainItem.selectedContact.core.verifiedDeviceCount / deviceList.count : 0
                                }
                                ListView {
                                    id: deviceList
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.min(
                                                                Math.round(200 * DefaultStyle.dp),
                                                                contentHeight)
                                    clip: true
                                    model: mainItem.selectedContact ? mainItem.selectedContact.core.devices : []
                                    spacing: Math.round(16 * DefaultStyle.dp)
                                    delegate: RowLayout {
                                        id: deviceDelegate
                                        width: deviceList.width
                                        height: Math.round(30 * DefaultStyle.dp)
                                        property var listViewModelData: modelData
                                        property var callObj
                                        property CallGui deviceCall: callObj ? callObj.value : null
                                        //: "Appareil inconnu"
                                        property string deviceName: listViewModelData.name.length != 0 ? listViewModelData.name : qsTr("contact_device_without_name")
                                        Text {
                                            text: deviceDelegate.deviceName
                                            font.pixelSize: Math.round(14 * DefaultStyle.dp)
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        EffectImage {
                                            visible: listViewModelData.securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                                            imageSource: AppIcons.trusted
                                            Layout.preferredWidth: Math.round(22 * DefaultStyle.dp)
                                            Layout.preferredHeight: Math.round(22 * DefaultStyle.dp)
                                        }

                                        SmallButton {
                                            // Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
                                            visible: listViewModelData.securityLevel != LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                                            icon.source: AppIcons.warningCircle
                                            style: ButtonStyle.tertiary
                                            //: "Vérifier"
                                            text: qsTr("contact_make_call_check_device_trust")
                                            onClicked: {
                                                if (SettingsCpp.getDisplayDeviceCheckConfirmation(
                                                            )) {
                                                    verifyDevicePopup.deviceName
                                                            = deviceDelegate.deviceName
                                                    verifyDevicePopup.deviceAddress
                                                            = listViewModelData.address
                                                    verifyDevicePopup.open()
                                                } else {
                                                    UtilsCpp.createCall(
                                                                listViewModelData.address,
                                                                {},
                                                                LinphoneEnums.MediaEncryption.Zrtp)
                                                    parent.callObj = UtilsCpp.getCallByAddress(
                                                                listViewModelData.address)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ContactDetailLayout {
                            Layout.fillWidth: true
                            //: "Autres actions"
                            label: qsTr("contact_details_actions_title")
                            content: ColumnLayout {
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                    icon.source: AppIcons.pencil
                                    //: "Éditer"
                                    text: qsTr("contact_details_edit")
                                    onClicked: mainItem.editContact(
                                                   mainItem.selectedContact)
                                    visible: !mainItem.selectedContact?.core.readOnly
                                    style: ButtonStyle.noBackground
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                    color: DefaultStyle.main2_200
                                }
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                    icon.source: mainItem.selectedContact
                                                 && mainItem.selectedContact.core.starred ? AppIcons.heartFill : AppIcons.heart
                                    text: mainItem.selectedContact
                                          && mainItem.selectedContact.core.starred
                                          //: "Retirer des favoris"
                                          ? qsTr("contact_details_remove_from_favourites")
                                          //: "Ajouter aux favoris"
                                          : qsTr("contact_details_add_to_favourites")
                                    style: ButtonStyle.noBackground
                                    onClicked: if (mainItem.selectedContact)
                                                   mainItem.selectedContact.core.lSetStarred(
                                                               !mainItem.selectedContact.core.starred)
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                    color: DefaultStyle.main2_200
                                }
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                    icon.source: AppIcons.shareNetwork
                                    //: "Partager"
                                    text: qsTr("contact_details_share")
                                    style: ButtonStyle.noBackground
                                    onClicked: {
                                        if (mainItem.selectedContact) {
                                            var vcard = mainItem.selectedContact.core.getVCard()
                                            var username = mainItem.selectedContact.core.givenName
                                                    + mainItem.selectedContact.core.familyName
                                            var filepath = UtilsCpp.createVCardFile(
                                                        username, vcard)
                                            if (filepath == "")
                                                UtilsCpp.showInformationPopup(
                                                            qsTr("information_popup_error_title"),
                                                            //: "La création du fichier vcard a échoué"
                                                            qsTr("contact_details_share_error_mesage"),
                                                            false)
                                            else
                                                mainWindow.showInformationPopup(
                                                            //: "VCard créée"
                                                            qsTr("contact_details_share_success_title"),
                                                            //: "VCard du contact enregistrée dans %1"
                                                            qsTr("contact_details_share_success_mesage").arg(filepath))
                                            UtilsCpp.shareByEmail(
                                                        //: "Partage de contact"
                                                        qsTr("contact_details_share_email_title"),
                                                        vcard, filepath)
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                    color: DefaultStyle.main2_200
                                }
                                // IconLabelButton {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                // 	icon.source: AppIcons.bellSlash
                                // 	text: qsTr("Mettre en sourdine")
                                // 	onClicked: console.log("TODO : mute contact")
                                // }
                                // Rectangle {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                // 	color: DefaultStyle.main2_200
                                // }
                                // IconLabelButton {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                // 	icon.source: AppIcons.empty
                                // 	text: qsTr("Bloquer")
                                // 	onClicked: console.log("TODO : block contact")
                                // }
                                // Rectangle {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                                // 	color: DefaultStyle.main2_200
                                // }
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                                    icon.source: AppIcons.trashCan
                                    //: "Supprimer ce contact"
                                    text: qsTr("contact_details_delete")
                                    visible: !mainItem.selectedContact?.core.readOnly
                                    onClicked: {
                                        mainItem.deleteContact(
                                                    mainItem.selectedContact)
                                    }
                                    style: ButtonStyle.noBackgroundRed
                                }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: contactEdition
        ContactEdition {
            property string objectName: "contactEdition"
            onCloseEdition: redirectAddress => {
                                goToContactDetails()
                                if (redirectAddress) {
                                    initialFriendToDisplay = redirectAddress
                                }
                            }
        }
    }
}
