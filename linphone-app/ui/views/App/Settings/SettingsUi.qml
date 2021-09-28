import QtQuick 2.7
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0

import App.Styles 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

import 'SettingsUi.js' as Logic

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		// -------------------------------------------------------------------------
		// Languages.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('languagesTitle')
			width: parent.width
			
			FormLine {
				FormGroup {
					label: qsTr('languagesLabel')
					
					ComboBox {
						textRole: 'key'
						
						Component.onCompleted: {
							var locales = Logic.getAvailableLocales()
							model = locales
							
							var locale = App.configLocale
							if (!locale.length) {
								currentIndex = 0
								return
							}
							
							var value = Qt.locale(locale).name
							currentIndex = Number(Utils.findIndex(locales, function (locale) {
								return locale.value === value
							}))
						}
						
						onActivated: Logic.setLocale(model[index].value)
					}
				}
			}
			Form {
				//: 'Fonts' : title of fonts section in settings
				title: qsTr('fontsTitle')
				width: parent.width
				FormLine {
					FormGroup {
						//: 'Text Messages' : Label for changing text message fonts
						label: qsTr('fontsTextChange')
						RowLayout{
							ActionButton {
								icon: 'options'
								iconSize: 25
								onClicked: fontDialog.visible = true
								Layout.preferredWidth: 25
								FontDialog {
									id: fontDialog
									//: 'Select a new font' : Popup title for choosing new fonts
									title: qsTr('fontsPopupTitle')
									visible:false
									font: SettingsModel.textMessageFont
									onAccepted: {
										SettingsModel.textMessageFont = fontDialog.font
									}
									onRejected: {
									}
								}
							}
							Text{
								Layout.leftMargin: 18
								Layout.fillWidth: true
								text: SettingsModel.textMessageFont.family +", "+SettingsModel.textMessageFont.pointSize
								font {
										bold: true
										pointSize: FormTableStyle.entry.text.pointSize
								}
							}
						}
						
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Paths.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('pathsTitle')
			visible: SettingsModel.videoSupported ||
					 SettingsModel.callRecorderEnabled ||
					 SettingsModel.chatEnabled ||
					 SettingsModel.developerSettingsEnabled
			width: parent.width
			
			FormLine {
				visible: SettingsModel.videoSupported
				
				FormGroup {
					label: qsTr('savedScreenshotsLabel')
					
					FileChooserButton {
						selectedFile: SettingsModel.savedScreenshotsFolder
						selectFolder: true
						
						onAccepted: SettingsModel.savedScreenshotsFolder = selectedFile
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.callRecorderEnabled || SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('savedCallsLabel')
					
					FileChooserButton {
						selectedFile: SettingsModel.savedCallsFolder
						selectFolder: true
						
						onAccepted: SettingsModel.savedCallsFolder = selectedFile
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.chatEnabled || SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('downloadLabel')
					
					FileChooserButton {
						selectedFile: SettingsModel.downloadFolder
						selectFolder: true
						
						onAccepted: SettingsModel.downloadFolder = selectedFile
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Data.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('dataTitle')
			visible: SettingsModel.contactsEnabled || SettingsModel.developerSettingsEnabled
			width: parent.width
		}
		
		TextButtonB {
			anchors.right: parent.right
			text: qsTr('cleanAvatars')
			visible: SettingsModel.contactsEnabled || SettingsModel.developerSettingsEnabled
			
			onClicked: Logic.cleanAvatars()
		}
		
		// -------------------------------------------------------------------------
		// Other.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('otherTitle')
			width: parent.width
			
			FormLine {
				FormGroup {
					label: qsTr('exitOnCloseLabel')
					
					Switch {
						checked: SettingsModel.exitOnClose
						
						onClicked: SettingsModel.exitOnClose = !checked
					}
				}
				
				FormGroup {
					label: qsTr('autoStartLabel')
					
					Switch {
						checked: App.autoStart
						
						onClicked: App.autoStart = !checked
					}
				}
			}
		}
	}
}
