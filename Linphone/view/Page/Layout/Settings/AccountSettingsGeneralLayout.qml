import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractSettingsLayout {
	id: mainItem
	saveButtonVisible: false

	width: parent?.width
	contentModel: [
		{
			title: qsTr("Détails"),
			subTitle: qsTr("Editer les informations de votre compte."),
			contentComponent: accountParametersComponent
		},
		{
			title: qsTr("Vos appareils"),
			subTitle: qsTr("La liste des appareils connectés à votre compte. Vous pouvez retirer les appareils que vous n’utilisez plus."),
			contentComponent: accountDevicesComponent
		}
	]

	property alias account: mainItem.model

	// Account parameters
	//////////////////////////

	Component {
		id: accountParametersComponent
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 20 * DefaultStyle.dp
			Avatar {
				id: avatar
				account: model
				displayPresence: false
				Layout.preferredWidth: 100 * DefaultStyle.dp
				Layout.preferredHeight: 100 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
			}
			IconLabelButton {
				visible: model.core.pictureUri.length === 0
				Layout.preferredWidth: width
				icon.source: AppIcons.camera
				icon.width: 17 * DefaultStyle.dp
				icon.height: 17 * DefaultStyle.dp
				text: qsTr("Ajouter une image")
				style: ButtonStyle.noBackground
				onClicked: fileDialog.open()
				Layout.alignment: Qt.AlignHCenter
			}
			RowLayout {
				visible: model.core.pictureUri.length > 0
				Layout.alignment: Qt.AlignHCenter
				spacing: 5 * DefaultStyle.dp
				IconLabelButton {
					Layout.preferredWidth: width
					icon.source: AppIcons.pencil
					icon.width: 17 * DefaultStyle.dp
					icon.height: 17 * DefaultStyle.dp
					text: qsTr("Modifier l'image")
					style: ButtonStyle.noBackground
					onClicked: fileDialog.open()
				}
				IconLabelButton {
					Layout.preferredWidth: width
					icon.source: AppIcons.trashCan
					icon.width: 17 * DefaultStyle.dp
					icon.height: 17 * DefaultStyle.dp
					text: qsTr("Supprimer l'image")
					style: ButtonStyle.noBackground
					onClicked: model.core.pictureUri = ""
				}
			}
			FileDialog {
				id: fileDialog
				currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
				onAccepted: {
					var avatarPath = UtilsCpp.createAvatar( selectedFile )
					if(avatarPath){
						model.core.pictureUri = avatarPath
						avatar.model = model
					}
				}
			}
			RowLayout {
				Layout.fillWidth: true
				spacing: 5 * DefaultStyle.dp
				Text {
					Layout.alignment: Qt.AlignLeft
					text: qsTr("Adresse SIP :")
					color: DefaultStyle.main2_600
					font: Typography.p2l
				}
				Text {
					Layout.alignment: Qt.AlignLeft
					text: model.core.identityAddress
					color: DefaultStyle.main2_600
					font: Typography.p1
				}
				Item {
					Layout.fillWidth: true
				}
				IconLabelButton {
					Layout.alignment: Qt.AlignRight
					icon.source: AppIcons.copy
					style: ButtonStyle.noBackground
					onClicked: UtilsCpp.copyToClipboard(model.core.identityAddress)
				}
			}
			ColumnLayout {
				spacing: 5 * DefaultStyle.dp
				Layout.alignment: Qt.AlignLeft
				Text {
					text: qsTr("Nom d’affichage")
					color: DefaultStyle.main2_600
					font: Typography.p2l
				}
				Text {
					text: qsTr("Le nom qui sera affiché à vos correspondants lors de vos échanges.")
					color: DefaultStyle.main2_600
					font: Typography.p1
				}
			}
			TextField {
				Layout.alignment: Qt.AlignLeft
				Layout.fillWidth: true
				Layout.preferredHeight: 49 * DefaultStyle.dp
				initialText: model.core.displayName
				backgroundColor: DefaultStyle.grey_100
				onEditingFinished: {
					if (text.length != 0) model.core.displayName = text
				}
				toValidate: true
			}
			Text {
				text: qsTr("Indicatif international*")
				color: DefaultStyle.main2_600
				font: Typography.p2l
			}
			ComboSetting {
				Layout.fillWidth: true
				Layout.topMargin: -15 * DefaultStyle.dp
				entries: account.core.dialPlans
				propertyName: "dialPlan"
				propertyOwnerGui: account
				textRole: 'text'
				flagRole: 'flag'
			}
			SwitchSetting {
				titleText: account?.core.humaneReadableRegistrationState
				subTitleText: account?.core.humaneReadableRegistrationStateExplained
				propertyName: "registerEnabled"
				propertyOwnerGui: account
			}
			RowLayout {
				id:mainItem
				spacing : 20 * DefaultStyle.dp
				ColumnLayout {
					spacing : 5 * DefaultStyle.dp
					Text {
						text: qsTr("Supprimer mon compte")
						font: Typography.p2l
						wrapMode: Text.WordWrap
						color: DefaultStyle.danger_500main
						Layout.fillWidth: true
					}
					Text {
						text: qsTr("Votre compte sera retiré de ce client linphone, mais vous restez connecté sur vos autres clients")
						font: Typography.p1
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_500main
						Layout.fillWidth: true
					}
				}
				Item {
					Layout.fillWidth: true
				}
				BigButton {
					style: ButtonStyle.noBackgroundRed
					Layout.alignment: Qt.AlignRight
					Layout.rightMargin: 5 * DefaultStyle.dp
					icon.source: AppIcons.trashCan
					onClicked: {
						var mainWin = UtilsCpp.getMainWindow()
						mainWin.showConfirmationLambdaPopup("",
							qsTr("Supprimer ") + (model.core.displayName.length > 0 ? model.core.displayName : qsTr("le compte")) + " ?",
							qsTr("Vous pouvez vous reconnecter à tout moment en cliquant sur \"Ajouter un compte\".\nCependant toutes les informations stockées sur ce périphérique seront supprimées."),
							function (confirmed) {
								if (confirmed) {
									account.core.removeAccount()
								}
							}
						)
					}
				}
			}
		}
	}


	// Account devices
	//////////////////////////

	Component {
		id: accountDevicesComponent
		RoundedPane {
			Layout.fillWidth: true
			Layout.fillHeight: true
			// Layout.minimumHeight: account.core.devices.length * 133 * DefaultStyle.dp + (account.core.devices.length - 1) * 15 * DefaultStyle.dp +  2 * 21 * DefaultStyle.dp
			Layout.rightMargin: 30 * DefaultStyle.dp
			Layout.topMargin: 20 * DefaultStyle.dp
			Layout.bottomMargin: 4 * DefaultStyle.dp
			Layout.leftMargin: 44 * DefaultStyle.dp
			topPadding: 21 * DefaultStyle.dp
			bottomPadding: 21 * DefaultStyle.dp
			leftPadding: 17 * DefaultStyle.dp
			rightPadding: 17 * DefaultStyle.dp
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.grey_100
				radius: 15 * DefaultStyle.dp
			}
			contentItem: ColumnLayout {
				spacing: 15 * DefaultStyle.dp
                BusyIndicator {
                    Layout.preferredWidth: 60 * DefaultStyle.dp
                    Layout.preferredHeight: 60 * DefaultStyle.dp
                    Layout.alignment: Qt.AlignHCenter
                    visible: devices.loading
                }

				Repeater {
					id: devices
                    visible: !loading
                    property bool loading
                    Component.onCompleted: loading = true
					model: AccountDeviceProxy {
						id: accountDeviceProxy
						account: model
                        onDevicesSet: devices.loading = false;
					}
                    Control.Control {
						Layout.fillWidth: true
						height: 133 * DefaultStyle.dp
						topPadding: 26 * DefaultStyle.dp
						bottomPadding: 26 * DefaultStyle.dp
						rightPadding: 36 * DefaultStyle.dp
						leftPadding: 33 * DefaultStyle.dp
						background: Rectangle {
							anchors.fill: parent
							color: DefaultStyle.grey_0
							radius: 10 * DefaultStyle.dp
						}
						contentItem: ColumnLayout {
							width: parent.width
							spacing: 20 * DefaultStyle.dp
							RowLayout {
								spacing: 5 * DefaultStyle.dp
								EffectImage {
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									fillMode: Image.PreserveAspectFit
									colorizationColor: DefaultStyle.main2_600
									imageSource: modelData.core.userAgent.toLowerCase().includes('ios') | modelData.core.userAgent.toLowerCase().includes('android') ? AppIcons.mobile : AppIcons.desktop
								}
								Text {
									text: modelData.core.deviceName
									color: DefaultStyle.main2_600
									font: Typography.p2
								}
								Item {
									Layout.fillWidth: true
								}
								MediumButton {
									Layout.alignment: Qt.AlignRight
									text: qsTr("Supprimer")
									icon.source: AppIcons.trashCan
									icon.width: 16 * DefaultStyle.dp
									icon.height: 16 * DefaultStyle.dp
									style: ButtonStyle.tertiary
									onClicked: {
										var mainWin = UtilsCpp.getMainWindow()
										mainWin.showConfirmationLambdaPopup("",
											qsTr("Supprimer ") + modelData.core.deviceName + " ?", "",
											function (confirmed) {
												if (confirmed) {
													accountDeviceProxy.deleteDevice(modelData)
												}
											}
										)
									}
								}
							}
							RowLayout {
								spacing: 5 * DefaultStyle.dp
								Text {
									text: qsTr("Dernière connexion:")
									color: DefaultStyle.main2_600
									font: Typography.p2
								}
								EffectImage {
									Layout.preferredWidth: 20 * DefaultStyle.dp
									Layout.preferredHeight: 20 * DefaultStyle.dp
									imageSource: AppIcons.calendar
									colorizationColor: DefaultStyle.main2_600
									fillMode: Image.PreserveAspectFit
								}
								Text {
									text: UtilsCpp.formatDate(modelData.core.lastUpdateTimestamp,false)
									color: DefaultStyle.main2_600
									font: Typography.p1
								}
								EffectImage {
									Layout.preferredWidth: 20 * DefaultStyle.dp
									Layout.preferredHeight: 20 * DefaultStyle.dp
									imageSource: AppIcons.clock
									colorizationColor: DefaultStyle.main2_600
									fillMode: Image.PreserveAspectFit
								}
								Text {
									text: UtilsCpp.formatTime(modelData.core.lastUpdateTimestamp)
									color: DefaultStyle.main2_600
									font: Typography.p1
								}
							}
						}
					}
				}
			}
		}
	}
}
