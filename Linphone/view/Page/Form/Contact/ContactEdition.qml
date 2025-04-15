import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

MainRightPanel {
	id: mainItem

	property FriendGui contact
	Connections {
		target: contact.core
		function onIsSavedChanged() {
			if (contact.core.isSaved) {
				mainItem.closeEdition(contact.core.defaultFullAddress)
			}
		}
	}
    //: "Modifier contact"
    property string title: qsTr("contact_editor_title")
    //: "Enregistrer
    property string saveButtonText: qsTr("save")
	property string oldPictureUri
    property int addressCount: 0
	
	signal closeEdition(var redirectAddress)	

	Dialog {
		id: confirmDialog
		onAccepted: {
			mainItem.contact.core.undo()
			mainItem.closeEdition('')
		}
        width: Math.round(278 * DefaultStyle.dp)
        //: "Les changements seront annulés. Souhaitez-vous continuer ?"
        text: qsTr("contact_editor_dialog_cancel_change_message")
	}

	headerContent: [
			Text {
				anchors.left: parent.left
                anchors.leftMargin: Math.round(31 * DefaultStyle.dp)
				anchors.verticalCenter: parent.verticalCenter
				text: mainItem.title
				font {
                    pixelSize: Math.round(20 * DefaultStyle.dp)
                    weight: Typography.h4.weight
				}
			},
			Button {
				style: ButtonStyle.noBackground
				anchors.right: parent.right
                anchors.rightMargin: Math.round(41 * DefaultStyle.dp)
				anchors.verticalCenter: parent.verticalCenter
                width: Math.round(24 * DefaultStyle.dp)
                height: Math.round(24 * DefaultStyle.dp)
				icon.source: AppIcons.closeX
                icon.width: Math.round(24 * DefaultStyle.dp)
                icon.height: Math.round(24 * DefaultStyle.dp)
				onClicked: {
					if (contact.core.isSaved) mainItem.closeEdition('')
                    else showConfirmationLambdaPopup("", qsTr("contact_editor_dialog_cancel_change_message"), "", function(confirmed) {
						if (confirmed) {
							mainItem.contact.core.undo()
							mainItem.closeEdition('')
						}
					})
				}
			}
	]

	content: ContactLayout {
		anchors.fill: parent
		contact: mainItem.contact
		button.text: mainItem.saveButtonText
		
		// Let some time to GUI to set fields on losing focus.
		Timer{
			id: saveDelay
			interval: 200
			onTriggered:{
                //: "Veuillez saisir un prénom"
				if (mainItem.contact.core.givenName.length === 0) {
                    givenName.errorMessage = qsTr("contact_editor_mandatory_first_name_not_filled")
					return
				} else if (addressesList.count === 0 && phoneNumberList.count === 0) {
                    //: "Veuillez saisir une adresse ou un numéro de téléphone"
                    addressesErrorText.setText(qsTr("contact_editor_mandatory_address_or_number_not_filled"))
					return
				}
				mainItem.contact.core.save()
			}
		}
		button.onClicked: {
			button.forceActiveFocus()
			saveDelay.restart()
		}
		bannerContent: [
			IconLabelButton {
				id: addPictureButton
				Layout.preferredWidth: width
				visible: !mainItem.contact || mainItem.contact.core.pictureUri.length === 0
				icon.source: AppIcons.camera
                //: "Ajouter une image"
                text: qsTr("contact_editor_add_image_label")
                textSize: Typography.h4.pixelSize
                textWeight: Typography.h4.weight
				textColor: DefaultStyle.main2_700
				hoveredTextColor: DefaultStyle.main2_800
				pressedTextColor: DefaultStyle.main2_900
				KeyNavigation.down: editButton.visible ? editButton : givenNameEdit
				onClicked: fileDialog.open()
			},
			RowLayout {
				visible: mainItem.contact && mainItem.contact.core.pictureUri.length != 0
				Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(32 * DefaultStyle.dp)
				IconLabelButton {
					id: editButton
					Layout.preferredWidth: width
					icon.source: AppIcons.pencil
                    //: "Modifier"
                    text: qsTr("contact_details_edit")
					textColor: DefaultStyle.main2_700
					hoveredTextColor: DefaultStyle.main2_800
					pressedTextColor: DefaultStyle.main2_900
                    textSize: Typography.h4.pixelSize
                    textWeight: Typography.h4.weight
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
					Layout.preferredWidth: width
					icon.source: AppIcons.trashCan
                    //: "Supprimer"
                    text: qsTr("contact_details_delete")
					textColor: DefaultStyle.main2_700
					hoveredTextColor: DefaultStyle.main2_800
					pressedTextColor: DefaultStyle.main2_900
                    textSize: Typography.h4.pixelSize
                    textWeight: Typography.h4.weight
					KeyNavigation.left: editButton
					onClicked: mainItem.contact.core.pictureUri = ""
				}
			},
			Item{Layout.fillWidth: true}
		]
		content: Flickable {
			id: editionLayout
            contentWidth: Math.round(Math.min(parent.width, 421 * DefaultStyle.dp))
            width: parent.width
			contentY: 0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    editionLayout.forceActiveFocus()
                }
            }

			signal ensureVisibleRequested(Item item)

			function ensureVisible(r) {
				if (contentY >= r.y)
					contentY = r.y;
				else if (contentY+height <= r.y+r.height)
					contentY = r.y + r.height - height;
			}

			// Hack to ensure the empty textfield is really visible, because
			// its y changes too late after the editingFinished is emitted
			function connectOnce(sig, slot) {
				var f = function() {
					slot.apply(this, arguments)
					sig.disconnect(f)
				}
				sig.connect(f)
			}

			ScrollBar.vertical: Control.ScrollBar {
				anchors.right: parent.right
			}
			ScrollBar.horizontal: Control.ScrollBar {
			}
			ColumnLayout {
                spacing: Math.round(20 * DefaultStyle.dp)
				anchors.left: parent.left
				anchors.right: parent.right

				FormItemLayout {
					id: givenName
					Layout.fillWidth: true
					enableErrorText: true
                    //: "Prénom"
                    label: qsTr("contact_editor_first_name")
					contentItem: TextField {
						id: givenNameEdit
                        Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
						initialText: contact.core.givenName
						onTextEdited: {
							contact.core.givenName = givenNameEdit.text
						}
						backgroundColor: DefaultStyle.grey_0
						backgroundBorderColor: givenName.errorTextVisible ? DefaultStyle.danger_500main : DefaultStyle.grey_200
						KeyNavigation.up: editButton.visible ? editButton : addPictureButton
						KeyNavigation.down: nameTextField
					}
				}
                FormItemLayout {
                    //: "Nom"
                    label: qsTr("contact_editor_last_name")
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
                    //: "Entreprise"
                    label: qsTr("contact_editor_company")
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
                    //: "Fonction"
                    label: qsTr("contact_editor_job_title")
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
                            spacing: Math.round(10 * DefaultStyle.dp)
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
                                Layout.preferredWidth: Math.round(421 * DefaultStyle.dp)
								Layout.preferredHeight: height
								onEditingFinished: {
                                    var label = qsTr("sip_address")
                                    if (text.length != 0) mainItem.contact.core.setAddressAt(index, label, text)
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
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
								Layout.alignment: Qt.AlignVCenter
								icon.source: AppIcons.closeX
                                icon.width: Math.round(24 * DefaultStyle.dp)
                                icon.height: Math.round(24 * DefaultStyle.dp)
								style: ButtonStyle.noBackground
								KeyNavigation.left: addressTextField
								Keys.onPressed: (event) => addressLayout.updateFocus(event)
								onClicked: mainItem.contact.core.removeAddress(index)
							}
						}
					}
				}
				FormItemLayout {
					id: newAddressSipTextField
                    label: qsTr("sip_address")
					Layout.fillWidth: true
					onYChanged: {
						editionLayout.ensureVisibleRequested(newAddressSipTextField)
					}
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
							if (text.length > 0) mainItem.contact.core.appendAddress(text)
							newAddressTextField.clear()
							editionLayout.connectOnce(editionLayout.ensureVisibleRequested, editionLayout.ensureVisible)
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
                            spacing: Math.round(10 * DefaultStyle.dp)
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
                                Layout.preferredWidth: Math.round(421 * DefaultStyle.dp)
								Layout.preferredHeight: height
								initialText: modelData.address
								backgroundColor: DefaultStyle.grey_0
								focus: true
								KeyNavigation.right: removePhoneButton
								Keys.onPressed: (event) => phoneNumberLayout.updateFocus(event)
								onEditingFinished: {
                                    //: "Téléphone"
                                    if (text.length != 0) mainItem.contact.core.setPhoneNumberAt(index, qsTr("phone"), text)
								}
							}
							Button {
								id: removePhoneButton
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
								Layout.alignment: Qt.AlignVCenter
								style: ButtonStyle.noBackground
								icon.source: AppIcons.closeX
                                icon.width: Math.round(24 * DefaultStyle.dp)
                                icon.height: Math.round(24 * DefaultStyle.dp)
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
                    label: qsTr("phone")
					onYChanged: {
						editionLayout.ensureVisibleRequested(phoneNumberInput)
					}
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
							phoneNumberInputTextField.clear()
							editionLayout.connectOnce(editionLayout.ensureVisibleRequested, editionLayout.ensureVisible)
						}
					}
				}
				TemporaryText {
					id: addressesErrorText
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
					onTextChanged: if(addressesErrorText.text.length > 0) editionLayout.ensureVisible(this)
				}
				Item{Layout.fillHeight: true}
			}
		}
		
	}

	
}
