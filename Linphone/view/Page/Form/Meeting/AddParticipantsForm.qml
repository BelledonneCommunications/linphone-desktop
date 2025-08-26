import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

FocusScope{
	id: mainItem
    //: "Rechercher des contacts"
    property string placeHolderText: qsTr("search_bar_search_contacts_placeholder")
	property list<string> selectedParticipants
	property int selectedParticipantsCount: selectedParticipants.length
	property ConferenceInfoGui conferenceInfoGui
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	property int participantscSrollBarRightMargin: Math.round(8 * DefaultStyle.dp)

	function clearSelectedParticipants() {
		// TODO
		//contactList.selectedContacts.clear()
	}

	ColumnLayout {
		anchors.fill: parent
        spacing: Math.round(15 * DefaultStyle.dp)
		GridView {
			id: participantList
			Layout.fillWidth: true
			visible: contentHeight > 0
			Layout.preferredHeight: contentHeight
			Layout.maximumHeight: mainItem.height / 3
			width: mainItem.width
			cellWidth: Math.round((50 + 18) * DefaultStyle.dp)
			cellHeight: Math.round(80 * DefaultStyle.dp)
			// columnCount: Math.floor(width/cellWidth)
			model: mainItem.selectedParticipants
			clip: true
        	// columnSpacing: Math.round(18 * DefaultStyle.dp)
        	// rowSpacing: Math.round(9 * DefaultStyle.dp)
			Keys.onPressed: (event) => {
				if(currentIndex <=0 && event.key == Qt.Key_Up){
					nextItemInFocusChain(false).forceActiveFocus()
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
						pixelSize: Math.round(12 * DefaultStyle.dp)
						weight: Math.round(300 * DefaultStyle.dp)
					}
				}
				Item {
					Layout.preferredHeight: Math.round(10 * DefaultStyle.dp)
				}
			}
			delegate: FocusScope {
				ColumnLayout {
					anchors.fill: parent
                    spacing: Math.round(4 * DefaultStyle.dp)
					width: Math.round(50 * DefaultStyle.dp)
					Item {
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: Math.round(50 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
						Avatar {
							anchors.fill: parent
							_address: modelData
							shadowEnabled: false
							secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
						}
						Button {
							Layout.preferredWidth: Math.round(17 * DefaultStyle.dp)
							Layout.preferredHeight: Math.round(17 * DefaultStyle.dp)
							icon.width: Math.round(12 * DefaultStyle.dp)
							icon.height: Math.round(12 * DefaultStyle.dp)
							icon.source: AppIcons.closeX
							anchors.top: parent.top
							anchors.right: parent.right
							background: Item {
								Rectangle {
									id: backgroundRect
									color: DefaultStyle.grey_0
									anchors.fill: parent
									radius: Math.round(50 * DefaultStyle.dp)
								}
								MultiEffect {
									anchors.fill: backgroundRect
									source: backgroundRect
									shadowEnabled: true
									shadowColor: DefaultStyle.grey_1000
									shadowBlur: 0.1
									shadowOpacity: 0.5
								}
							}
							onClicked: contactList.removeSelectedContactByAddress(modelData)
						}
					}
					Text {
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: width
						width: Math.round(50 * DefaultStyle.dp)
						maximumLineCount: 1
						clip: true
						property var nameObj: UtilsCpp.getDisplayName(modelData)
						text: nameObj ? nameObj.value : ""
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
            Layout.topMargin: Math.round(6 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(28 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
			placeholderText: mainItem.placeHolderText
			focus: participantList.count == 0
			color: mainItem.searchBarColor
			borderColor: mainItem.searchBarColor
			KeyNavigation.up: participantList.count > 0
								? participantList
								: nextItemInFocusChain(false)
			KeyNavigation.down: contactList
		}
		ColumnLayout {
			id: content
            spacing: Math.round(15 * DefaultStyle.dp)
			Text {
				visible: !contactList.loading && contactList.count === 0
				Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Math.round(137 * DefaultStyle.dp)
                //: "Aucun contact"
                text: searchBar.text.length !== 0 ? qsTr("list_filter_no_result_found") : qsTr("contact_list_empty")
				font {
                    pixelSize: Typography.h4.pixelSize
                    weight: Typography.h4.weight
				}
			}
			AllContactListView{
				id: contactList
				Layout.fillWidth: true
				Layout.fillHeight: true
                itemsRightMargin: Math.round(28 * DefaultStyle.dp)
				multiSelectionEnabled: true
				showContactMenu: false
				confInfoGui: mainItem.conferenceInfoGui
				selectedContacts: mainItem.selectedParticipants
				onSelectedContactsChanged: Qt.callLater(function(){mainItem.selectedParticipants = selectedContacts})
				searchBarText: searchBar.text
				onContactAddedToSelection: (address) => {
					contactList.addContactToSelection(address)
				}
				onContactRemovedFromSelection: (address) => contactList.removeSelectedContactByAddress(address)
			}
		}
	}
}
