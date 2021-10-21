import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		Form {
			title: qsTr('callsTitle')
			width: parent.width
			
			FormLine {
				visible: !!encryption.encryptions.length
				
				FormGroup {
					label: qsTr('encryptionLabel')
					
					ExclusiveButtons {
						id: encryption
						
						property var encryptions: (function () {
							var encryptions = SettingsModel.supportedMediaEncryptions
							if (encryptions.length) {
								encryptions.unshift([ SettingsModel.MediaEncryptionNone, qsTr('noEncryption') ])
							}
							
							return encryptions
						})()
						
						texts: encryptions.map(function (value) {
							return value[1]
						})
						
						onClicked: SettingsModel.mediaEncryption = encryptions[button][0]
						
						Binding {
							property: 'selectedButton'
							target: encryption
							value: {
								var toFound = SettingsModel.mediaEncryption
								return Number(
											Utils.findIndex(encryption.encryptions, function (value) {
												return toFound === value[0]
											})
											)
							}
						}
					}
				}
				FormGroup {
					label: qsTr('encryptionMandatoryLabel')
					
					Switch {
						id:	encryptionMandatory
						
						checked: SettingsModel.mediaEncryptionMandatory
						
						onClicked: SettingsModel.mediaEncryptionMandatory = !checked
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('autoAnswerLabel')
					
					Switch {
						id: autoAnswer
						
						checked: SettingsModel.autoAnswerStatus
						
						onClicked: SettingsModel.autoAnswerStatus = !checked
					}
				}
				
				FormGroup {
					label: qsTr('autoAnswerDelayLabel')
					
					NumericField {
						readOnly: !autoAnswer.checked
						
						minValue: 0
						maxValue: 30000
						step: 1000
						
						text: SettingsModel.autoAnswerDelay
						
						onEditingFinished: SettingsModel.autoAnswerDelay = text
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('autoAnswerWithVideoLabel')
					visible: SettingsModel.videoSupported
					
					Switch {
						checked: SettingsModel.autoAnswerVideoStatus
						enabled: autoAnswer.checked
						
						onClicked: SettingsModel.autoAnswerVideoStatus = !checked
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('showTelKeypadAutomaticallyLabel')
					
					Switch {
						checked: SettingsModel.showTelKeypadAutomatically
						
						onClicked: SettingsModel.showTelKeypadAutomatically = !checked
					}
				}
				
				FormGroup {
					label: qsTr('keepCallsWindowInBackgroundLabel')
					
					Switch {
						checked: SettingsModel.keepCallsWindowInBackground
						
						onClicked: SettingsModel.keepCallsWindowInBackground = !checked
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('outgoingCallsEnabledLabel')
					
					Switch {
						checked: SettingsModel.outgoingCallsEnabled
						
						onClicked: SettingsModel.outgoingCallsEnabled = !checked
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('callRecorderEnabledLabel')
					
					Switch {
						checked: SettingsModel.callRecorderEnabled
						
						onClicked: SettingsModel.callRecorderEnabled = !checked
					}
				}
				
				FormGroup {
					label: qsTr('callPauseEnabledLabel')
					
					Switch {
						checked: SettingsModel.callPauseEnabled
						
						onClicked: SettingsModel.callPauseEnabled = !checked
					}
				}
			}
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('muteMicrophoneEnabledLabel')
					
					Switch {
						checked: SettingsModel.muteMicrophoneEnabled
						
						onClicked: SettingsModel.muteMicrophoneEnabled = !checked
					}
				}
			}
			
			FormLine {
				FormGroup {
					//: 'Call when registered' : Label on switch to choose if calls are make when the current proxy is registered
					label: qsTr('waitRegistrationForCallLabel')
					
					Switch {
						id: waitRegistrationForCall
						
						checked: SettingsModel.waitRegistrationForCall
						
						onClicked: SettingsModel.waitRegistrationForCall = !checked
					}
				}
				
				FormGroup {
					visible: SettingsModel.callRecorderEnabled || SettingsModel.developerSettingsEnabled
					label: qsTr('automaticallyRecordCallsLabel')
					
					Switch {
						checked: SettingsModel.automaticallyRecordCalls
						
						onClicked: SettingsModel.automaticallyRecordCalls = !checked
					}
				}
				
			}
		}
		
		Form {
			title: qsTr('chatTitle')
			visible: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled || SettingsModel.developerSettingsEnabled
			width: parent.width
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('chatEnabledLabel')
					
					Switch {
						checked: SettingsModel.standardChatEnabled
						
						onClicked: SettingsModel.standardChatEnabled = !checked
					}
				}
				FormGroup {
					label: 'Activate secure chats'
					
					Switch {
						checked: SettingsModel.secureChatEnabled
						
						onClicked: SettingsModel.secureChatEnabled = !checked
					}
				}
								
				FormGroup {
					label: qsTr('conferenceEnabledLabel')
					
					Switch {
						checked: SettingsModel.conferenceEnabled
						
						onClicked: SettingsModel.conferenceEnabled = !checked
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('chatNotificationSoundEnabledLabel')
					
					Switch {
						id: enableChatNotificationSound
						
						checked: SettingsModel.chatNotificationSoundEnabled
						
						onClicked: SettingsModel.chatNotificationSoundEnabled = !checked
					}
				}
				
				FormGroup {
					label: qsTr('chatNotificationSoundLabel')
					
					FileChooserButton {
						readOnly: !enableChatNotificationSound.checked
						selectedFile: SettingsModel.chatNotificationSoundPath
						
						onAccepted: SettingsModel.chatNotificationSoundPath = selectedFile
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('fileServerLabel')
					
					TextField {
						text: SettingsModel.fileTransferUrl
						
						onEditingFinished: SettingsModel.fileTransferUrl = text
					}
				}
			}
			FormLine {
				FormGroup {
					//: 'Hide empty chat rooms' : Label for a switch to choose if Linphone hide empty chat rooms
					label: qsTr('hideEmptyChatRoomsLabel')
					
					Switch {
						id: hideEmptyChatRooms
						
						checked: SettingsModel.hideEmptyChatRooms
						
						onClicked: SettingsModel.hideEmptyChatRooms = !checked
					}
				}
				
			}
			
			FormLine {
				visible: false // Use SettingsModel.limeIsSupported when we want to control lime
				
				FormGroup {
					label: qsTr('encryptWithLimeLabel')
					
					ExclusiveButtons {
						id: lime
						
						property var limeStates: ([
													  [ SettingsModel.LimeStateDisabled, qsTr('limeDisabled') ],
													  [ SettingsModel.LimeStateMandatory, qsTr('limeRequired') ],
													  [ SettingsModel.LimeStatePreferred, qsTr('limePreferred') ]
												  ])
						
						texts: limeStates.map(function (value) {
							return value[1]
						})
						
						onClicked: SettingsModel.limeState = limeStates[button][0]
						
						Binding {
							property: 'selectedButton'
							target: lime
							value: {
								var toFound = SettingsModel.limeState
								return Number(
											Utils.findIndex(lime.limeStates, function (value) {
												return toFound === value[0]
											})
											)
							}
						}
					}
				}
			}
		}
		
		Form {
			title: qsTr('contactsTitle')
			visible: SettingsModel.developerSettingsEnabled
			width: parent.width
			
			FormLine {
				FormGroup {
					label: qsTr('contactsEnabledLabel')
					
					Switch {
						checked: SettingsModel.contactsEnabled
						
						onClicked: SettingsModel.contactsEnabled = !checked
					}
				}
			}
		}
	}
}
