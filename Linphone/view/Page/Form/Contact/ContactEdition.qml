import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp

MainRightPanel {
	id: mainItem

	property FriendGui contact
	Connections {
		target: contact.core
		function onIsSavedChanged() {
			if (contact.core.isSaved) {
				var mainWin = UtilsCpp.getMainWindow()
				UtilsCpp.smartShowWindow(mainWin)
				mainWin.goToContactDetail(contact)
			}
		}
	}
	property string title: qsTr("Modifier contact")
	property string saveButtonText: qsTr("Enregistrer")
	property string oldPictureUri
	property int addressCount: 0
	
	signal closeEdition()

	Dialog {
		id: confirmDialog
		onAccepted: {
			mainItem.contact.core.undo()
			mainItem.closeEdition()
		}
		width: 278 * DefaultStyle.dp
		text: qsTr("Les changements seront annulés. Souhaitez-vous continuer ?")
	}

	headerContent: [
			Text {
				anchors.left: parent.left
				anchors.leftMargin: 31 * DefaultStyle.dp
				anchors.verticalCenter: parent.verticalCenter
				text: mainItem.title
				font {
					pixelSize: 20 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			},
			Button {
				background: Item{}
				anchors.right: parent.right
				anchors.rightMargin: 41 * DefaultStyle.dp
				anchors.verticalCenter: parent.verticalCenter
				width: 24 * DefaultStyle.dp
				height: 24 * DefaultStyle.dp
				icon.source: AppIcons.closeX
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				onClicked: {
					confirmDialog.open()
				}
			}
	]

	content: ContactLayout {
		anchors.fill: parent
		contact: mainItem.contact
		button.text: mainItem.saveButtonText

		button.onClicked: {
			if (contact.core.givenName.length === 0 || (addressesList.count === 0 && phoneNumberList.count === 0)) {
				if (contact.core.givenName.length === 0) givenName.errorMessage = qsTr("Veuillez saisir un prénom")
				if (addressesList.count === 0 && phoneNumberList.count === 0) addressesErrorText.text = qsTr("Veuillez saisir une adresse ou un numéro de téléphone")
				return
			}
			mainItem.contact.core.save()
			mainItem.closeEdition()
		}
		bannerContent: [
			IconLabelButton {
				id: addPictureButton
				Layout.preferredWidth: width
				Layout.preferredHeight: 17 * DefaultStyle.dp
				visible: !mainItem.contact || mainItem.contact.core.pictureUri.length === 0
				iconSource: AppIcons.camera
				iconSize: 17 * DefaultStyle.dp
				backgroundColor: "transparent"
				text: qsTr("Ajouter une image")
				KeyNavigation.down: editButton.visible ? editButton : givenNameEdit
				onClicked: fileDialog.open()
			},
			RowLayout {
				visible: mainItem.contact && mainItem.contact.core.pictureUri.length != 0
				Layout.alignment: Qt.AlignHCenter
				IconLabelButton {
					id: editButton
					Layout.preferredWidth: width
					Layout.preferredHeight: 17 * DefaultStyle.dp
					iconSource: AppIcons.pencil
					iconSize: 17 * DefaultStyle.dp
					backgroundColor: "transparent"
					text: qsTr("Modifier")
					KeyNavigation.right: removeButton
					onClicked: fileDialog.open()
				}
				FileDialog {
					id: fileDialog
					currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
					onAccepted: {
						mainItem.oldPictureUri = mainItem.contact.core.pictureUri
						var avatarPath = UtilsCpp.createAvatar( selectedFile )
						if(avatarPath){
							mainItem.contact.core.pictureUri = avatarPath
						}
					}
				}
				IconLabelButton {
					id: removeButton
					Layout.preferredHeight: 17 * DefaultStyle.dp
					Layout.preferredWidth: width
					iconSize: 17 * DefaultStyle.dp
					iconSource: AppIcons.trashCan
					backgroundColor: "transparent"
					text: qsTr("Supprimer")
					KeyNavigation.left: editButton
					onClicked: mainItem.contact.core.pictureUri = ""
				}
			},
			Item{Layout.fillWidth: true}
		]
		content: Flickable {
			id: editionLayout
			contentWidth: 421 * DefaultStyle.dp

			function ensureVisible(r) {
				if (contentY >= r.y)
					contentY = r.y;
				else if (contentY+height <= r.y+r.height+content.spacing)
					contentY = r.y+r.height-height;
			}

			ScrollBar.vertical: Control.ScrollBar {
				anchors.right: parent.right
			}
			ScrollBar.horizontal: Control.ScrollBar {
			}
			ColumnLayout {
				spacing: 20 * DefaultStyle.dp
				anchors.left: parent.left
				anchors.right: parent.right

				FormItemLayout {
					id: givenName
					Layout.fillWidth: true
					enableErrorText: true
					label: qsTr("Prénom")
					contentItem: TextField {
						id: givenNameEdit
						Layout.preferredHeight: 49 * DefaultStyle.dp
						initialText: contact.core.givenName
						onTextEdited: contact.core.givenName = text
						backgroundColor: DefaultStyle.grey_0
						backgroundBorderColor: givenName.errorTextVisible ? DefaultStyle.danger_500main : DefaultStyle.grey_200
						KeyNavigation.up: editButton.visible ? editButton : addPictureButton
						KeyNavigation.down: nameTextField
					}
				}
				FormItemLayout {
					label: qsTr("Nom")
					Layout.fillWidth: true
					contentItem: TextField {
						id: nameTextField
						initialText: contact.core.familyName
						onTextEdited: contact.core.familyName = text
						backgroundColor: DefaultStyle.grey_0
						KeyNavigation.up: givenNameEdit
						KeyNavigation.down: companyTextField
					}
				}
				FormItemLayout {
					label: qsTr("Entreprise")
					Layout.fillWidth: true
					contentItem: TextField {
						id: companyTextField
						initialText: contact.core.organization
						onTextEdited: contact.core.organization = text
						backgroundColor: DefaultStyle.grey_0
						KeyNavigation.up: nameTextField
						KeyNavigation.down: jobTextField
					}
				}
				FormItemLayout {
					label: qsTr("Fonction")
					Layout.fillWidth: true
					contentItem: TextField {
						id: jobTextField
						initialText: contact.core.job
						onTextEdited: contact.core.job = text
						backgroundColor: DefaultStyle.grey_0
						KeyNavigation.up: companyTextField
						Keys.onPressed: (event) => {
							if(event.key == Qt.Key_Down){
								if(addressesList.count > 0)
									addressesList.itemAt(0).forceActiveFocus()
								else
									newAddressTextField.forceActiveFocus()
								event.accepted = true
							}
						}
					}
				}
				Repeater {
					id: addressesList
					onCountChanged: mainItem.addressCount = count
					model: VariantList {
						model: mainItem.contact && mainItem.contact.core.addresses || []
					}
					delegate: FormItemLayout {
						label: modelData.label
						contentItem: RowLayout {
							id: addressLayout
							spacing: 10 * DefaultStyle.dp
							function updateFocus(event){
								if(event.key == Qt.Key_Up){
									if(index - 1 >=0 )
										addressesList.itemAt(index - 1).forceActiveFocus()
									else
										jobTextField.forceActiveFocus()
									event.accepted = true
								}else if(event.key == Qt.Key_Down){
									if(index + 1 < addressesList.count)
										addressesList.itemAt(index+1).forceActiveFocus()
									else
										newAddressTextField.forceActiveFocus()
									event.accepted = true
								}
							}
							TextField {
								id: addressTextField
								Layout.preferredWidth: 421 * DefaultStyle.dp
								Layout.preferredHeight: height
								onEditingFinished: {
									if (text.length != 0) mainItem.contact.core.setAddressAt(index, qsTr("Adresse SIP"), text)
								}
								property string _initialText: modelData.address
								initialText: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_initialText) : _initialText
								backgroundColor: DefaultStyle.grey_0
								focus: true
								KeyNavigation.right: removeAddressButton
								Keys.onPressed: (event) => addressLayout.updateFocus(event)
							}
							Button {
								id: removeAddressButton
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								Layout.alignment: Qt.AlignVCenter
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								icon.source: AppIcons.closeX
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								background: Item{}
								KeyNavigation.left: addressTextField
								Keys.onPressed: (event) => addressLayout.updateFocus(event)
								onClicked: mainItem.contact.core.removeAddress(index)
							}
						}
					}
				}
				FormItemLayout {
					label: qsTr("Adresse SIP")
					Layout.fillWidth: true
					onYChanged: editionLayout.ensureVisible(this)
					contentItem: TextField {
						id: newAddressTextField
						backgroundColor: DefaultStyle.grey_0
						Keys.onPressed: (event) => {
							if(event.key == Qt.Key_Up){
								if(addressesList.count > 0 )
									addressesList.itemAt(addressesList.count - 1).forceActiveFocus()
								else
									jobTextField.forceActiveFocus()
								event.accepted = true
							}else if(event.key == Qt.Key_Down){
								if(phoneNumberList.count > 0)
									phoneNumberList.itemAt(0).forceActiveFocus()
								else
									phoneNumberInputTextField.forceActiveFocus()
								event.accepted = true
							}
						}
						onEditingFinished: {
							mainItem.contact.core.appendAddress(text)
							newAddressTextField.clear()
						}
					}
				}
				Repeater {
					id: phoneNumberList
					model: VariantList {
						model: mainItem.contact && mainItem.contact.core.phoneNumbers || []
					}
					delegate: FormItemLayout {
						label: modelData.label
						contentItem: RowLayout {
							id: phoneNumberLayout
							spacing: 10 * DefaultStyle.dp
							function updateFocus(event){
								if(event.key == Qt.Key_Up){
									if(index - 1 >=0 )
										phoneNumberList.itemAt(index - 1).forceActiveFocus()
									else
										newAddressTextField.forceActiveFocus()
									event.accepted = true
								}else if(event.key == Qt.Key_Down){
									if(index + 1 < phoneNumberList.count)
										phoneNumberList.itemAt(index+1).forceActiveFocus()
									else
										phoneNumberInputTextField.forceActiveFocus()
									event.accepted = true
								}
							}
							TextField {
								id: phoneTextField
								Layout.preferredWidth: 421 * DefaultStyle.dp
								Layout.preferredHeight: height
								initialText: modelData.address
								backgroundColor: DefaultStyle.grey_0
								focus: true
								KeyNavigation.right: removePhoneButton
								Keys.onPressed: (event) => phoneNumberLayout.updateFocus(event)
								onEditingFinished: {
									if (text.length != 0) mainItem.contact.core.setPhoneNumberAt(index, qsTr("Téléphone"), text)
								}
							}
							Button {
								id: removePhoneButton
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								Layout.alignment: Qt.AlignVCenter
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								background: Item{}
								icon.source: AppIcons.closeX
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								KeyNavigation.left: phoneTextField
								Keys.onPressed: (event) => phoneNumberLayout.updateFocus(event)
								onClicked: mainItem.contact.core.removePhoneNumber(index)
							}
						}
					}
				}
				FormItemLayout {
					id: phoneNumberInput
					Layout.fillWidth: true
					label: qsTr("Phone")
					onYChanged: editionLayout.ensureVisible(this)
					contentItem: TextField {
						id: phoneNumberInputTextField
						backgroundColor: DefaultStyle.grey_0
						Keys.onPressed: (event) => {
							if(event.key == Qt.Key_Up){
								if(phoneNumberList.count > 0 )
									phoneNumberList.itemAt(phoneNumberList.count - 1).forceActiveFocus()
								else
									newAddressTextField.forceActiveFocus()
								event.accepted = true
							}else if(event.key == Qt.Key_Down){
								if(saveButton.enabled)
									saveButton.forceActiveFocus()
								else
									givenNameEdit.forceActiveFocus()
								event.accepted = true
							}
						}
						onEditingFinished: {
							if (text.length != 0) mainItem.contact.core.appendPhoneNumber(phoneNumberInput.label, text)
							text = ""
						}
					}
				}
				TemporaryText {
					id: addressesErrorText
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
					onTextChanged: editionLayout.ensureVisible(this)
				}
				Item{Layout.fillHeight: true}
			}
		}
		
	}

	
}
