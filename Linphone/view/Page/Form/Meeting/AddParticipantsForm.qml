import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp
import SettingsCpp

FocusScope{
	id: mainItem
	
	property string placeHolderText: qsTr("Rechercher des contacts")
	property list<string> selectedParticipants: contactList.selectedContacts
	property int selectedParticipantsCount: selectedParticipants.length
	property ConferenceInfoGui conferenceInfoGui
	property bool nameGroupCall: false
	readonly property string groupName: groupCallName.text
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"

	function clearSelectedParticipants() {
		// TODO
		//contactList.selectedContacts.clear()
	}
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 15 * DefaultStyle.dp
		ColumnLayout {
			visible: mainItem.nameGroupCall
			spacing: 5 * DefaultStyle.dp
			Layout.rightMargin: 38 * DefaultStyle.dp
			RowLayout {
				spacing: 0
				Text {
					font.pixelSize: 13 * DefaultStyle.dp
					font.weight: 700 * DefaultStyle.dp
					text: qsTr("Nom du groupe")
				}
				Item{Layout.fillWidth: true}
				Text {
					font.pixelSize: 12 * DefaultStyle.dp
					font.weight: 300 * DefaultStyle.dp
					text: qsTr("Requis")
				}
			}
			TextField {
				id: groupCallName
				Layout.fillWidth: true
				Layout.preferredHeight: 49 * DefaultStyle.dp
				focus: mainItem.nameGroupCall
				KeyNavigation.down: participantList.count > 0 ? participantList : searchbar
				Keys.onPressed: (event) => {
					if(currentIndex <=0 && event.key == Qt.Key_Up){
						nextItemInFocusChain(false).forceActiveFocus()
					}
				}
			}
		}
		ListView {
			id: participantList
			Layout.fillWidth: true
			Layout.preferredHeight: contentHeight
			Layout.maximumHeight: mainItem.height / 3
			width: mainItem.width
			model: contactList.selectedContacts
			clip: true
			focus: !groupCallName.visible && participantList.count > 0
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
						onClicked: contactList.selectedContacts.splice(index, 1)
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
			placeholderText: mainItem.placeHolderText
			focus: !groupCallName.visible && participantList.count == 0
			color: mainItem.searchBarColor
			borderColor: mainItem.searchBarColor
			KeyNavigation.up: participantList.count > 0 
								? participantList
								: groupCallName.visible
									? groupCallName
									: nextItemInFocusChain(false)
			KeyNavigation.down: contactList
		}
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
			Layout.fillHeight: true
			Layout.topMargin: 8 * DefaultStyle.dp
			Layout.rightMargin: 8 * DefaultStyle.dp
			Layout.preferredHeight: contentHeight
			multiSelectionEnabled: true
			contactMenuVisible: false
			confInfoGui: mainItem.conferenceInfoGui
			searchBarText: searchbar.text
			onContactAddedToSelection: participantList.positionViewAtEnd()
			headerPositioning: ListView.InlineHeader
			header: MouseArea {
				onClicked: contactList.addContactToSelection(sipAddr.text)
				visible: searchbar.text.length > 0
				height: searchbar.text.length > 0 ? 56 * DefaultStyle.dp : 0
				width: contactList.width
				RowLayout {
					Layout.fillWidth: true
					spacing: 10 * DefaultStyle.dp
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: 30 * DefaultStyle.dp
					anchors.left: parent.left
					Avatar {
						Layout.preferredWidth: 45 * DefaultStyle.dp
						Layout.preferredHeight: 45 * DefaultStyle.dp
						_address: sipAddr.text
					}
					ColumnLayout {
						spacing: 0
						Text {
							id: sipAddr
							property string _text: UtilsCpp.interpretUrl(searchbar.text)
							text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_text) : _text
							font.pixelSize: 14 * DefaultStyle.dp
						}
					}
				}
			}
			
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
