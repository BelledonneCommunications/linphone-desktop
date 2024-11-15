import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

FocusScope{
	id: mainItem
	
	property string placeHolderText: qsTr("Rechercher des contacts")
	property list<string> selectedParticipants//: contactLoader.item ? contactLoader.item.selectedContacts
	property int selectedParticipantsCount: selectedParticipants.length
	property ConferenceInfoGui conferenceInfoGui
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"

	function clearSelectedParticipants() {
		// TODO
		//contactList.selectedContacts.clear()
	}

	ColumnLayout {
		anchors.fill: parent
		spacing: 15 * DefaultStyle.dp
		ListView {
			id: participantList
			Layout.fillWidth: true
			Layout.preferredHeight: contentHeight
			Layout.maximumHeight: mainItem.height / 3
			width: mainItem.width
			model: mainItem.selectedParticipants
			clip: true
			focus: participantList.count > 0
			Keys.onPressed: (event) => {
				if(currentIndex <=0 && event.key == Qt.Key_Up){
					nextItemInFocusChain(false).forceActiveFocus()
				}
			}
			delegate: FocusScope {
				height: 56 * DefaultStyle.dp
				width: participantList.width - scrollbar.implicitWidth - 28 * DefaultStyle.dp
				RowLayout {
					anchors.fill: parent
					spacing: 10 * DefaultStyle.dp
					Avatar {
						Layout.preferredWidth: 45 * DefaultStyle.dp
						Layout.preferredHeight: 45 * DefaultStyle.dp
						_address: modelData
					}
					Text {
						property var nameObj: UtilsCpp.getDisplayName(modelData)
						text: nameObj ? nameObj.value : ""
						font.pixelSize: 14 * DefaultStyle.dp
						font.capitalization: Font.Capitalize
					}
					Item {
						Layout.fillWidth: true
					}
					Button {
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						background: Item{}
						icon.source: AppIcons.closeX
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						focus: true
						contentImageColor: DefaultStyle.main1_500_main
						onClicked: if(contactLoader.item) contactLoader.item.removeSelectedContactByAddress(modelData)
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
				anchors.rightMargin: 8 * DefaultStyle.dp
			}
		}
		SearchBar {
			id: searchBar
			Layout.fillWidth: true
			Layout.topMargin: 6 * DefaultStyle.dp
			Layout.rightMargin: 28 * DefaultStyle.dp
			Layout.preferredHeight: 45 * DefaultStyle.dp
			placeholderText: mainItem.placeHolderText
			focus: participantList.count == 0
			color: mainItem.searchBarColor
			borderColor: mainItem.searchBarColor
			KeyNavigation.up: participantList.count > 0
								? participantList
								: nextItemInFocusChain(false)
			KeyNavigation.down: contactLoader.item
		}
		ColumnLayout {
			id: content
			spacing: 15 * DefaultStyle.dp
			Text {
				visible: !contactLoader.item?.loading && contactLoader.item?.count === 0
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: 137 * DefaultStyle.dp
				text: qsTr("Aucun contact%1").arg(searchBar.text.length !== 0 ? " correspondant" : "")
				font {
					pixelSize: 16 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			}
			Loader{
			// This is a hack for an incomprehensible behavior on sections title where they doesn't match with their delegate and can be unordered after resetting models.
				id: contactLoader
				Layout.fillWidth: true
				Layout.fillHeight: true
				property string t: searchBar.text
				onTChanged: {
					contactLoader.active = false
					Qt.callLater(function(){contactLoader.active=true})
				}
				//-------------------------------------------------------------
				sourceComponent: ContactListView{
					id: contactList
					Layout.fillWidth: true
					Layout.fillHeight: true
					itemsRightMargin: 28 * DefaultStyle.dp
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
}
