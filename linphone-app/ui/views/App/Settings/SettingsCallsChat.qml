import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
import Common.Styles 1.0

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		Form {
			title: qsTr('callsTitle')
			width: parent.width
			
			FormLine {
				visible: !!encryption.model.length
				
				FormGroup {
					label: qsTr('encryptionLabel')
					
					ComboBox {
						id: encryption
						textRole: 'key'
						
						model: (function () {
							var encryptions = SettingsModel.supportedMediaEncryptions
							if (encryptions.length) {
								encryptions.unshift({value:SettingsModel.MediaEncryptionNone, key:qsTr('noEncryption')})
							}
							
							return encryptions
						})()
						property var currentEncryption: SettingsModel.mediaEncryption
						onCurrentEncryptionChanged: {
							currentIndex = Number(
										Utils.findIndex(encryption.model, function (value) {
											return currentEncryption === value.value
										})
							)
						}
						onActivated: SettingsModel.mediaEncryption = model[index].value
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
					//: 'Enable notifications': settings label for enabling notifications.
					label: qsTr('chatNotificationsEnabledLabel')
					
					Switch {
						id: enableChatNotifications
						
						checked: SettingsModel.chatNotificationsEnabled
						
						onClicked: SettingsModel.chatNotificationsEnabled = !checked
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
				FormGroup {
					//: 'Auto download' : Label for a slider about auto download mode
					label: qsTr('AutoDownload')
					
					RowLayout{
						Layout.fillHeight: true
						Layout.fillWidth: true
						spacing: 0
						Slider {
							Layout.fillHeight: true
							Layout.fillWidth: true
							id: autoDownloadModes
							width: parent.width
							
							function toSlider(value){
								if( value == -1)
									return autoDownloadModes.from;
								else if(value == 0)
									return autoDownloadModes.to;
								else
									return value/1000000+autoDownloadModes.from
							}
							function fromSlider(value){
								if( value == autoDownloadModes.from)
									return -1
								else if( value == autoDownloadModes.to)
									return 0
								else
									return (value - autoDownloadModes.from) * 1000000
							}
							
							onValueChanged: {
												SettingsModel.autoDownloadMaxSize = fromSlider(value)
												autoDownloadText.updateText(value)
											}
							from: 1
							to: 500
							stepSize: 1
							value: toSlider(SettingsModel.autoDownloadMaxSize)
						}
						Text {
							id: autoDownloadText
							property int preferredWidth : 0
							Layout.preferredWidth: preferredWidth
							color: FormHGroupStyle.legend.color
							font.pointSize: FormHGroupStyle.legend.pointSize
							
							function updateText(value){
								//: 'Never' : auto download mode description for deactivated feature.
								text = value == autoDownloadModes.from ? qsTr('autoDownloadNever')
								//: 'Always' : auto download mode description for activated feature without any constraints.
									: value == autoDownloadModes.to ? qsTr('autoDownloadAlways')
										: ' <  '+ ( autoDownloadModes.fromSlider(value) ).toFixed(0)/1000000 + ' Mb'
							}
							Component.onCompleted: updateMaxSize()
							function updateMaxSize(){
								autoDownloadText.visible = false
								updateText(autoDownloadModes.from)
								var maxWidth = autoDownloadText.implicitWidth
								updateText(autoDownloadModes.to)
								maxWidth = Math.max( maxWidth, autoDownloadText.implicitWidth)
								updateText(autoDownloadModes.to-1)
								maxWidth = Math.max( maxWidth, autoDownloadText.implicitWidth)
								autoDownloadText.preferredWidth = maxWidth
								updateText(autoDownloadModes.value)
								autoDownloadText.visible = true
							}
						}
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
