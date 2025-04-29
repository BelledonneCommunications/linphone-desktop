import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

FocusScope {
    id: mainItem
    implicitHeight: visible ? Math.round(56 * DefaultStyle.dp) : 0
    property var searchResultItem
    property bool showInitials: true // Display Initials of Display name.
    property bool showDefaultAddress: true // Display address below display name.
    property bool showActions: false // Display actions layout (call buttons)
    property bool showContactMenu: true // Display the dot menu for contacts.
    property string highlightText
    property string addressFromFilter: UtilsCpp.getAddressToDisplay(searchResultItem.core.addresses, highlightText, searchResultItem.core.defaultAddress)

    // Bold characters in Display name.
    property bool displayNameCapitalization: true // Capitalize display name.

    property bool selectionEnabled: true // Contact can be selected
    property bool multiSelectionEnabled: false //Multiple items can be selected.
    property list<string> selectedContacts
    // List of default address on selected contacts.
    property bool isSelected: false // selected in list => currentIndex == index
    property bool isLastHovered: false

    property var previousInitial
    // Use directly previous initial
    property real itemsRightMargin: Math.round(39 * DefaultStyle.dp)

    property var displayName: searchResultItem.core.fullName
    property string initial: displayName ? displayName[0].toLocaleLowerCase(
                                               ConstantsCpp.DefaultLocale) : ''

    signal clicked(var mouse)
    signal contactDeletionRequested(FriendGui contact)
    signal containsMouseChanged(bool containsMouse)

    Text {
        id: initial
        anchors.left: parent.left
        visible: mainItem.showInitials
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Math.round(15 * DefaultStyle.dp)
        verticalAlignment: Text.AlignVCenter
        width: Math.round(20 * DefaultStyle.dp)
        opacity: previousInitial != mainItem.initial ? 1 : 0
        text: mainItem.initial
        color: DefaultStyle.main2_400
        font {
            pixelSize: Math.round(20 * DefaultStyle.dp)
            weight: Math.round(500 * DefaultStyle.dp)
            capitalization: Font.AllUppercase
        }
    }
    RowLayout {
        id: contactDelegate
        anchors.left: initial.visible ? initial.right : parent.left
        anchors.right: parent.right
        anchors.rightMargin: mainItem.itemsRightMargin
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: Math.round(16 * DefaultStyle.dp)
        z: 1
        Avatar {
            Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(5 * DefaultStyle.dp)
            contact: searchResultItem
            shadowEnabled: false
        }
        ColumnLayout {
            spacing: 0
            Text {
                text: UtilsCpp.boldTextPart(mainItem.displayName,
                                            mainItem.highlightText)
                font {
                    pixelSize: mainItem.showDefaultAddress ? Typography.h4.pixelSize : Typography.p1.pixelSize
                    capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
                    weight: mainItem.showDefaultAddress ? Typography.h4.weight : Typography.p1.weight
                }
                maximumLineCount: 1
                Layout.fillWidth: true
            }
            Text {
                Layout.topMargin: Math.round(2 * DefaultStyle.dp)
                Layout.fillWidth: true
                visible: mainItem.showDefaultAddress
                property string address: SettingsCpp.onlyDisplaySipUriUsername
                    ? UtilsCpp.getUsername(mainItem.addressFromFilter)
                    : mainItem.addressFromFilter
                text: UtilsCpp.boldTextPart(address, mainItem.highlightText)
                maximumLineCount: 1
                elide: Text.ElideRight
                font {
                    weight: Math.round(300 * DefaultStyle.dp)
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
        RowLayout {
            id: actionsRow
            z: 1
            visible: mainItem.showActions || actionButtons.visible || mainItem.showContactMenu || mainItem.multiSelectionEnabled
            spacing: visible ? Math.round(16 * DefaultStyle.dp) : 0
            enabled: visible
            Layout.rightMargin: Math.round(5 * DefaultStyle.dp)
            EffectImage {
                id: isSelectedCheck
                visible: mainItem.multiSelectionEnabled
                            && (mainItem.selectedContacts.indexOf(mainItem.addressFromFilter) != -1)
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                imageSource: AppIcons.check
                colorizationColor: DefaultStyle.main1_500_main
            }
            RowLayout {
                id: actionButtons
                visible: mainItem.showActions
                spacing: visible ? Math.round(10 * DefaultStyle.dp) : 0
                IconButton {
                    id: callButton
                    Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
                    icon.source: AppIcons.phone
                    focus: visible
                    radius: Math.round(40 * DefaultStyle.dp)
                    style: ButtonStyle.grey
                    onClicked: UtilsCpp.createCall(mainItem.addressFromFilter)
                    KeyNavigation.left: chatButton
                    KeyNavigation.right: videoCallButton
                }
                IconButton {
                    id: videoCallButton
                    visible: SettingsCpp.videoEnabled
                    Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
                    icon.source: AppIcons.videoCamera
                    focus: visible && !callButton.visible
                    radius: Math.round(40 * DefaultStyle.dp)
                    style: ButtonStyle.grey
                    onClicked: UtilsCpp.createCall(mainItem.addressFromFilter, {"localVideoEnabled": true})
                    KeyNavigation.left: callButton
                    KeyNavigation.right: chatButton
                }
                IconButton {
                    id: chatButton
                    visible: actionButtons.visible
                                && !SettingsCpp.disableChatFeature
                    Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
                    icon.source: AppIcons.chatTeardropText
                    focus: visible && !callButton.visible
                            && !videoCallButton.visible
                    radius: Math.round(40 * DefaultStyle.dp)
                    style: ButtonStyle.grey
                    KeyNavigation.left: videoCallButton
                    KeyNavigation.right: callButton
                    onClicked: {
                        console.debug("[ContactListItem.qml] Open conversation")
                        mainWindow.displayChatPage(mainItem.addressFromFilter)
                    }
                }
            }
            PopupButton {
                id: friendPopup
                z: 1
                popup.x: 0
                popup.padding: Math.round(10 * DefaultStyle.dp)
                visible: mainItem.showContactMenu && (contactArea.containsMouse || mainItem.isLastHovered || hovered || popup.opened)
                enabled: visible

                popup.contentItem: ColumnLayout {
                    IconLabelButton {
                        Layout.fillWidth: true
                        visible: searchResultItem.core.isStored
                                    && !searchResultItem.core.readOnly
                        //: "Enlever des favoris"
                        text: searchResultItem.core.starred ? qsTr("contact_details_remove_from_favourites")
                                                                //: "Ajouter aux favoris"
                                                            : qsTr("contact_details_add_to_favourites")
                        icon.source: searchResultItem.core.starred ? AppIcons.heartFill : AppIcons.heart
                        spacing: Math.round(10 * DefaultStyle.dp)
                        textColor: DefaultStyle.main2_500main
                        hoveredImageColor: searchResultItem.core.starred ? DefaultStyle.main1_700 : DefaultStyle.danger_700
                        contentImageColor: searchResultItem.core.starred ? DefaultStyle.danger_500main : DefaultStyle.main2_600
                        onClicked: {
                            searchResultItem.core.lSetStarred(
                                        !searchResultItem.core.starred)
                            friendPopup.close()
                        }
                        style: ButtonStyle.noBackground
                    }
                    IconLabelButton {
                        text: qsTr("Partager")
                        Layout.fillWidth: true
                        icon.source: AppIcons.shareNetwork
                        spacing: Math.round(10 * DefaultStyle.dp)
                        textColor: DefaultStyle.main2_500main
                        onClicked: {
                            var vcard = searchResultItem.core.getVCard()
                            var username = searchResultItem.core.givenName
                                    + searchResultItem.core.familyName
                            var filepath = UtilsCpp.createVCardFile(
                                        username, vcard)
                            if (filepath == "")
                                UtilsCpp.showInformationPopup(
                                            qsTr("information_popup_error_title"),
                                            //: La création du fichier vcard a échoué
                                            qsTr("information_popup_vcard_creation_error"),
                                            false)
                            else
                                //: VCard créée
                                mainWindow.showInformationPopup(qsTr("information_popup_vcard_creation_title"),
                                                                //: "VCard du contact enregistrée dans %1"
                                                                qsTr("information_popup_vcard_creation_success").arg(filepath))
                            //: Partage de contact
                            UtilsCpp.shareByEmail(qsTr("contact_sharing_email_title"),vcard, filepath)
                        }
                        style: ButtonStyle.noBackground
                    }
                    IconLabelButton {
                        //: "Supprimer"
                        text: qsTr("contact_details_delete")
                        icon.source: AppIcons.trashCan
                        spacing: Math.round(10 * DefaultStyle.dp)
                        visible: !searchResultItem.core.readOnly
                        Layout.fillWidth: true
                        onClicked: {
                            mainItem.contactDeletionRequested(
                                        searchResultItem)
                            friendPopup.close()
                        }
                        style: ButtonStyle.noBackgroundRed
                    }
                }
            }
        }
    }

    MouseArea {
        id: contactArea
        enabled: mainItem.selectionEnabled
        anchors.fill: contactDelegate
        //height: mainItem.height
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        z: -1
        focus: !actionButtons.visible
        onContainsMouseChanged: {
            mainItem.containsMouseChanged(containsMouse)
        }
        Rectangle {
            anchors.fill: contactArea
            radius: Math.round(8 * DefaultStyle.dp)
            opacity: 0.7
            color: mainItem.isSelected ? DefaultStyle.main2_200 : DefaultStyle.main2_100
            visible: mainItem.isLastHovered || mainItem.isSelected || friendPopup.hovered
        }
        Keys.onPressed: event => {
                            if (event.key == Qt.Key_Space
                                || event.key == Qt.Key_Enter
                                || event.key == Qt.Key_Return) {
                                contactArea.clicked(undefined)
                                event.accepted = true
                            }
                        }
        onClicked: mouse => {
                       forceActiveFocus()
                       if (mouse && mouse.button == Qt.RightButton
                           && mainItem.showContactMenu) {
                           if (friendPopup) friendPopup.open()
                       } else {
                           mainItem.clicked(mouse)
                       }
                   }
    }
}
