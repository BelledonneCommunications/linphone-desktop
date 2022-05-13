import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0
import UtilsCpp 1.0
import ColorsList 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils
// =============================================================================

DialogPlus {
	id: conferenceManager
	property bool isNew: !conferenceInfoModel || conferenceInfoModel.uri === ''
	property ConferenceInfoModel conferenceInfoModel: ConferenceInfoModel{}
	onConferenceInfoModelChanged: selectedParticipants.setAddresses(conferenceInfoModel)
	Connections{
		target: conferenceInfoModel
		onConferenceCreated: {
			creationStatus.icon = 'led_green'
		}
		onConferenceCreationFailed:{ creationStatus.icon = 'led_red' }
		onInvitationsSent: {
						exit(1)
					}
	}
	
	readonly property int minParticipants: 1
	
	buttons: [
		ColumnLayout{
			Layout.fillWidth: true
			Layout.topMargin:15
			Layout.alignment: Qt.AlignLeft
			Layout.leftMargin: 15
			spacing:4
			visible: false	// TODO
			Text {
				Layout.fillWidth: true
				//: 'Would you like to encrypt your conference?' : Ask about setting the conference as secured.
				text:qsTr('askEncryption')
				color: NewConferenceStyle.askEncryptionColor
				font.pointSize: NewConferenceStyle.titles.pointSize
				font.weight: Font.DemiBold
			}
			Item{
				Layout.fillWidth: true
				Layout.preferredHeight: 50
				Icon{
					id:secureOff
					anchors.left:parent.left
					anchors.leftMargin : 0
					anchors.verticalCenter: parent.verticalCenter
					width:20
					height:20
					icon: 'secure_off'
					iconSize:20
				}
				Switch{
					id:secureSwitch
					anchors.left:secureOff.right
					anchors.leftMargin : 5
					anchors.verticalCenter: parent.verticalCenter
					width:50
					enabled:true
					checked: !SettingsModel.standardChatEnabled && SettingsModel.secureChatEnabled 
					
					onClicked: {
						var newCheck = checked
						if(SettingsModel.standardChatEnabled && checked || SettingsModel.secureChatEnabled && !checked)
							newCheck = !checked;
						
						checked = newCheck;
					}
					indicatorStyle: SwitchStyle.aux
				}
				Icon{
					id:secureOn
					anchors.left:secureSwitch.right
					anchors.leftMargin : 15
					anchors.verticalCenter: parent.verticalCenter
					width:20
					height:20
					icon: 'secure_on'
					iconSize:20
				}
			}
		},
		TextButtonA {
			//: 'Cancel' : Cancel button
			text: qsTr('cancelButton')
			capitalization: Font.AllUppercase
			
			onClicked: exit(0)
		},
		TextButtonB {
			enabled: selectedParticipants.count >= conferenceManager.minParticipants && subject.text != '' && AccountSettingsModel.conferenceURI != ''
			//: 'Launch' : Launch button
			text: conferenceManager.isNew ? qsTr('launchButton') 
			//: 'Update' : Update button
				: qsTr('updateButton')
			capitalization: Font.AllUppercase
			
			function getInviteMode(){
				return 0;
			}
			
			onClicked: {
				creationStatus.icon = 'led_orange'
				conferenceInfoModel.isScheduled = scheduledSwitch.checked
				if( scheduledSwitch.checked){
					var startDateTime = Utils.buildDate(dateField.getDate(), timeField.getTime())
					startDateTime.setSeconds(0)
					conferenceInfoModel.timeZoneModel = timeZoneField.model.getAt(timeZoneField.currentIndex)
					conferenceInfoModel.dateTime = startDateTime
					conferenceInfoModel.duration = durationField.text
				}
				conferenceInfoModel.subject = subject.text
				conferenceInfoModel.description = description.text
				
				
				conferenceInfoModel.setParticipants(selectedParticipants.participantListModel)
				conferenceInfoModel.createConference(false && secureSwitch.checked, getInviteMode())	// TODO remove false when Encryption is ready to use
			}
			TooltipArea{
				visible: AccountSettingsModel.conferenceURI == '' || subject.text == '' || selectedParticipants.count < conferenceManager.minParticipants
				maxWidth: participantView.width
				delay:0
				text: {
					var txt = '\n';
					if( subject.text == '')
						//: 'You need to fill a subject.' : Tooltip to warn a user on missing field.
						txt ='- ' + qsTr('missingSubject') + '\n'
					if( selectedParticipants.count < conferenceManager.minParticipants)
						//: 'You need at least %1 participant.' : Tooltip to warn a user that there are not enough participants for the chat creation.
						txt += '- ' + qsTr('missingParticipants', '', conferenceManager.minParticipants).arg(conferenceManager.minParticipants) + '\n'
					if( AccountSettingsModel.conferenceURI == '')
						//: 'You need to set the conference URI in your account settings to create a conference based chat room.' : Tooltip to warn the user that a setting is missong in its configuration.
						txt += '- ' + qsTr('missingConferenceURI') + '\n'
					return txt;
				}
			}
		}
		, Icon{
			id: creationStatus
			height: 10
			width: 10
			visible: icon != ''
			icon: ''
		}
	]
	
	buttonsAlignment: Qt.AlignRight
	buttonsLeftMargin: 15
	//: 'Start a video conference' : Title of a popup about creation of a video conference
	title: conferenceManager.isNew ? qsTr('newConferenceTitle') 
	//: 'Update the conference' : Title of a popup about updating configuration of a video conference.
		: qsTr('updateConferenceTitle')
	
	height: window.height - 100
	width: window.width - 100
	expandHeight: true
	
	// ---------------------------------------------------------------------------
	RowLayout {
		height: parent.height
		width: parent.width
		spacing: 0
		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.topMargin: 10
			spacing: 10
			
			ColumnLayout {
				Layout.fillWidth: true
				Layout.rightMargin: 15
				spacing:5
				
				Text{
					textFormat: Text.RichText
					//: 'Subject' : Label of a text field about the subject of the chat room
					text :qsTr('subjectLabel') +'<span style="color:red">*</span>'
					color: NewConferenceStyle.titles.textColor
					font.pointSize: NewConferenceStyle.titles.pointSize
					font.weight: NewConferenceStyle.titles.weight
				}
				TextField {
					id:subject
					Layout.fillWidth: true
					//: 'Give a subject' : Placeholder in a form about setting a subject
					placeholderText : qsTr('subjectPlaceholder')
					text: conferenceInfoModel && conferenceInfoModel.subject || ''
					Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
					TooltipArea{
						//: 'Current subject of the Chat Room. It cannot be empty'
						//~ Tooltip Explanation about the subject of the chat room
						text : qsTr('subjectTooltip')
					}
				}
			}
			Rectangle{
				Layout.fillWidth: true
				Layout.preferredHeight: scheduledSwitch.checked ? 120 : 50
				Layout.rightMargin: 15
				color: '#F7F7F7'
				ColumnLayout{
					anchors.fill: parent
					spacing: 0
					RowLayout{
						Layout.fillWidth: true
						Layout.preferredHeight: 50
						Switch{
							id:scheduledSwitch
							Layout.leftMargin : 5
							Layout.alignment: Qt.AlignVCenter
							width:50
							enabled: true
							checked: conferenceInfoModel.isScheduled
							
							onClicked: {
								checked = !checked
							}
							indicatorStyle: SwitchStyle.aux
						}
						Text {
							Layout.fillWidth: true
							Layout.rightMargin: 15
							//: 'Would you like to schedule your conference?' : Ask about setting the conference as scheduled.
							text: qsTr('newConferenceScheduleTitle')
							color: NewConferenceStyle.titles.textColor
							font.pointSize: NewConferenceStyle.titles.pointSize
							font.weight: NewConferenceStyle.titles.weight
							wrapMode: Text.WordWrap
						}
					}
					GridLayout{
						id: scheduleForm
						visible: scheduledSwitch.checked
						Layout.fillWidth: true
						Layout.fillHeight: true
						columns: 4
						property var locale: Qt.locale()
						property date currentDate: new Date()
						property int cellWidth: (parent.width-15)/columns
						
						//: 'Date' : Date lebel.
						Text{textFormat: Text.RichText; text: qsTr('newConferenceDate')+'<span style="color:red">*</span>'; Layout.preferredWidth: parent.cellWidth; wrapMode: Text.WordWrap; color: NewConferenceStyle.titles.textColor; font.weight: NewConferenceStyle.titles.weight; font.pointSize: NewConferenceStyle.titles.pointSize }
						//: 'Time' : Time label.
						Text{textFormat: Text.RichText; text: qsTr('newConferenceTimeTitle')+'<span style="color:red">*</span>'; Layout.preferredWidth: parent.cellWidth; wrapMode: Text.WordWrap; color: NewConferenceStyle.titles.textColor; font.weight: NewConferenceStyle.titles.weight; font.pointSize: NewConferenceStyle.titles.pointSize }
						//: 'Duration' : Duration label.
						Text{textFormat: Text.RichText; text: qsTr('newConferenceDurationTitle'); Layout.preferredWidth: parent.cellWidth; wrapMode: Text.WordWrap; color: NewConferenceStyle.titles.textColor; font.weight: NewConferenceStyle.titles.weight; font.pointSize: NewConferenceStyle.titles.pointSize }
						//: 'Timezone' : Timezone label.
						Text{textFormat: Text.RichText; text: qsTr('newConferenceTimezoneTitle'); Layout.preferredWidth: parent.cellWidth; wrapMode: Text.WordWrap; color: NewConferenceStyle.titles.textColor; font.weight: NewConferenceStyle.titles.weight; font.pointSize: NewConferenceStyle.titles.pointSize }
						TextField{id: dateField; Layout.preferredWidth: parent.cellWidth
							color: NewConferenceStyle.fields.textColor; font.weight: NewConferenceStyle.fields.weight; font.pointSize: NewConferenceStyle.fields.pointSize
							function getDate(){
								return Date.fromLocaleDateString(scheduleForm.locale, text,'yyyy/MM/dd')
							}
							function setDate(date){
								text = date.toLocaleDateString(scheduleForm.locale, 'yyyy/MM/dd')
							}
							text: conferenceManager.conferenceInfoModel? conferenceManager.conferenceInfoModel.dateTime.toLocaleDateString(scheduleForm.locale, 'yyyy/MM/dd') : ''
							MouseArea{
								anchors.fill: parent
								onClicked: {
									if( rightStackView.currentItemType === 1) {
										rightStackView.currentItemType = 0
										rightStackView.pop()// Cancel
									}else {
										if( rightStackView.depth > 1 )
											rightStackView.pop()//Remove previous request
										rightStackView.currentItemType = 1
										rightStackView.push(datePicker, {selectedDate: new Date(dateField.getDate())})	
									}
								}
							}
						} 
						TextField{id: timeField; Layout.preferredWidth: parent.cellWidth
							color: NewConferenceStyle.fields.textColor; font.weight: NewConferenceStyle.fields.weight; font.pointSize: NewConferenceStyle.fields.pointSize
							function getTime(){
								return Date.fromLocaleTimeString(scheduleForm.locale, timeField.text, 'hh:mm')
							}
							function setTime(date){
								text = date.toLocaleTimeString(scheduleForm.locale, 'hh:mm')
							}
							text: conferenceManager.conferenceInfoModel? conferenceManager.conferenceInfoModel.dateTime.toLocaleTimeString(scheduleForm.locale, 'hh:mm') : ''
							MouseArea{
								anchors.top: parent.top
								anchors.bottom: parent.bottom
								anchors.right: parent.right
								width: parent.width-50
								onClicked: {
									if( rightStackView.currentItemType === 2) {
										rightStackView.currentItemType = 0
										rightStackView.pop()// Cancel
									}else {
										if( rightStackView.depth > 1 )
											rightStackView.pop()//Remove previous request
										rightStackView.currentItemType = 2
										rightStackView.push(timePicker,{selectedTime: new Date(timeField.getTime())})
									}
								}
							}
						}
						NumericField{id: durationField; Layout.preferredWidth: parent.cellWidth; color: NewConferenceStyle.fields.textColor; font.weight: NewConferenceStyle.fields.weight; font.pointSize: NewConferenceStyle.fields.pointSize
							text: conferenceManager.conferenceInfoModel ? conferenceManager.conferenceInfoModel.duration : '1200'
						}
						ComboBox{
							id: timeZoneField
							Layout.preferredWidth: parent.cellWidth;
							currentIndex: conferenceManager.conferenceInfoModel ? model.getIndex(conferenceManager.conferenceInfoModel.timeZoneModel) : -1
							model: TimeZoneProxyModel{}
							textRole: "displayText"
							selectionWidth: 500
							rootItem: conferenceManager
						}
						
						function updateDateTime(){
								var storedDate
								if( dateField.text != '' && timeField.text != ''){
									storedDate = Utils.buildDate(dateField.getDate(), timeField.getTime() )
								}else
									storedDate = new Date()
								var currentDate = new Date()
								if(currentDate >= storedDate){
									var nextStoredDate = UtilsCpp.addMinutes(new Date(), 1)
									dateField.setDate(nextStoredDate)
									timeField.setTime(nextStoredDate)
								}
						}
						Timer{
							running: scheduleForm.visible && conferenceManager.isNew
							repeat: true
							interval: 1000
							triggeredOnStart: true
							onTriggered: {
								if(conferenceManager.isNew)
									scheduleForm.updateDateTime()
							}
						}
					}
				}
			}
			ColumnLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.rightMargin: 15
				spacing:5
				Text{
					Layout.fillWidth: true
					Layout.preferredHeight: 20
					textFormat: Text.RichText
					//: 'Add a description' : Label of a text field about the description of the conference
					text : qsTr('newConferenceDescriptionTitle')
					color: NewConferenceStyle.titles.textColor
					font.pointSize: NewConferenceStyle.titles.pointSize
					font.weight: NewConferenceStyle.titles.weight
				}
				TextAreaField {
					id: description
					Layout.fillWidth: true
					Layout.fillHeight: true
					//: 'Description' : Placeholder in a form about setting a description
					placeholderText : qsTr('newConferenceDescriptionPlaceholder')
					text: conferenceManager.conferenceInfoModel ? conferenceManager.conferenceInfoModel.description : ''
					Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
					TooltipArea{
						//: 'This description will describe the conference' : Explanation about the description of the conference
						text : qsTr('newConferenceDescriptionTooltip')
					}
				}
			}
			ColumnLayout{
				Layout.fillWidth: true
				spacing: 5
				CheckBoxText {
					id: inviteAppAccountCheckBox
					//: 'Send invite via Linphone' : Label for checkbox for sending invitations with Linphone.
					text: qsTr('newConferenceSendLinphoneInviteLabel')
					width: parent.width
					checked: true
				}
				CheckBoxText {
					id: inviteEmailCheckBox
					visible: false	// TODO
					//: 'Send invite via Email' : Label for checkbox for sending invitations with mailer.
					text: qsTr('newConferenceSendEmailInviteLabel')
					width: parent.width
				}
			}
		}
		
		StackView{
			id: rightStackView
			
			property int currentItemType: 0
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.minimumWidth: 200
			Layout.topMargin: 10
			Layout.bottomMargin: 10
			
			clip: true
		// -------------------------------------------------------------------------
		// See and remove selected addresses.
		// -------------------------------------------------------------------------
			initialItem: ColumnLayout{
				Rectangle{
					Layout.fillHeight: true
					Layout.fillWidth: true
					border.width: 1
					border.color: NewConferenceStyle.addressesBorderColor
					
					ColumnLayout {
						anchors.fill: parent
						anchors.topMargin: 15
						anchors.leftMargin: 10
						anchors.rightMargin: 10
						spacing: 0
						
						SmartSearchBar {
							id: smartSearchBar
							
							Layout.fillWidth: true
							Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
							
							showHeader:false
							
							maxMenuHeight: MainWindowStyle.searchBox.maxHeight
							//: 'Select participants' : Placeholder for a search on participant to add them in selection.
							placeholderText: qsTr('participantSelectionPlaceholder')
							//: 'Search in your contacts or add a custom one to the chat room.'
							tooltipText: qsTr('participantSelectionTooltip')
							
							actions:[{
									colorSet: NewConferenceStyle.addParticipant,
									secure: secureSwitch.checked,
									visible: true,
									secureIconVisibleHandler : function(entry) {
										return UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh)
									},
									handler: function (entry) {
										selectedParticipants.addAddress(entry.sipAddress)
										smartSearchBar.addAddressToIgnore(entry.sipAddress);
									},
								}]
							
							onEntryClicked: {
								selectedParticipants.addAddress(entry.sipAddress)
								smartSearchBar.addAddressToIgnore(entry.sipAddress);
							}
						}
						Text{
							Layout.preferredHeight: 20
							Layout.rightMargin: 65
							Layout.alignment: Qt.AlignRight | Qt.AlignBottom
							Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
							//: 'Admin' : Admin(istrator)
							//~ one word for admin status
							text : qsTr('adminStatus')
							
							color: NewConferenceStyle.addressesAdminColor
							font.pointSize: Units.dp * 11
							font.weight: Font.Light
							visible: participantView.count > 0
							
						}
						ScrollableListViewField {
							Layout.fillHeight: true
							Layout.fillWidth: true
							Layout.bottomMargin: 5
							
							textFieldStyle: TextFieldStyle.unbordered
							
							ParticipantsView {
								id: participantView
								anchors.fill: parent
								
								showContactAddress:false
								showSwitch : conferenceManager.isNew
								showSeparator: false
								isSelectable: false
								showInvitingIndicator: false
								function removeParticipant(entry){
									smartSearchBar.removeAddressToIgnore(entry.sipAddress)
									selectedParticipants.removeModel(entry)
									++lastContacts.reloadCount
								}
								
								
								actions: [{
										colorSet: NewConferenceStyle.removeParticipant,
										secure:0,
										visible:true,
										//: 'Remove this participant from the selection' : Explanation about removing participant from a selection
										//~ Tooltip This is a tooltip
										tooltipText: qsTr('removeParticipantSelection'),
										handler: function (entry) {
											removeParticipant(entry)
										}
									}]
								
								genSipAddress: ''
								
								model: ParticipantProxyModel {
									id:selectedParticipants
									chatRoomModel:null
								}
								onEntryClicked: actions[0].handler(entry)
							}
						}
					}
				}
				Item{
					Layout.fillWidth: true
					Layout.preferredHeight: 20
					Text{
						anchors.fill:parent
						textFormat: Text.RichText
						//: 'Required' : Word relative to a star to explain that it is a requirement (Field form)
						text : '<span style="color:red">*</span> '+qsTr('requiredField')
						color: NewConferenceStyle.requiredColor
						font.pointSize: Units.dp * 8
					}
				}
			}
//----------------------------------------------------
//			STACKVIEWS
//----------------------------------------------------
			Component{
				id: datePicker
				DatePicker{
					onClicked: {
						dateField.setDate(date)
						rightStackView.currentItemType = 0
						rightStackView.pop()
					}
				}
			}

			Component{
				id: timePicker
				TimePicker{
					onClicked: {
						timeField.setTime(date)
						rightStackView.currentItemType = 0
						rightStackView.pop()
					}
				}
			}
		}
	}
}
