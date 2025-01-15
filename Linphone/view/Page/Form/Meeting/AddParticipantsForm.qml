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
	
	property string placeHolderText: qsTr("Rechercher des contacts")
	property list<string> selectedParticipants
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
						Layout.fillWidth: true
						maximumLineCount: 1
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
						style: ButtonStyle.noBackgroundOrange
						icon.source: AppIcons.closeX
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						focus: true
						onClicked: contactList.removeSelectedContactByAddress(modelData)
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
			KeyNavigation.down: contactList
		}
		ColumnLayout {
			id: content
			spacing: 15 * DefaultStyle.dp
			Text {
				visible: !contactList.loading && contactList.count === 0
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: 137 * DefaultStyle.dp
				text: qsTr("Aucun contact%1").arg(searchBar.text.length !== 0 ? " correspondant" : "")
				font {
					pixelSize: 16 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			}
			AllContactListView{
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
