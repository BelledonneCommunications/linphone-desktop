import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0

ListView {
	id: mainItem
	height: contentHeight
	visible: contentHeight > 0
	clip: true
	// rightMargin: 5 * DefaultStyle.dp

	property string searchBarText

	property bool selectionEnabled: true
	property bool hoverEnabled: true
	// dots popup menu
	property bool contactMenuVisible: true
	// call, video call etc menu
	property bool actionLayoutVisible: false
	property bool initialHeadersVisible: true
	property bool displayNameCapitalization: true
	property bool showOnlyFavourites: false

	property ConferenceInfoGui confInfoGui

	property bool multiSelectionEnabled: false
	property list<string> selectedContacts
	property int selectedContactCount: selectedContacts.length
	Component.onCompleted: {
		if (confInfoGui) {
			for(var i = 0; i < confInfoGui.core.participants.length; ++i) {
				selectedContacts.push(confInfoGui.core.getParticipantAddressAt(i));
			}
		}
	}
	currentIndex: -1

	property FriendGui selectedContact: model.getAt(currentIndex) || null

	onCurrentIndexChanged: selectedContact = model.getAt(currentIndex) || null
	onCountChanged: selectedContact = model.getAt(currentIndex) || null

	signal contactStarredChanged()
	signal contactDeletionRequested(FriendGui contact)
	signal contactAddedToSelection()

	function selectContact(address) {
		var index = magicSearchProxy.findFriendIndexByAddress(address)
		if (index != -1) {
			mainItem.currentIndex = index
		}
		return index
	}
	function addContactToSelection(address) {
		if (multiSelectionEnabled) {
			var indexInSelection = selectedContacts.indexOf(address)
			if (indexInSelection == -1) {
				selectedContacts.push(address)
				contactAddedToSelection()
			}
		}
	}
	function removeContactFromSelection(indexInSelection) {
		if (indexInSelection != -1) {
			selectedContacts.splice(indexInSelection, 1)
		}
	}

	

	model: MagicSearchProxy {
		id: magicSearchProxy
		searchText: searchBarText.length === 0 ? "*" : searchBarText
		onFriendCreated: (index) => {
			mainItem.currentIndex = index
		}
	}

	Control.ScrollBar.vertical: ScrollBar {
		id: scrollbar
		active: true
		interactive: true
		// anchors.top: parent.top
		// anchors.bottom: parent.bottom
		// anchors.right: parent.right
	}

	delegate: Item {
		id: itemDelegate
		height: display ? 56 * DefaultStyle.dp : 0
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDisplayName: previousItem ? previousItem.core.displayName : ""
		property var displayName: modelData.core.displayName
		property bool display: !mainItem.showOnlyFavourites || modelData.core.starred
		visible: display

		Connections {
			enabled: modelData.core
			target: modelData.core
			function onStarredChanged() { mainItem.contactStarredChanged()}
		}
		Text {
			id: initial
			anchors.left: parent.left
			visible: mainItem.initialHeadersVisible && mainItem.model.sourceFlags != LinphoneEnums.MagicSearchSource.All
			anchors.verticalCenter: parent.verticalCenter
			anchors.rightMargin: 15 * DefaultStyle.dp
			verticalAlignment: Text.AlignVCenter
			width: 20 * DefaultStyle.dp
			opacity: (!previousItem || !previousDisplayName.toLocaleLowerCase(ConstantsCpp.DefaultLocale).startsWith(displayName[0].toLocaleLowerCase(ConstantsCpp.DefaultLocale))) ? 1 : 0
			text: displayName[0]
			color: DefaultStyle.main2_400
			font {
				pixelSize: 20 * DefaultStyle.dp
				weight: 500 * DefaultStyle.dp
				capitalization: Font.AllUppercase
			}
		}
		RowLayout {
			id: contactDelegate
			anchors.left: initial.visible ? initial.right : parent.left
			anchors.right: actionsRow.left
			anchors.verticalCenter: parent.verticalCenter
			spacing: 10 * DefaultStyle.dp
			z: 1
			Avatar {
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				contact: modelData
			}
			Text {
				text: itemDelegate.displayName
				font.pixelSize: 14 * DefaultStyle.dp
				font.capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
				maximumLineCount: 1
				Layout.fillWidth: true
			}
			EffectImage {
				id: isSelectedCheck
				// visible: mainItem.multiSelectionEnabled && (mainItem.confInfoGui.core.getParticipantIndex(modelData.core.defaultAddress) != -1)
				visible: mainItem.multiSelectionEnabled && (mainItem.selectedContacts.indexOf(modelData.core.defaultAddress) != -1)
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				imageSource: AppIcons.check
				colorizationColor: DefaultStyle.main1_500_main
				Connections {
					target: mainItem
					// onParticipantsChanged: isSelectedCheck.visible = mainItem.confInfoGui.core.getParticipantIndex(modelData.core.defaultAddress) != -1
					function onSelectedContactCountChanged(){ isSelectedCheck.visible = (mainItem.selectedContacts.indexOf(modelData.core.defaultAddress) != -1)}
				}
			}
		}

		RowLayout {
			id: actionsRow
			z: 1
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 10 * DefaultStyle.dp // TODO : change when mockup ready
			RowLayout{
				visible: mainItem.actionLayoutVisible
				spacing: 10 * DefaultStyle.dp
				Button {
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					icon.source: AppIcons.phone
					contentImageColor: DefaultStyle.main2_500main
					background: Rectangle {
						anchors.fill: parent
						radius: 40 * DefaultStyle.dp
						color: DefaultStyle.main2_200
					}
					onClicked: UtilsCpp.createCall(modelData.core.defaultAddress)
				}
				Button {
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					icon.source: AppIcons.chatTeardropText
					contentImageColor: DefaultStyle.main2_500main
					background: Rectangle {
						anchors.fill: parent
						radius: 40 * DefaultStyle.dp
						color: DefaultStyle.main2_200
					}
				}
			}
			PopupButton {
				id: friendPopup
				z: 1
				// Layout.rightMargin: 13 * DefaultStyle.dp
				Layout.alignment: Qt.AlignVCenter
				popup.x: 0
				popup.padding: 10 * DefaultStyle.dp
				hoverEnabled: mainItem.hoverEnabled
				visible: mainItem.contactMenuVisible && (contactArea.containsMouse || hovered || popup.opened) && (!mainItem.delegateButtons || mainItem.delegateButtons.length === 0)
				
				popup.contentItem: ColumnLayout {
					Button {
						text: modelData.core.starred ? qsTr("Enlever des favoris") : qsTr("Mettre en favori")
						background: Item{}
						icon.source: modelData.core.starred ? AppIcons.heartFill : AppIcons.heart
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						spacing: 10 * DefaultStyle.dp
						textSize: 14 * DefaultStyle.dp
						textWeight: 400 * DefaultStyle.dp
						textColor: DefaultStyle.main2_500main
						contentImageColor: modelData.core.starred ? DefaultStyle.danger_500main : DefaultStyle.main2_600
						onClicked: {
							modelData.core.lSetStarred(!modelData.core.starred)
							friendPopup.close()
						}
					}
					Button {
						text: qsTr("Partager")
						background: Item{}
						icon.source: AppIcons.shareNetwork
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						spacing: 10 * DefaultStyle.dp
						textSize: 14 * DefaultStyle.dp
						textWeight: 400 * DefaultStyle.dp
						textColor: DefaultStyle.main2_500main
						onClicked: {
							var vcard = modelData.core.getVCard()
							var username = modelData.core.givenName + modelData.core.familyName
							var filepath = UtilsCpp.createVCardFile(username, vcard)
							if (filepath == "") UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La création du fichier vcard a échoué"), false)
							else mainWindow.showInformationPopup(qsTr("VCard créée"), qsTr("VCard du contact enregistrée dans %1").arg(filepath))
							UtilsCpp.shareByEmail(qsTr("Partage de contact"), vcard, filepath)
						}
					}
					Button {
						text: qsTr("Supprimer")
						background: Item{}
						icon.source: AppIcons.trashCan
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						spacing: 10 * DefaultStyle.dp
						textSize: 14 * DefaultStyle.dp
						textWeight: 400 * DefaultStyle.dp
						textColor: DefaultStyle.danger_500main
						contentImageColor: DefaultStyle.danger_500main
						onClicked: {
							mainItem.contactDeletionRequested(modelData)
							friendPopup.close()
						}
					}
				}
			}
		}

		
		MouseArea {
			id: contactArea
			enabled: mainItem.selectionEnabled
			hoverEnabled: mainItem.hoverEnabled
			anchors.fill: itemDelegate
			height: mainItem.height
			acceptedButtons: Qt.AllButtons
			z: -1
			Rectangle {
				anchors.fill: contactArea
				opacity: 0.7
				color: DefaultStyle.main2_100
				visible: contactArea.containsMouse || friendPopup.hovered || (!mainItem.multiSelectionEnabled && mainItem.currentIndex === index)
			}
			onClicked: (mouse) => {
				if (mouse.button == Qt.RightButton) {
					friendPopup.open()
				} else {
					mainItem.currentIndex = -1
					mainItem.currentIndex = index
					if (mainItem.multiSelectionEnabled) {
						var indexInSelection = mainItem.selectedContacts.indexOf(modelData.core.defaultAddress)
						if (indexInSelection == -1) {
							mainItem.addContactToSelection(modelData.core.defaultAddress)
						}
						else {
							mainItem.removeContactFromSelection(indexInSelection, 1)
						}
					}
				}
			}
		}
	}
}
