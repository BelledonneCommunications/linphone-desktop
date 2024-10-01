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

	content: ColumnLayout {
		anchors.fill: parent
		spacing : 0
		ColumnLayout {
			spacing: 8 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: 69 * DefaultStyle.dp
			Avatar {
				contact: mainItem.contact
				Layout.preferredWidth: 72 * DefaultStyle.dp
				Layout.preferredHeight: 72 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
			}
			IconLabelButton {
				id: addPictureButton
				visible: !mainItem.contact || mainItem.contact.core.pictureUri.length === 0
				Layout.preferredWidth: width
				Layout.preferredHeight: 17 * DefaultStyle.dp
				iconSource: AppIcons.camera
				iconSize: 17 * DefaultStyle.dp
				backgroundColor: "transparent"
				text: qsTr("Ajouter une image")
				KeyNavigation.down: editButton.visible ? editButton : givenNameEdit
				onClicked: fileDialog.open()
			}
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
					KeyNavigation.down: givenNameEdit
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
					KeyNavigation.down: givenNameEdit
					onClicked: mainItem.contact.core.pictureUri = ""
				}
			}
		}
		RowLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: 63 * DefaultStyle.dp
			Layout.bottomMargin: 78 * DefaultStyle.dp
			spacing: 100 * DefaultStyle.dp
			Flickable {
				Layout.preferredWidth: contentWidth
				Layout.fillHeight: true
				Layout.leftMargin: 100 * DefaultStyle.dp
				contentWidth: content.implicitWidth
				contentHeight: content.height
				clip: true

				ColumnLayout {
					spacing: 20 * DefaultStyle.dp
					anchors.fill: parent
					FormItemLayout {
						id: givenName
						enableErrorText: true
						label: qsTr("Prénom")
						contentItem: TextField {
							id: givenNameEdit
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
					Item{Layout.fillHeight: true}
				}
			}
			Flickable {
				id: addressesFlickable
				Layout.preferredWidth: contentWidth
				Layout.fillHeight: true
				Layout.rightMargin: 76 * DefaultStyle.dp
				contentWidth: content.implicitWidth
				contentHeight: content.implicitHeight
				clip: true

				flickableDirection: Flickable.VerticalFlick
				function ensureVisible(r)
				{
					if (contentY >= r.y)
						contentY = r.y;
					else if (contentY+height <= r.y+r.height+content.spacing)
						contentY = r.y+r.height-height;
				}

				Control.ScrollBar.vertical: Control.ScrollBar{
					id: scrollbar
					active: true
					interactive: true
					policy: Control.ScrollBar.AlwaysOff
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					anchors.leftMargin: 15 * DefaultStyle.dp
				}
				Control.ScrollBar.horizontal: Control.ScrollBar{
					visible: false
				}
				ColumnLayout {
					id: content
					anchors.fill: parent
					spacing: 20 * DefaultStyle.dp
					Repeater {
						id: addressesList
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
									onEditingFinished: {
										if (text.length != 0) mainItem.contact.core.setAddressAt(index, qsTr("Adresse SIP"), text)
									}
									property string _initialText: modelData.address
									initialText: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_initialText) : _initialText
									backgroundColor: DefaultStyle.grey_0
									Layout.preferredWidth: width
									Layout.preferredHeight: height
									focus: true
									KeyNavigation.right: removeAddressButton
									Keys.onPressed: (event) => addressLayout.updateFocus(event)
								}
								Button {
									id: removeAddressButton
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									Layout.alignment: Qt.AlignVCenter
									background: Item{}
									icon.source: AppIcons.closeX
									width: 24 * DefaultStyle.dp
									height: 24 * DefaultStyle.dp
									icon.width: 24 * DefaultStyle.dp
									icon.height: 24 * DefaultStyle.dp
									KeyNavigation.left: addressTextField
									Keys.onPressed: (event) => addressLayout.updateFocus(event)
									onClicked: mainItem.contact.core.removeAddress(index)
								}
							}
						}
					}
					RowLayout {
						onYChanged: addressesFlickable.ensureVisible(this)
						spacing: 10 * DefaultStyle.dp
						FormItemLayout {
							label: qsTr("Adresse SIP")
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
						Item {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
					}
					Repeater {
						// phone numbers
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
											addressesList.phoneNumberList(index+1).forceActiveFocus()
										else
											phoneNumberInputTextField.forceActiveFocus()
										event.accepted = true
									}
								}
								TextField {
									id: phoneTextField
									initialText: modelData.address
									onTextEdited: {
										if (text.length != 0) mainItem.contact.core.setPhoneNumberAt(index, qsTr("Téléphone"), text)
									}
									backgroundColor: DefaultStyle.grey_0
									Layout.preferredWidth: width
									Layout.preferredHeight: height
									focus: true
									KeyNavigation.right: removePhoneButton
									Keys.onPressed: (event) => phoneNumberLayout.updateFocus(event)
								}
								Button {
									id: removePhoneButton
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									Layout.alignment: Qt.AlignVCenter
									background: Item{}
									icon.source: AppIcons.closeX
									width: 24 * DefaultStyle.dp
									height: 24 * DefaultStyle.dp
									icon.width: 24 * DefaultStyle.dp
									icon.height: 24 * DefaultStyle.dp
									KeyNavigation.left: phoneTextField
									Keys.onPressed: (event) => phoneNumberLayout.updateFocus(event)
									onClicked: mainItem.contact.core.removePhoneNumber(index)
								}
							}
						}
					}
					RowLayout {
						onYChanged: addressesFlickable.ensureVisible(this)
						spacing: 10 * DefaultStyle.dp
						FormItemLayout {
							id: phoneNumberInput
							label: qsTr("Phone")
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
						Item {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
					}
					TemporaryText {
						id: addressesErrorText
						wrapMode: Text.WordWrap
						elide: Text.ElideRight
						Layout.fillWidth: true
					}
					Item{Layout.fillHeight: true}
				}
			}
		}

		Button {
			id: saveButton
			Layout.bottomMargin: 100 * DefaultStyle.dp
			Layout.preferredWidth: 165 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			enabled: mainItem.contact && mainItem.contact.core.allAddresses.length > 0
			text: mainItem.saveButtonText
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			KeyNavigation.up: phoneNumberInputTextField
			KeyNavigation.down: givenNameEdit
			onClicked: {
				if (givenNameEdit.text.length === 0 || (addressesList.count === 0 && phoneNumberList.count === 0)) {
					if (givenNameEdit.text.length === 0) givenName.errorMessage = qsTr("Veuillez saisir un prénom")
					if (addressesList.count === 0 && phoneNumberList.count === 0) addressesErrorText.text = qsTr("Veuillez saisir une adresse ou un numéro de téléphone")
					return
				}
				mainItem.contact.core.save()
				mainItem.closeEdition()
			}
		}
	}
}
