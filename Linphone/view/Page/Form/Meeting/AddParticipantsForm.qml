import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

FocusScope {
    id: mainItem
    //: "Rechercher des contacts"
    property string placeHolderText: qsTr("search_bar_search_contacts_placeholder")
    property list<string> selectedParticipants
    property int selectedParticipantsCount: selectedParticipants.length
    property ConferenceInfoGui conferenceInfoGui
    property color searchBarColor: DefaultStyle.grey_100
    property color searchBarBorderColor: "transparent"
    property int participantscSrollBarRightMargin: Utils.getSizeWithScreenRatio(8)

    function clearSelectedParticipants() {
    // TODO
    //contactList.selectedContacts.clear()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Utils.getSizeWithScreenRatio(15)
        GridView {
            id: participantList
            Layout.fillWidth: true
            visible: contentHeight > 0
            Layout.preferredHeight: contentHeight
            Layout.maximumHeight: mainItem.height / 3
            width: mainItem.width
            cellWidth: Utils.getSizeWithScreenRatio((50 + 18))
            cellHeight: Utils.getSizeWithScreenRatio(80)
            // columnCount: Math.floor(width/cellWidth)
            model: mainItem.selectedParticipants
            clip: true
            // columnSpacing: Utils.getSizeWithScreenRatio(18)
            // rowSpacing: Utils.getSizeWithScreenRatio(9)
            Keys.onPressed: event => {
                if (currentIndex <= 0 && event.key == Qt.Key_Up) {
                    nextItemInFocusChain(false).forceActiveFocus();
                }
            }
            header: ColumnLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    visible: mainItem.selectedParticipantsCount > 0
                    //: "%n participant(s) sélectionné(s)"
                    text: qsTr("add_participant_selected_count", '0', mainItem.selectedParticipantsCount).arg(mainItem.selectedParticipantsCount)
                    maximumLineCount: 1
                    color: DefaultStyle.grey_1000
                    font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(300)
                    }
                }
                Item {
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(10)
                }
            }
            delegate: FocusScope {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Utils.getSizeWithScreenRatio(4)
                    width: Utils.getSizeWithScreenRatio(50)
                    Item {
                        id: participantItem
                        property var nameObj: UtilsCpp.getDisplayName(modelData)
                        property string displayName: nameObj ? nameObj.value : ""
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(50)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(50)
                        Avatar {
                            anchors.fill: parent
                            _address: modelData
                            shadowEnabled: false
                            secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                        }
                        Button {
                            width: Utils.getSizeWithScreenRatio(17)
                            height: Utils.getSizeWithScreenRatio(17)
                            icon.width: Utils.getSizeWithScreenRatio(12)
                            icon.height: Utils.getSizeWithScreenRatio(12)
                            icon.source: AppIcons.closeX
                            anchors.top: parent.top
                            anchors.right: parent.right
                            //: Remove participant %1
                            Accessible.name: qsTr("remove_participant_accessible_name").arg(participantItem.displayName)
                            style: ButtonStyle.whiteSelected
                            shadowEnabled: true
                            onClicked: contactList.removeSelectedContactByAddress(modelData)
                        }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: width
                        width: Utils.getSizeWithScreenRatio(50)
                        maximumLineCount: 1
                        clip: true
                        text: participantItem.displayName
                        color: DefaultStyle.main2_700
                        wrapMode: Text.WrapAnywhere
                        font {
                            pixelSize: Typography.p3.pixelSize
                            weight: Typography.p3.weight
                            capitalization: Font.Capitalize
                        }
                    }
                }
            }
            Control.ScrollBar.vertical: ScrollBar {
                id: scrollbar
                active: true
                interactive: true
                policy: Control.ScrollBar.AsNeeded
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: mainItem.participantscSrollBarRightMargin
                visible: participantList.height < participantList.contentHeight
            }
        }
        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            Layout.topMargin: Utils.getSizeWithScreenRatio(6)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(28)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
            placeholderText: mainItem.placeHolderText
            focus: participantList.count == 0
            color: mainItem.searchBarColor
            borderColor: mainItem.searchBarColor
            KeyNavigation.up: participantList.count > 0 ? participantList : nextItemInFocusChain(false)
            KeyNavigation.down: contactList
        }
        ColumnLayout {
            id: content
            spacing: Utils.getSizeWithScreenRatio(15)
            Text {
                visible: !contactList.loading && contactList.count === 0
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Utils.getSizeWithScreenRatio(137)
                //: "Aucun contact"
                text: searchBar.text.length !== 0 ? qsTr("list_filter_no_result_found") : qsTr("contact_list_empty")
                font {
                    pixelSize: Typography.h4.pixelSize
                    weight: Typography.h4.weight
                }
            }
            AllContactListView {
                id: contactList
                Layout.fillWidth: true
                Layout.fillHeight: true
                itemsRightMargin: Utils.getSizeWithScreenRatio(28)
                multiSelectionEnabled: true
                showContactMenu: false
                showMe: false
                confInfoGui: mainItem.conferenceInfoGui
                selectedContacts: mainItem.selectedParticipants
                onSelectedContactsChanged: Qt.callLater(function () {
                    mainItem.selectedParticipants = selectedContacts;
                })
                searchBarText: searchBar.text
                onContactAddedToSelection: address => {
                    contactList.addContactToSelection(address);
                }
                onContactRemovedFromSelection: address => contactList.removeSelectedContactByAddress(address)
            }
        }
    }
}
