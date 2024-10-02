import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp

ListView {
	id: mainItem
	height: contentHeight
	visible: contentHeight > 0
	clip: true
	//keyNavigationWraps: true
	// rightMargin: 5 * DefaultStyle.dp


	property bool selectionEnabled: true
	property bool hoverEnabled: true
	// dots popup menu
	property bool contactMenuVisible: true
	// call, video call etc menu
	property bool actionLayoutVisible: false
	property bool initialHeadersVisible: true
	property bool displayNameCapitalization: true
	property bool showFavoritesOnly: false
	property bool showDefaultAddress: false

	property var listProxy: MagicSearchProxy{}

	// Model properties
	// set searchBarText without specifying a model to bold
	// matching names
	property string searchBarText
	property string searchText: searchBarText.length === 0 ? "*" : searchBarText
	property var aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
	property var sourceFlags: LinphoneEnums.MagicSearchSource.Friends | ((searchText.length > 0 && searchText != "*") || SettingsCpp.syncLdapContacts ? LinphoneEnums.MagicSearchSource.LdapServers : 0)

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
	signal contactAddedToSelection(string address)
	signal contactRemovedFromSelection(string address)
	signal clicked()

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
				contactAddedToSelection(address)
			}
		}
	}
	function removeContactFromSelection(indexInSelection) {
		var addressToRemove = selectedContacts[indexInSelection]
		if (indexInSelection != -1) {
			selectedContacts.splice(indexInSelection, 1)
			contactRemovedFromSelection(addressToRemove)
		}
	}
	function removeSelectedContactByAddress(address) {
		var index = selectedContacts.indexOf(address)
		if (index != -1) {
			selectedContacts.splice(index, 1)
			contactRemovedFromSelection(address)
		}
	}

	onActiveFocusChanged: if(activeFocus && (!footerItem || !footerItem.activeFocus)) {
		currentIndex = 0
	}

	model: MagicSearchProxy {
		id: magicSearchProxy
		searchText: mainItem.searchText
		// This property is needed instead of playing on the delegate visibility
		// considering its starred status. Otherwise, the row in the list still
		// exists even if its delegate is not visible, and creates navigation issues
		showFavoritesOnly: mainItem.showFavoritesOnly
		onFriendCreated: (index) => {
			mainItem.currentIndex = index
		}
		aggregationFlag: mainItem.aggregationFlag
		parentProxy: mainItem.listProxy
		sourceFlags: mainItem.sourceFlags
		onInitialized: {
			magicSearchProxy.forceUpdate()
		}
	}

	Connections {
		target: SettingsCpp
		onLdapConfigChanged: {
			if (SettingsCpp.syncLdapContacts)
				magicSearchProxy.forceUpdate()
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
	Keys.onPressed: (event)=>{
		if(event.key == Qt.Key_Tab && !mainItem.itemAtIndex(mainItem.currentIndex).activeFocus){
			mainItem.itemAtIndex(mainItem.currentIndex).forceActiveFocus()
		}
	}
	delegate: FocusScope {
		id: itemDelegate
		height: 56 * DefaultStyle.dp
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDisplayName: previousItem ? previousItem.core.displayName : ""
		property var displayName: modelData.core.displayName

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
			anchors.right: parent.right
			anchors.rightMargin: 5 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			spacing: 16 * DefaultStyle.dp
			z: 1
			Avatar {
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				contact: modelData
			}
			ColumnLayout {
				spacing: 0
				Text {
					text: UtilsCpp.boldTextPart(itemDelegate.displayName, mainItem.searchBarText)
					font{
						pixelSize: mainItem.showDefaultAddress ? 16 * DefaultStyle.dp : 14 * DefaultStyle.dp
						capitalization: mainItem.displayNameCapitalization ? Font.Capitalize : Font.MixedCase
						weight: mainItem.showDefaultAddress ? 800 * DefaultStyle.dp : 400 * DefaultStyle.dp
					}
					maximumLineCount: 1
					Layout.fillWidth: true
				}
				Text {
					Layout.topMargin: 2 * DefaultStyle.dp
					visible: mainItem.showDefaultAddress
					text: modelData.core.defaultAddress
					font {
						weight: 300 * DefaultStyle.dp
						pixelSize: 12 * DefaultStyle.dp
					}
				}
			}
			Item{Layout.fillWidth: true}
			RowLayout {
				id: actionsRow
				z: 1
				visible: actionButtons || friendPopup.visible || mainItem.multiSelectionEnabled
				spacing: visible ? 16 * DefaultStyle.dp : 0
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
				RowLayout{
					id: actionButtons
					visible: mainItem.actionLayoutVisible
					spacing: visible ? 10 * DefaultStyle.dp : 0
					Button {
						id: callButton
						Layout.preferredWidth: 45 * DefaultStyle.dp
						Layout.preferredHeight: 45 * DefaultStyle.dp
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						icon.source: AppIcons.phone
						focus: visible
						contentImageColor: DefaultStyle.main2_500main
						background: Rectangle {
							anchors.fill: parent
							radius: 40 * DefaultStyle.dp
							color: DefaultStyle.main2_200
						}
						onClicked: UtilsCpp.createCall(modelData.core.defaultAddress)
						KeyNavigation.right: chatButton
						KeyNavigation.left: chatButton
					}
					Button {
						id: chatButton
						visible: actionButtons.visible && !SettingsCpp.disableChatFeature
						Layout.preferredWidth: 45 * DefaultStyle.dp
						Layout.preferredHeight: 45 * DefaultStyle.dp
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						icon.source: AppIcons.chatTeardropText
						focus: visible && !callButton.visible
						contentImageColor: DefaultStyle.main2_500main
						background: Rectangle {
							anchors.fill: parent
							radius: 40 * DefaultStyle.dp
							color: DefaultStyle.main2_200
						}
						KeyNavigation.right: callButton
						KeyNavigation.left: callButton
					}
				}
				PopupButton {
					id: friendPopup
					z: 1
					// Layout.rightMargin: 13 * DefaultStyle.dp
					Layout.alignment: Qt.AlignVCenter
					Layout.rightMargin: 8 * DefaultStyle.dp
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
							visible: !modelData.core.readOnly
							onClicked: {
								mainItem.contactDeletionRequested(modelData)
								friendPopup.close()
							}
						}
					}
				}
			}
		}


		
		MouseArea {
			id: contactArea
			enabled: mainItem.selectionEnabled
			hoverEnabled: mainItem.hoverEnabled
			anchors.fill: contactDelegate
			height: mainItem.height
			acceptedButtons: Qt.AllButtons
			z: -1
			focus: !actionButtons.visible
			Rectangle {
				anchors.fill: contactArea
				opacity: 0.7
				color: DefaultStyle.main2_100
				visible: contactArea.containsMouse || friendPopup.hovered || mainItem.currentIndex === index
			}
			Keys.onPressed: (event)=> {
				if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
					contactArea.clicked(undefined)
					event.accepted = true;
				}
			}
			onClicked: (mouse) => {
				if (mouse && mouse.button == Qt.RightButton) {
					friendPopup.open()
				} else {
					mainItem.forceActiveFocus()
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
					mainItem.clicked()
				}
			}
		}
	}
}
