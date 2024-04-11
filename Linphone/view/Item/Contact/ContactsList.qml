import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control

import Linphone
import UtilsCpp 1.0

ListView {
	id: mainItem
	height: contentHeight
	visible: contentHeight > 0
	clip: true
	// rightMargin: 5 * DefaultStyle.dp

	property string searchBarText

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
	onCountChanged: {
		selectedContact = model.getAt(currentIndex) || null
	}

	// signal contactSelected(var contact)
	signal contactStarredChanged()
	signal contactDeletionRequested(FriendGui contact)
	signal contactAddedToSelection()

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
		searchText: searchBarText.length === 0 ? "*" : searchBarText
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
		width: mainItem.width - scrollbar.width - 12 * DefaultStyle.dp
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDisplayName: previousItem ? previousItem.core.displayName : ""
		property var displayName: modelData.core.displayName
		property bool display: !mainItem.showOnlyFavourites || modelData.core.starred
		
		visible: display
		Connections {
			target: modelData.core
			onStarredChanged: mainItem.contactStarredChanged()
		}
		Text {
			id: initial
			anchors.left: parent.left
			visible: mainItem.initialHeadersVisible && mainItem.model.sourceFlags != LinphoneEnums.MagicSearchSource.All
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			width: 20 * DefaultStyle.dp
			opacity: (!previousItem || !previousDisplayName.startsWith(displayName[0])) ? 1 : 0
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
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.right: parent.right
			// anchors.rightMargin: 10 * DefaultStyle.dp
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
					onSelectedContactCountChanged: isSelectedCheck.visible = (mainItem.selectedContacts.indexOf(modelData.core.defaultAddress) != -1)
				}
			}
		}

		RowLayout {
			id: actionsRow
			z: 1
			// visible: mainItem.actionLayoutVisible || friendPopup.visible
			// anchors.fill: parent
			anchors.right: parent.right
			// anchors.rightMargin: 10 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			RowLayout{
				visible: mainItem.actionLayoutVisible
				spacing: 10 * DefaultStyle.dp
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					background: Item{}
					contentItem: Image {
						anchors.fill: parent
						width: 24 * DefaultStyle.dp
						height: 24 * DefaultStyle.dp
						source: AppIcons.phone
					}
					onClicked: UtilsCpp.createCall(modelData.core.defaultAddress)
				}
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					background: Item{}
					contentItem: Image {
						anchors.fill: parent
						width: 24 * DefaultStyle.dp
						height: 24 * DefaultStyle.dp
						source: AppIcons.videoCamera
					}
					onClicked: UtilsCpp.createCall(modelData.core.defaultAddress, {'cameraEnabled':true})
				}
			}
			PopupButton {
				id: friendPopup
				z: 1
				Layout.rightMargin: 5 * DefaultStyle.dp
				Layout.alignment: Qt.AlignVCenter
				popup.x: 0
				popup.padding: 10 * DefaultStyle.dp
				hoverEnabled: mainItem.hoverEnabled
				visible: mainItem.contactMenuVisible && (contactArea.containsMouse || hovered || popup.opened) && (!mainItem.delegateButtons || mainItem.delegateButtons.length === 0)
				
				popup.contentItem: ColumnLayout {
					Button {
						background: Item{}
						contentItem: RowLayout {
							Image {
								source: modelData.core.starred ? AppIcons.heartFill : AppIcons.heart
								fillMode: Image.PreserveAspectFit
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
							}
							Text {
								text: modelData.core.starred ? qsTr("Enlever des favoris") : qsTr("Mettre en favori")
								color: DefaultStyle.main2_500main
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
						}
						onClicked: {
							modelData.core.lSetStarred(!modelData.core.starred)
							friendPopup.close()
						}
					}
					Button {
						background: Item{}
						contentItem: RowLayout {
							EffectImage {
								imageSource: AppIcons.trashCan
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
								colorizationColor: DefaultStyle.danger_500main
							}
							Text {
								text: qsTr("Supprimer")
								color: DefaultStyle.danger_500main
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
						}
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
			hoverEnabled: mainItem.hoverEnabled
			anchors.fill: contactDelegate
			height: mainItem.height
			Rectangle {
				anchors.fill: contactArea
				opacity: 0.7
				color: DefaultStyle.main2_100
				visible: contactArea.containsMouse || friendPopup.hovered || (!mainItem.multiSelectionEnabled && mainItem.currentIndex === index)
			}
			onClicked: {
				mainItem.currentIndex = index
				// mainItem.contactSelected(modelData)
				// if (mainItem.multiSelectionEnabled && mainItem.confInfoGui) {
				// 	var indexInSelection = mainItem.confInfoGui.core.getParticipantIndex(modelData.core.defaultAddress)
				// 	if (indexInSelection == -1) {
				// 		mainItem.confInfoGui.core.addParticipant(modelData.core.defaultAddress)
				// 	} else {
				// 		mainItem.confInfoGui.core.removeParticipant(indexInSelection)
				// 	}
				// }
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
