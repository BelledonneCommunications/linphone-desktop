import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'SettingsSipAccounts.js' as Logic

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		// -------------------------------------------------------------------------
		// Default identity.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('defaultIdentityTitle')
			width: parent.width
			
			FormLine {
				visible: SettingsModel.showLocalSipAccount
				FormGroup {
					label: qsTr('defaultDisplayNameLabel')
					
					TextField {
						text: AccountSettingsModel.primaryDisplayName
						
						onEditingFinished: AccountSettingsModel.primaryDisplayName = text
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.showLocalSipAccount
				FormGroup {
					label: qsTr('defaultUsernameLabel')
					
					TextField {
						text: AccountSettingsModel.primaryUsername
						
						onEditingFinished: AccountSettingsModel.primaryUsername = text
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.showLocalSipAccount
				FormGroup {
					label: qsTr('defaultSipAddressLabel')
					
					TextField {
						readOnly: true
						text: AccountSettingsModel.primarySipAddress
					}
				}
			}
			FormLine {
				FormGroup {
					//: 'Device Name' : Label for setting the device name.
					label: qsTr('defaultDeviceNameLabel')
					
					TextField {
						text: SettingsModel.deviceName
						onEditingFinished: SettingsModel.deviceName = text
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Proxy accounts.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('proxyAccountsTitle')
			width: parent.width
			
			FormTable {
				legendLineWidth: SettingsWindowStyle.sipAccounts.legendLineWidth
				
				titles: ['',
					qsTr('editHeader'),
					qsTr('deleteHeader')
				]
				
				Repeater {
					model: SettingsModel.showLocalSipAccount ? AccountSettingsModel.accounts.slice(1) : AccountSettingsModel.accounts
					
					delegate: FormTableLine {
						title: modelData.sipAddress
						
						FormTableEntry {
							ActionButton {
								isCustom: true
								backgroundRadius: 4
								colorSet: SettingsWindowStyle.buttons.editProxy
								
								onClicked: Logic.editAccount(modelData)
							}
						}
						
						FormTableEntry {
							ActionButton {
								isCustom: true
								backgroundRadius: 4
								colorSet: SettingsWindowStyle.buttons.deleteProxy
								
								onClicked: Logic.deleteAccount(modelData)
							}
						}
					}
				}
			}
			
			FormEmptyLine {}
		}
		
		Row {
			anchors.right: parent.right
			
			spacing: SettingsWindowStyle.sipAccounts.buttonsSpacing
			
			TextButtonB {
				text: qsTr('eraseAllPasswords')
				
				onClicked: Logic.eraseAllPasswords()
			}
			
			TextButtonB {
				text: qsTr('addAccount')
				
				onClicked: Logic.editAccount(null)
			}
		}
		
		// -------------------------------------------------------------------------
		// Assistant.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('assistantTitle')
			
			width: parent.width
			visible: SettingsModel.useWebview() || SettingsModel.developerSettingsEnabled
			FormLine {
				FormGroup {
					//: 'Registration URL' : Label for registration URL.
					label: qsTr('webviewRegistrationUrlLabel')
					
					TextField {
						text: SettingsModel.assistantRegistrationUrl
						
						onEditingFinished: SettingsModel.assistantRegistrationUrl = text
					}
				}
				visible: SettingsModel.useWebview()
			}
			
			FormLine {
				FormGroup {
					//: 'Login URL' : Label for login URL.
					label: qsTr('webviewLoginUrlLabel')
					
					TextField {
						text: SettingsModel.assistantLoginUrl
						
						onEditingFinished: SettingsModel.assistantLoginUrl = text
					}
				}
				visible: SettingsModel.useWebview()
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					label: qsTr('createAppSipAccountEnabledLabel')
					
					Switch {
						checked: SettingsModel.createAppSipAccountEnabled
						
						onClicked: SettingsModel.createAppSipAccountEnabled = !checked
					}
				}
				
				FormGroup {
					label: qsTr('useAppSipAccountEnabledLabel')
					
					Switch {
						checked: SettingsModel.useAppSipAccountEnabled
						
						onClicked: SettingsModel.useAppSipAccountEnabled = !checked
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					label: qsTr('useOtherSipAccountEnabledLabel')
					
					Switch {
						checked: SettingsModel.useOtherSipAccountEnabled
						
						onClicked: SettingsModel.useOtherSipAccountEnabled = !checked
					}
				}
				
				FormGroup {
					label: qsTr('fetchRemoteConfigurationEnabledLabel')
					
					Switch {
						checked: SettingsModel.fetchRemoteConfigurationEnabled
						
						onClicked: SettingsModel.fetchRemoteConfigurationEnabled = !checked
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					label: qsTr('assistantSupportsPhoneNumbersLabel')
					
					Switch {
						checked: SettingsModel.assistantSupportsPhoneNumbers
						
						onClicked: SettingsModel.assistantSupportsPhoneNumbers = !checked
					}
				}
			}
		}
	}
}
