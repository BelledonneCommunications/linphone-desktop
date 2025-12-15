import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import EnumsToStringCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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
        console.log("selected contact changed, go to contact details")
        // if we are editing a contact, force staying on edition page
        if (!rightPanelStackView.currentItem
            || rightPanelStackView.currentItem.objectName != "contactEdition") {
            goToContactDetails()
        }
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
        padding: Utils.getSizeWithScreenRatio(30)
        width: Utils.getSizeWithScreenRatio(637)
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
                spacing: Utils.getSizeWithScreenRatio(7)
                CheckBox {
                    id: neverDisplayAgainCheckbox
                }
                Text {
                    //: Ne plus afficher
                    text: qsTr("popup_do_not_show_again")
                    font.pixelSize: Utils.getSizeWithScreenRatio(14)
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
                spacing: Utils.getSizeWithScreenRatio(15)
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
        width: Utils.getSizeWithScreenRatio(637)
        //: "Niveau de confiance"
        title: qsTr("contact_dialog_devices_trust_help_title")
        //: "Vérifiez les appareils de votre contact pour confirmer que vos communications seront sécurisées et sans compromission. <br>Quand tous seront vérifiés, vous atteindrez le niveau de confiance maximal."
        text: qsTr("contact_dialog_devices_trust_help_message")
        content: RowLayout {
            spacing: Utils.getSizeWithScreenRatio(50)
            Avatar {
                displayNameVal: "A C"
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
            }
            EffectImage {
                imageSource: AppIcons.arrowRight
                colorizationColor: DefaultStyle.main2_600
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
            }
            Avatar {
                displayNameVal: "A C"
                secured: true
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
            }
        }
        buttons: Button {
            //: "Ok"
            text: qsTr("dialog_ok")
            style: ButtonStyle.main
            leftPadding: Utils.getSizeWithScreenRatio(30)
            rightPadding: Utils.getSizeWithScreenRatio(30)
            onClicked: trustInfoDialog.close()
        }
    }

    leftPanelContent: FocusScope {
        id: leftPanel
        property real leftMargin: Utils.getSizeWithScreenRatio(45)
        property real rightMargin: Utils.getSizeWithScreenRatio(39)
        Layout.fillHeight: true
        Layout.fillWidth: true

        FlexboxLayout {
            id: title
            direction: FlexboxLayout.Row
            gap: Utils.getSizeWithScreenRatio(16)
            alignItems: FlexboxLayout.AlignCenter
            anchors.top: leftPanel.top
            anchors.right: leftPanel.right
            anchors.left: leftPanel.left
            anchors.leftMargin: leftPanel.leftMargin
            anchors.rightMargin: leftPanel.rightMargin
            Layout.fillHeight: false
            Text {
                Layout.fillWidth: true
                //: "Contacts"
                text: qsTr("bottom_navigation_contacts_label")
                color: DefaultStyle.main2_700
                font.pixelSize: Typography.h2.pixelSize
                font.weight: Typography.h2.weight
            }
            Button {
                id: createContactButton
                visible: !rightPanelStackView.currentItem
                         || rightPanelStackView.currentItem.objectName !== "contactEdition"
                style: ButtonStyle.noBackground
                icon.source: AppIcons.plusCircle
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(28)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
                icon.width: Utils.getSizeWithScreenRatio(28)
                icon.height: Utils.getSizeWithScreenRatio(28)
                onClicked: {
                    mainItem.createContact("", "")
                }
                KeyNavigation.down: searchBar
                //: Create new contact
                Accessible.name: qsTr("create_contact_accessible_name")
            }
        }

        ColumnLayout {
            anchors.top: title.bottom
            anchors.right: leftPanel.right
            anchors.left: leftPanel.left
            anchors.leftMargin: leftPanel.leftMargin
            anchors.bottom: leftPanel.bottom
            enabled: mainItem.leftPanelEnabled
            spacing: Utils.getSizeWithScreenRatio(38)
            SearchBar {
                id: searchBar
                visible: contactList.haveContacts || text.length !== 0
                Layout.rightMargin: leftPanel.rightMargin
                Layout.topMargin: Utils.getSizeWithScreenRatio(18)
                Layout.fillWidth: true
                //: Rechercher un contact
                placeholderText: qsTr("search_bar_look_for_contact_text")
                KeyNavigation.up: createContactButton
                KeyNavigation.down: contactList
            }
            ColumnLayout {
                id: content
                spacing: Utils.getSizeWithScreenRatio(15)
                Text {
                    visible: !contactList.loading && !contactList.haveContacts
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Utils.getSizeWithScreenRatio(137)
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
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(8)
                    searchBarText: searchBar.text
                    hideSuggestions: true
                    sourceFlags: LinphoneEnums.MagicSearchSource.Friends
                                 | LinphoneEnums.MagicSearchSource.FavoriteFriends
                                 | LinphoneEnums.MagicSearchSource.LdapServers
                                 | LinphoneEnums.MagicSearchSource.RemoteCardDAV
                    onHighlightedContactChanged: mainItem.selectedContact = highlightedContact
                    onContactDeletionRequested: contact => {
                        mainItem.deleteContact(contact)
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
                spacing: Utils.getSizeWithScreenRatio(15)
                property string label
                property var icon
                property alias content: contentControl.contentItem
                signal titleIconClicked
                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(10)
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
                        //: More info %1
                        Accessible.name: qsTr("more_info_accessible_name").arg(contactDetailLayout.label)
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
                        Accessible.name: (checked ?
                            //: Shrink %1
                            qsTr("shrink_accessible_name"):
                            //: Expand %1
                            qsTr("expand_accessible_name")).arg(contactDetailLayout.label)

                    }
                }
                RoundedPane {
                    id: contentControl
                    visible: expandButton.checked
                    Layout.fillWidth: true
                    leftPadding: Utils.getSizeWithScreenRatio(20)
                    rightPadding: Utils.getSizeWithScreenRatio(20)
                    topPadding: Utils.getSizeWithScreenRatio(17)
                    bottomPadding: Utils.getSizeWithScreenRatio(17)
                }
            }
            ContactLayout {
                id: contactDetail
                anchors.fill: parent
                contact: mainItem.selectedContact
                button.color: DefaultStyle.main1_100
                //: Edit
                button.text: qsTr("contact_details_edit")
                button.style: ButtonStyle.tertiary
                button.icon.source: AppIcons.pencil
                button.onClicked: mainItem.editContact(mainItem.selectedContact)
                button.visible: mainItem.selectedContact && mainItem.selectedContact.core.isStored && !mainItem.selectedContact.core.readOnly
                property string contactAddress: contact ? contact.core.defaultAddress : ""
                property var computedContactNameObj: UtilsCpp.getDisplayName(contactAddress)
                property string computedContactName: computedContactNameObj ? computedContactNameObj.value : ""
                property string contactName: contact ? contact.core.fullName : computedContactName
                component ActionsButtons: RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(58)
                    LabelButton {
                        button.icon.source: AppIcons.phone
                        //: "Appel"
                        label: qsTr("contact_call_action")
                        width: Utils.getSizeWithScreenRatio(56)
                        height: Utils.getSizeWithScreenRatio(56)
                        button.icon.width: Utils.getSizeWithScreenRatio(24)
                        button.icon.height: Utils.getSizeWithScreenRatio(24)
                        button.onClicked: mainWindow.startCallWithContact(contactDetail.contact, false, mainItem)
                    }
                    LabelButton {
                        button.icon.source: AppIcons.chatTeardropText
                        visible: !SettingsCpp.disableChatFeature
                        //: "Message"
                        label: qsTr("contact_message_action")
                        width: Utils.getSizeWithScreenRatio(56)
                        height: Utils.getSizeWithScreenRatio(56)
                        button.icon.width: Utils.getSizeWithScreenRatio(24)
                        button.icon.height: Utils.getSizeWithScreenRatio(24)
                        button.onClicked: {
                            console.debug("[ContactLayout.qml] Open conversation")
                            mainWindow.sendMessageToContact(contactDetail.contact)
                        }
                    }
                    LabelButton {
                        visible: SettingsCpp.videoEnabled
                        button.icon.source: AppIcons.videoCamera
                        //: "Appel vidéo"
                        label: qsTr("contact_video_call_action")
                        width: Utils.getSizeWithScreenRatio(56)
                        height: Utils.getSizeWithScreenRatio(56)
                        button.icon.width: Utils.getSizeWithScreenRatio(24)
                        button.icon.height: Utils.getSizeWithScreenRatio(24)
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
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            text: contactDetail.contact ? contactDetail.contact.core.presenceStatus : ""
                            color: contactDetail.contact ? contactDetail.contact.core.presenceColor : 'transparent'
                            font.pixelSize: Utils.getSizeWithScreenRatio(14)
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
                        spacing: Utils.getSizeWithScreenRatio(32)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        ColumnLayout {
                            spacing: Utils.getSizeWithScreenRatio(15)
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
                                    spacing: Utils.getSizeWithScreenRatio(9)
                                    model: VariantList {
                                        model: (mainItem.selectedContact ? UtilsCpp.append(mainItem.selectedContact.core.addresses, mainItem.selectedContact.core.phoneNumbers) : [])
                                    }
                                    delegate: Item {
                                        property var listViewModelData: modelData
                                        width: addrList.width
                                        height: Utils.getSizeWithScreenRatio(46)

                                        ColumnLayout {
                                            anchors.fill: parent
                                            // anchors.topMargin: Utils.getSizeWithScreenRatio(5)
                                            RowLayout {
                                                Layout.fillWidth: true
                                                // Layout.fillHeight: true
                                                // Layout.alignment: Qt.AlignVCenter
                                                // Layout.topMargin: Utils.getSizeWithScreenRatio(10)
                                                // Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
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
                                                        text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(_text) : _text
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
                                                    //: Call address %1
                                                    Accessible.name: qsTr("call_adress_accessible_name").arg(listViewModelData.address)
                                                }
                                            }

                                            Rectangle {
                                                visible: index != addrList.model.count - 1
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                                Layout.rightMargin: Utils.getSizeWithScreenRatio(3)
                                                Layout.leftMargin: Utils.getSizeWithScreenRatio(3)
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
                                topPadding: Utils.getSizeWithScreenRatio(17)
                                bottomPadding: Utils.getSizeWithScreenRatio(17)
                                leftPadding: Utils.getSizeWithScreenRatio(20)
                                rightPadding: Utils.getSizeWithScreenRatio(20)

                                contentItem: ColumnLayout {
                                    RowLayout {
                                        height: Utils.getSizeWithScreenRatio(50)
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
                                        height: Utils.getSizeWithScreenRatio(50)
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
                            visible: false//!SettingsCpp.disableChatFeature
                            //: "Medias"
                            label: qsTr("contact_details_medias_title")
                            Layout.fillWidth: true
                            content: Button {
                                style: ButtonStyle.noBackground
                                contentItem: RowLayout {
                                    EffectImage {
                                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
                                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                                        imageSource: AppIcons.rightArrow
                                        colorizationColor: DefaultStyle.main2_600
                                    }
                                }
                                onClicked: console.debug(
                                               "TODO : go to shared media")
                                Accessible.name: qsTr("contact_details_medias_subtitle")
                            }
                        }
                        ContactDetailLayout {
                            Layout.fillWidth: true
                            //: "Confiance"
                            label: qsTr("contact_details_trust_title")
                            icon: AppIcons.question
                            onTitleIconClicked: trustInfoDialog.open()
                            content: ColumnLayout {
                                spacing: Utils.getSizeWithScreenRatio(13)
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
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
                                    value: mainItem.selectedContact ? mainItem.selectedContact.core.verifiedDeviceCount / deviceList.count : 0
                                }
                                ListView {
                                    id: deviceList
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.min(
                                                               Utils.getSizeWithScreenRatio(200),
                                                                contentHeight)
                                    clip: true
                                    model: mainItem.selectedContact ? mainItem.selectedContact.core.devices : []
                                    spacing: Utils.getSizeWithScreenRatio(16)
                                    delegate: RowLayout {
                                        id: deviceDelegate
                                        width: deviceList.width
                                        height: Utils.getSizeWithScreenRatio(30)
                                        property var listViewModelData: modelData
                                        property var callObj
                                        property CallGui deviceCall: callObj ? callObj.value : null
                                        //: "Appareil inconnu"
                                        property string deviceName: listViewModelData.name.length != 0 ? listViewModelData.name : qsTr("contact_device_without_name")
                                        Text {
                                            text: deviceDelegate.deviceName
                                            font.pixelSize: Utils.getSizeWithScreenRatio(14)
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        EffectImage {
                                            visible: listViewModelData.securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                                            imageSource: AppIcons.trusted
                                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(22)
                                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(22)
                                        }

                                        SmallButton {
                                            // Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
                                            visible: listViewModelData.securityLevel != LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                                            icon.source: AppIcons.warningCircle
                                            style: ButtonStyle.tertiary
                                            //: "Vérifier"
                                            text: qsTr("contact_make_call_check_device_trust")
                                            //: Verify %1 device
                                            Accessible.name: qsTr("verify_device_accessible_name").arg(deviceDelegate.deviceName)
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
                                spacing: Utils.getSizeWithScreenRatio(10)
                                ColumnLayout {
                                    visible: mainItem.selectedContact && mainItem.selectedContact.core.isStored && !mainItem.selectedContact.core.readOnly
                                    IconLabelButton {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                                        icon.source: AppIcons.pencil
                                        //: "Éditer"
                                        text: qsTr("contact_details_edit")
                                        onClicked: mainItem.editContact(mainItem.selectedContact)
                                        style: ButtonStyle.noBackground
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                        color: DefaultStyle.main2_200
                                    }
                                }
                                ColumnLayout {
                                    visible: mainItem.selectedContact && mainItem.selectedContact.core.isStored && !mainItem.selectedContact.core.readOnly
                                    IconLabelButton {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
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
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                        color: DefaultStyle.main2_200
                                    }
                                }
                                IconLabelButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
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
                                // IconLabelButton {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                                // 	icon.source: AppIcons.bellSlash
                                // 	text: qsTr("Mettre en sourdine")
                                // 	onClicked: console.log("TODO : mute contact")
                                // }
                                // Rectangle {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                // 	color: DefaultStyle.main2_200
                                // }
                                // IconLabelButton {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                                // 	icon.source: AppIcons.empty
                                // 	text: qsTr("Bloquer")
                                // 	onClicked: console.log("TODO : block contact")
                                // }
                                // Rectangle {
                                // 	Layout.fillWidth: true
                                // 	Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                // 	color: DefaultStyle.main2_200
                                // }
                                ColumnLayout {
                                    visible: mainItem.selectedContact && mainItem.selectedContact.core.isStored && !mainItem.selectedContact.core.readOnly
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                        color: DefaultStyle.main2_200
                                    }
                                    IconLabelButton {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                                        icon.source: AppIcons.trashCan
                                        //: "Supprimer ce contact"
                                        text: qsTr("contact_details_delete")
                                        onClicked: {
                                            mainItem.deleteContact(mainItem.selectedContact)
                                        }
                                        style: ButtonStyle.noBackgroundRed
                                    }
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
