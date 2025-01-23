import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

FocusScope {
	id: mainItem
	implicitHeight: visible ? 56 * DefaultStyle.dp : 0
	property var searchResultItem
	property bool showInitials: true	// Display Initials of Display name.
	property bool showDefaultAddress: true	// Display address below display name.
	property bool showActions: false	// Display actions layout (call buttons)
	property bool showContactMenu: true	// Display the dot menu for contacts.
	property string highlightText	// Bold characters in Display name.
	
	property bool displayNameCapitalization: true	// Capitalize display name.
	
	property bool selectionEnabled: true		// Contact can be selected
	property bool multiSelectionEnabled: false	//Multiple items can be selected.
	property list<string> selectedContacts		// List of default address on selected contacts.
	property bool isSelected: false	// selected in list => currentIndex == index
	property bool isLastHovered: false
		
	property var previousInitial	// Use directly previous initial
	property int itemsRightMargin: 39 * DefaultStyle.dp
	
	property var displayName: searchResultItem.core.fullName
	property string initial: displayName ? displayName[0].toLocaleLowerCase(ConstantsCpp.DefaultLocale) : ''
	
	signal clicked(var mouse)
	signal contactDeletionRequested(FriendGui contact)
	signal containsMouseChanged(bool containsMouse)

	Text {
		id: initial
		anchors.left: parent.left
		visible: mainItem.showInitials
		anchors.verticalCenter: parent.verticalCenter
		anchors.rightMargin: 15 * DefaultStyle.dp
		verticalAlignment: Text.AlignVCenter
		width: 20 * DefaultStyle.dp
		opacity: previousInitial != mainItem.initial ? 1 : 0
		text: mainItem.initial
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
		anchors.rightMargin: mainItem.itemsRightMargin
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		spacing: 16 * DefaultStyle.dp
		z: 1
		Avatar {
			Layout.preferredWidth: 45 * DefaultStyle.dp
			Layout.preferredHeight: 45 * DefaultStyle.dp
			Layout.leftMargin: 5 * DefaultStyle.dp
			contact: searchResultItem
		}
		ColumnLayout {
			spacing: 0
			Text {
				text: UtilsCpp.boldTextPart(mainItem.displayName, mainItem.highlightText)
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
				Layout.fillWidth: true
				visible: mainItem.showDefaultAddress
				property string address: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(searchResultItem.core.defaultAddress) : searchResultItem.core.defaultAddress
				text: UtilsCpp.boldTextPart(address, mainItem.highlightText)
				maximumLineCount: 1
				elide: Text.ElideRight
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
			Layout.rightMargin: visible ? 10 * DefaultStyle.dp : 0
			EffectImage {
				id: isSelectedCheck
				visible: mainItem.multiSelectionEnabled && (mainItem.selectedContacts.indexOf(searchResultItem.core.defaultAddress) != -1)
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				imageSource: AppIcons.check
				colorizationColor: DefaultStyle.main1_500_main
			}
			RowLayout{
				id: actionButtons
				visible: mainItem.showActions
				spacing: visible ? 10 * DefaultStyle.dp : 0
				Button {
					id: callButton
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					icon.source: AppIcons.phone
					focus: visible
					radius: 40 * DefaultStyle.dp
					style: ButtonStyle.grey
					onClicked: UtilsCpp.createCall(searchResultItem.core.defaultFullAddress)
					KeyNavigation.left: chatButton
					KeyNavigation.right: videoCallButton
				}
				Button {
					id: videoCallButton
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					icon.source: AppIcons.videoCamera
					focus: visible && !callButton.visible
					radius: 40 * DefaultStyle.dp
					style: ButtonStyle.grey
					onClicked: UtilsCpp.createCall(searchResultItem.core.defaultFullAddress, {'localVideoEnabled': true})
					KeyNavigation.left: callButton
					KeyNavigation.right: chatButton
				}
				Button {
					id: chatButton
					visible: actionButtons.visible && !SettingsCpp.disableChatFeature
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					icon.source: AppIcons.chatTeardropText
					focus: visible && !callButton.visible && !videoCallButton.visible
					radius: 40 * DefaultStyle.dp
					style: ButtonStyle.grey
					KeyNavigation.left: videoCallButton
					KeyNavigation.right: callButton
				}
			}
			PopupButton {
				id: friendPopup
				z: 1
				popup.x: 0
				popup.padding: 10 * DefaultStyle.dp
				visible: mainItem.showContactMenu && (contactArea.containsMouse || hovered || popup.opened)
				
				popup.contentItem: ColumnLayout {
					IconLabelButton {
						visible: searchResultItem.core.isStored && !searchResultItem.core.readOnly
						text: searchResultItem.core.starred ? qsTr("Enlever des favoris") : qsTr("Mettre en favori")
						icon.source: searchResultItem.core.starred ? AppIcons.heartFill : AppIcons.heart
						spacing: 10 * DefaultStyle.dp
						textColor: DefaultStyle.main2_500main
						hoveredImageColor: searchResultItem.core.starred ?  DefaultStyle.main1_700 : DefaultStyle.danger_700
						contentImageColor: searchResultItem.core.starred ? DefaultStyle.danger_500main : DefaultStyle.main2_600
						onClicked: {
							searchResultItem.core.lSetStarred(!searchResultItem.core.starred)
							friendPopup.close()
						}
						style: ButtonStyle.noBackground
					}
					IconLabelButton {
						text: qsTr("Partager")
						icon.source: AppIcons.shareNetwork
						spacing: 10 * DefaultStyle.dp
						textColor: DefaultStyle.main2_500main
						onClicked: {
							var vcard = searchResultItem.core.getVCard()
							var username = searchResultItem.core.givenName + searchResultItem.core.familyName
							var filepath = UtilsCpp.createVCardFile(username, vcard)
							if (filepath == "") UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La création du fichier vcard a échoué"), false)
							else mainWindow.showInformationPopup(qsTr("VCard créée"), qsTr("VCard du contact enregistrée dans %1").arg(filepath))
							UtilsCpp.shareByEmail(qsTr("Partage de contact"), vcard, filepath)
						}
						style: ButtonStyle.noBackground

					}
					IconLabelButton {
						text: qsTr("Supprimer")
						icon.source: AppIcons.trashCan
						spacing: 10 * DefaultStyle.dp
						visible: !searchResultItem.core.readOnly
						onClicked: {
							mainItem.contactDeletionRequested(searchResultItem)
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
			radius: 8 * DefaultStyle.dp
			opacity: 0.7
			color: mainItem.isSelected ? DefaultStyle.main2_200 : DefaultStyle.main2_100
			visible: mainItem.isLastHovered || friendPopup.hovered || mainItem.isSelected || friendPopup.visible
		}
		Keys.onPressed: (event)=> {
			if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
				contactArea.clicked(undefined)
				event.accepted = true;
			}
		}
		onClicked: (mouse) => {
			forceActiveFocus()
			if (mouse && mouse.button == Qt.RightButton && mainItem.showContactMenu) {
				friendPopup.open()
			} else {
				mainItem.clicked(mouse)
			}
		}
	}
}
