import QtCore
import QtQuick 2.15
import QtQuick.Controls as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp 1.0

RightPanelLayout {
	id: mainItem

	property FriendGui contact
	Connections {
		target: contact.core
		onIsSavedChanged: {
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
					// contact.core.pictureUri = mainItem.oldPictureUri
					mainItem.contact.core.undo()
					mainItem.closeEdition()
				}
			}
	]

	content: ColumnLayout {
		anchors.centerIn: parent
		// anchors.leftMargin: 103 * DefaultStyle.dp
		ColumnLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: 69 * DefaultStyle.dp
			Avatar {
				contact: mainItem.contact
				Layout.preferredWidth: 72 * DefaultStyle.dp
				Layout.preferredHeight: 72 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
			}
			IconLabelButton {
				visible: !mainItem.contact || mainItem.contact.core.pictureUri.length === 0
				Layout.preferredWidth: width
				Layout.preferredHeight: 17 * DefaultStyle.dp
				iconSource: AppIcons.camera
				iconSize: 17 * DefaultStyle.dp
				text: qsTr("Ajouter une image")
				onClicked: fileDialog.open()
			}
			RowLayout {
				visible: mainItem.contact && mainItem.contact.core.pictureUri.length != 0
				Layout.alignment: Qt.AlignHCenter
				IconLabelButton {
					Layout.preferredWidth: width
					Layout.preferredHeight: 17 * DefaultStyle.dp
					iconSource: AppIcons.pencil
					iconSize: 17 * DefaultStyle.dp
					text: qsTr("Modifier")
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
					Layout.preferredHeight: 17 * DefaultStyle.dp
					Layout.preferredWidth: width
					iconSize: 17 * DefaultStyle.dp
					iconSource: AppIcons.trashCan
					text: qsTr("Supprimer")
					onClicked: mainItem.contact.core.pictureUri = ""
				}
			}
		}
		RowLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillHeight: true
			Layout.fillWidth: true
			spacing: 100 * DefaultStyle.dp
			Layout.topMargin: 50 * DefaultStyle.dp
			Layout.bottomMargin: 50 * DefaultStyle.dp
			ColumnLayout {
				spacing: 20 * DefaultStyle.dp
				FormItemLayout {
					label: qsTr("Prénom")
					contentItem: TextField {
						initialText: contact.core.givenName
						onEditingFinished: contact.core.givenName = text
						backgroundColor: DefaultStyle.grey_0
					}
				}
				FormItemLayout {
					label: qsTr("Nom")
					contentItem: TextField {
						initialText: contact.core.familyName
						onEditingFinished: contact.core.familyName = text
						backgroundColor: DefaultStyle.grey_0
					}
				}
				FormItemLayout {
					label: qsTr("Entreprise")
					contentItem: TextField {
						initialText: contact.core.organization
						onEditingFinished: contact.core.organization = text
						backgroundColor: DefaultStyle.grey_0
					}
				}
				FormItemLayout {
					label: qsTr("Fonction")
					contentItem: TextField {
						initialText: contact.core.job
						onEditingFinished: contact.core.job = text
						backgroundColor: DefaultStyle.grey_0
					}
				}
				Item{Layout.fillHeight: true}
			}
			Control.ScrollView {
				Layout.fillHeight: true
				contentHeight: content.height
				ColumnLayout {
					id: content
					anchors.rightMargin: 10 * DefaultStyle.dp
					spacing: 20 * DefaultStyle.dp
					Repeater {
						model: VariantList {
							model: mainItem.contact && mainItem.contact.core.addresses || []
						}
						delegate: FormItemLayout {
								label: modelData.label
								contentItem: RowLayout {
									TextField {
										onEditingFinished: {
											if (text.length != 0) mainItem.contact.core.setAddressAt(index, qsTr("Address SIP"), text)
										}
										initialText: modelData.address
										backgroundColor: DefaultStyle.grey_0
										Layout.preferredWidth: width
										Layout.preferredHeight: height
									}
									Button {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										Layout.alignment: Qt.AlignVCenter
										background: Item{}
										icon.source: AppIcons.closeX
										width: 24 * DefaultStyle.dp
										height: 24 * DefaultStyle.dp
										icon.width: 24 * DefaultStyle.dp
										icon.height: 24 * DefaultStyle.dp
										onClicked: mainItem.contact.core.removeAddress(index)
									}
								}
							}
					}
					RowLayout {
						FormItemLayout {
							label: qsTr("Adresse SIP")
							contentItem: TextField {
								backgroundColor: DefaultStyle.grey_0
								onEditingFinished: {
									if (text.length != 0) mainItem.contact.core.appendAddress(text)
									text = ""
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
						model: VariantList {
							model: mainItem.contact && mainItem.contact.core.phoneNumbers || []
						}
						delegate: RowLayout {
							FormItemLayout {
								label: modelData.label
								contentItem: TextField {
									initialText: modelData.address
									onEditingFinished: {
										if (text.length != 0) mainItem.contact.core.setPhoneNumberAt(index, qsTr("Téléphone"), text)
									}
									backgroundColor: DefaultStyle.grey_0
								}
							}
							Button {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								background: Item{}
								icon.source: AppIcons.closeX
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								onClicked: mainItem.contact.core.removePhoneNumber(index)
							}
						}
					}
					RowLayout {
						FormItemLayout {
							label: qsTr("Phone")
							contentItem: TextField {
								backgroundColor: DefaultStyle.grey_0
								onEditingFinished: {
									if (text.length != 0) mainItem.contact.core.appendPhoneNumber(label, text)
									setText("")
								}
							}
						}
						Item {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
					}
					Item{Layout.fillHeight: true}
				}
				Control.ScrollBar.vertical: Control.ScrollBar{
					id: scrollbar
					active: true
					interactive: true
					policy: Control.ScrollBar.AsNeeded
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					anchors.leftMargin: 15 * DefaultStyle.dp
				}
				Control.ScrollBar.horizontal: Control.ScrollBar{
					visible: false
				}
			}
		}

		Button {
			Layout.bottomMargin: 100 * DefaultStyle.dp
			Layout.preferredWidth: 165 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			enabled: mainItem.contact && mainItem.contact.core.givenName.length > 0
			text: mainItem.saveButtonText
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			onClicked: {
				mainItem.contact.core.save()
				mainItem.closeEdition()
			}
		}
	}
}