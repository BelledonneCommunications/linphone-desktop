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
	property list<string> selectedParticipants: suggestionList.selectedContacts
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
			model: suggestionList.selectedContacts
			clip: true
			focus: participantList.count > 0
			Keys.onPressed: (event) => {
				if(currentIndex <=0 && event.key == Qt.Key_Up){
					nextItemInFocusChain(false).forceActiveFocus()
				}
			}
			delegate: FocusScope {
				height: 56 * DefaultStyle.dp
				width: participantList.width - scrollbar.implicitWidth - 12 * DefaultStyle.dp
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
						onClicked: suggestionList.removeSelectedContactByAddress(modelData)
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
			id: searchbar
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
			KeyNavigation.down: contactList
		}
		Flickable {
			Layout.fillWidth: true
			Layout.fillHeight: true
			contentWidth: width
			contentHeight: content.height
			clip: true
			Control.ScrollBar.vertical: ScrollBar {
				id: contactsScrollBar
				active: true
				interactive: true
				policy: Control.ScrollBar.AsNeeded
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				anchors.rightMargin: 8 * DefaultStyle.dp
			}
			ColumnLayout {
				id: content
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.rightMargin: contactsScrollBar.implicitWidth + 12 * DefaultStyle.dp
				Text {
					Layout.topMargin: 6 * DefaultStyle.dp
					text: qsTr("Contacts")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				ContactListView {
					id: contactList
					visible: contentHeight > 0 || searchbar.text.length > 0
					Layout.fillWidth: true
					// Layout.fillHeight: true
					Layout.topMargin: 8 * DefaultStyle.dp
					Layout.preferredHeight: contentHeight
					multiSelectionEnabled: true
					contactMenuVisible: false
					confInfoGui: mainItem.conferenceInfoGui
					searchBarText: searchbar.text
					onContactAddedToSelection: (address) => {
						suggestionList.addContactToSelection(address)
					}
					onContactRemovedFromSelection: (address) => suggestionList.removeSelectedContactByAddress(address)
					Control.ScrollBar.vertical.visible: false
				}
				Text {
					Layout.topMargin: 6 * DefaultStyle.dp
					text: qsTr("Suggestions")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				ContactListView {
					id: suggestionList
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.preferredHeight: contentHeight
					contactMenuVisible: false
					searchBarText: searchbar.text
					sourceFlags: LinphoneEnums.MagicSearchSource.All
					multiSelectionEnabled: true
					onContactAddedToSelection: (address) => {
						contactList.addContactToSelection(address)
						participantList.positionViewAtEnd()
					}
					onContactRemovedFromSelection: (address) => contactList.removeSelectedContactByAddress(address)
					Control.ScrollBar.vertical.visible: false
				}
			}
		}

		// Item {
		// 	Layout.fillHeight: true
		// }
	}
}
