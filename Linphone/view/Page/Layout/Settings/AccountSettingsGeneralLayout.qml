import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
	id: mainItem
	saveButtonVisible: false

	width: parent?.width
	contentModel: [
		{
            //: "Détails"
            title: qsTr("manage_account_details_title"),
            //: Éditer les informations de votre compte.
            subTitle: qsTr("manage_account_details_subtitle"),
			contentComponent: accountParametersComponent
		},
		{
            visible: SettingsCpp.showAccountDevices,
            //: "Vos appareils"
            title: qsTr("manage_account_devices_title"),
            //: "La liste des appareils connectés à votre compte. Vous pouvez retirer les appareils que vous n’utilisez plus."
            subTitle: qsTr("manage_account_devices_subtitle"),
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
            spacing: Utils.getSizeWithScreenRatio(20)
			Avatar {
				id: avatar
				account: model
				displayPresence: false
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(100)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
				Layout.alignment: Qt.AlignHCenter
			}
			IconLabelButton {
				visible: model.core.pictureUri.length === 0
				Layout.preferredWidth: width
				icon.source: AppIcons.camera
                icon.width: Utils.getSizeWithScreenRatio(17)
                icon.height: Utils.getSizeWithScreenRatio(17)
                //: "Ajouter une image"
                text: qsTr("manage_account_add_picture")
				style: ButtonStyle.noBackground
				onClicked: fileDialog.open()
				Layout.alignment: Qt.AlignHCenter
			}
			RowLayout {
				visible: model.core.pictureUri.length > 0
				Layout.alignment: Qt.AlignHCenter
                spacing: Utils.getSizeWithScreenRatio(5)
				IconLabelButton {
					Layout.preferredWidth: width
					icon.source: AppIcons.pencil
                    icon.width: Utils.getSizeWithScreenRatio(17)
                    icon.height: Utils.getSizeWithScreenRatio(17)
                    //: "Modifier l'image"
                    text: qsTr("manage_account_edit_picture")
					style: ButtonStyle.noBackground
					onClicked: fileDialog.open()
				}
				IconLabelButton {
					Layout.preferredWidth: width
					icon.source: AppIcons.trashCan
                    icon.width: Utils.getSizeWithScreenRatio(17)
                    icon.height: Utils.getSizeWithScreenRatio(17)
                    //: "Supprimer l'image"
                    text: qsTr("manage_account_remove_picture")
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
                spacing: Utils.getSizeWithScreenRatio(5)
				Text {
					Layout.alignment: Qt.AlignLeft
					//: SIP address
                    text: "%1 :".arg(qsTr("sip_address"))
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
					onClicked: {
						if (UtilsCpp.copyToClipboard(model.core.identityAddress)) {
							//: Copied
							UtilsCpp.showInformationPopup(qsTr("copied"),
							//: Your SIP address has been copied in the clipboard
							qsTr("account_settings_sip_address_copied_message"))
						} else {
							UtilsCpp.showInformationPopup(qsTr("error"),
							//: Error copying your SIP address
							qsTr("account_settings_sip_address_copied_error_message"), false)
						}
					}
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(5)
				Layout.alignment: Qt.AlignLeft
				Text {
                    //: "Nom d'affichage
                    text: qsTr("sip_address_display_name")
					color: DefaultStyle.main2_600
					font: Typography.p2l
				}
				Text {
                    //: "Le nom qui sera affiché à vos correspondants lors de vos échanges."
                    text: qsTr("sip_address_display_name_explaination")
					color: DefaultStyle.main2_600
					font: Typography.p1
				}
			}
			TextField {
				Layout.alignment: Qt.AlignLeft
				Layout.fillWidth: true
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
				initialText: model.core.displayName
				backgroundColor: DefaultStyle.grey_100
				onEditingFinished: {
					if (text.length != 0) model.core.displayName = text
				}
				toValidate: true
			}
			Text {
                //: Indicatif international*
                text: qsTr("manage_account_international_prefix")
				color: DefaultStyle.main2_600
				font: Typography.p2l
			}
			ComboSetting {
				Layout.fillWidth: true
                Layout.topMargin: Utils.getSizeWithScreenRatio(15)
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
                spacing : Utils.getSizeWithScreenRatio(20)
				ColumnLayout {
                    spacing : Utils.getSizeWithScreenRatio(5)
					Text {
                        //: "Déconnecter mon compte"
                        text: qsTr("manage_account_delete")
						font: Typography.p2l
						wrapMode: Text.WordWrap
						color: DefaultStyle.danger_500_main
						Layout.fillWidth: true
					}
					Text {
                        // "Votre compte sera retiré de ce client linphone, mais vous restez connecté sur vos autres clients
                        text: qsTr("manage_account_delete_message")
						font: Typography.p1
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_500_main
						Layout.fillWidth: true
					}
				}
				Item {
					Layout.fillWidth: true
				}
				BigButton {
					style: ButtonStyle.noBackgroundRed
					Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(5)
					icon.source: AppIcons.trashCan
					onClicked: {
						var mainWin = UtilsCpp.getMainWindow()
						mainWin.showConfirmationLambdaPopup("",
                            //: "Se déconnecter du compte ?"
                            qsTr("manage_account_dialog_remove_account_title"),
                            //: Si vous souhaitez supprimer définitivement votre compte rendez-vous sur : https://sip.linphone.org
                            qsTr("manage_account_dialog_remove_account_message"),
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
            // Layout.minimumHeight: account.core.devices.length *Utils.getSizeWithScreenRatio(133) + (account.core.devices.length - 1) *Utils.getSizeWithScreenRatio(15) +  2 *Utils.getSizeWithScreenRatio(21)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(30)
            Layout.topMargin: Utils.getSizeWithScreenRatio(20)
            Layout.bottomMargin: Utils.getSizeWithScreenRatio(4)
            Layout.leftMargin: Utils.getSizeWithScreenRatio(44)
            topPadding: Utils.getSizeWithScreenRatio(21)
            bottomPadding: Utils.getSizeWithScreenRatio(21)
            leftPadding: Utils.getSizeWithScreenRatio(17)
            rightPadding: Utils.getSizeWithScreenRatio(17)
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.grey_100
                radius: Utils.getSizeWithScreenRatio(15)
			}
			contentItem: ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(15)
                BusyIndicator {
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(60)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(60)
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
						account: mainItem.model
                        onDevicesSet: devices.loading = false;
                        onRequestError: (errorMessage) => {
                            devices.loading = false;
                            //: Erreur
                            mainWindow.showInformationPopup(qsTr("error"), errorMessage, false)
                        }
					}
                    Control.Control {
						Layout.fillWidth: true
                        height: Utils.getSizeWithScreenRatio(133)
                        topPadding: Utils.getSizeWithScreenRatio(26)
                        bottomPadding: Utils.getSizeWithScreenRatio(26)
                        rightPadding: Utils.getSizeWithScreenRatio(36)
                        leftPadding: Utils.getSizeWithScreenRatio(33)
						background: Rectangle {
							anchors.fill: parent
							color: DefaultStyle.grey_0
                            radius: Utils.getSizeWithScreenRatio(10)
						}
						contentItem: ColumnLayout {
							width: parent.width
                            spacing: Utils.getSizeWithScreenRatio(20)
							RowLayout {
                                spacing: Utils.getSizeWithScreenRatio(5)
								EffectImage {
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
                                    //: "Supprimer"
                                    text: qsTr("manage_account_device_remove")
									icon.source: AppIcons.trashCan
                                    icon.width: Utils.getSizeWithScreenRatio(16)
                                    icon.height: Utils.getSizeWithScreenRatio(16)
									style: ButtonStyle.tertiary
									onClicked: {
										var mainWin = UtilsCpp.getMainWindow()
										mainWin.showConfirmationLambdaPopup("",
                                            //:"Supprimer %1 ?"
                                            qsTr("manage_account_device_remove_confirm_dialog").arg(modelData.core.deviceName), "",
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
                                spacing: Utils.getSizeWithScreenRatio(5)
								Text {
                                    //: "Dernière connexion:"
                                    text: qsTr("manage_account_device_last_connection")
									color: DefaultStyle.main2_600
									font: Typography.p2
								}
								EffectImage {
									visible: dateText.lastDate != ""
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
									imageSource: AppIcons.calendarBlank
									colorizationColor: DefaultStyle.main2_600
									fillMode: Image.PreserveAspectFit
								}
								Text {
									id: dateText
									property string lastDate: UtilsCpp.formatDate(modelData.core.lastUpdateTimestamp,false)
									text: lastDate != ""
										? lastDate
										//: "No information"
										: qsTr("device_last_updated_time_no_info")
									color: DefaultStyle.main2_600
									font: Typography.p1
								}
								EffectImage {
									visible: dateText.lastDate != ""
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
									imageSource: AppIcons.clock
									colorizationColor: DefaultStyle.main2_600
									fillMode: Image.PreserveAspectFit
								}
								Text {
									visible: dateText.lastDate != ""
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
