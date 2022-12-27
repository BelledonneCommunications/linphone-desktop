import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

import ContactsImporterPluginsManager 1.0

import 'SettingsAdvanced.js' as Logic

// =============================================================================

TabContainer {
	id: mainItem
	color: "#00000000"
	signal showLogs()
	Column {
		id: column
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		// -------------------------------------------------------------------------
		// Logs.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('logsTitle')
			width: parent.width
			
			FormLine {
				FormGroup {
					label: qsTr('logsFolderLabel')
					
					FileChooserButton {
						selectedFile: SettingsModel.logsFolder
						selectFolder: true
						
						onAccepted: SettingsModel.logsFolder = selectedFile
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('logsUploadUrlLabel')
					
					TextField {
						readOnly: true
						text: SettingsModel.logsUploadUrl
						
						onEditingFinished: SettingsModel.logsUploadUrl = text
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('logsEnabledLabel')
					
					Switch {
						checked: SettingsModel.logsEnabled
						
						onClicked: SettingsModel.logsEnabled = !checked
					}
				}
			}
		}
		Row {
			anchors.right: parent.right
			spacing: SettingsAdvancedStyle.buttons.spacing
			
			TextButtonB {
				text: qsTr('viewlogs')
				
				onClicked: {
					mainItem.showLogs()
				}
			}
			
			TextButtonB {
				text: qsTr('cleanLogs')
				
				onClicked: {
					Logic.cleanLogs()
					sendLogsBlock.setText('')
				}
			}
			
			TextButtonB {
				enabled: !sendLogsBlock.loading && SettingsModel.logsEnabled
				text: qsTr('sendLogs')
				
				onClicked: sendLogsBlock.execute()
			}
		}
		RequestBlock {
			id: sendLogsBlock
			
			action: CoreManager.sendLogs
			width: parent.width
			
			
			Connections {
				target: CoreManager
				
				onLogsUploaded: Logic.handleLogsUploaded(url)
			}
		}
		onVisibleChanged: sendLogsBlock.setText('')
		
		// -------------------------------------------------------------------------
		//								LDAP
		// -------------------------------------------------------------------------
		Form {
			title: 'LDAP'
			width: parent.width
			addButton:true
			onAddButtonClicked:ldapSection.add()
			visible: SettingsModel.isLdapAvailable() || SettingsModel.developerSettingsEnabled
			SettingsLdap{
				id:ldapSection
				width: parent.width
			}
		}
		
		// -------------------------------------------------------------------------
		//							ADDRESS BOOK
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('contactsTitle')
			width: parent.width
			FormTable {
				id:contactsImporterTable
				width :parent.width
				legendLineWidth:0
				disableLineTitle:importerRepeater.count!=1
				titles: (importerRepeater.count==1? getTitles(): [])
				function getTitles(repeaterModel){
					var fields = importerRepeater.itemAt(0).pluginDescription['fields'];
					var t = [''];
					for(var i = 0 ; i < fields.length ; ++i){
						t.push(fields[i]['placeholder']);
					}
					return t;
				}
				Repeater{
					id:importerRepeater
					model:ContactsImporterListProxyModel{id:contactsImporterList}
					
					delegate : FormTable{
						//readonly property double maxItemWidth: contactsImporterTable.maxItemWidth
						property var pluginDescription : importerLine.pluginDescription
						width :parent.width
						legendLineWidth:80
						disableLineTitle:true
						FormTableLine {
							id:importerLine
							property var fields : $modelData.fields
							property int identity : $modelData.identity
							property var pluginDescription : ContactsImporterPluginsManager.getContactsImporterPluginDescription(fields["pluginID"]) // Plugin definition
							
							FormTableEntry {
								Row{
									width :parent.width
									ActionButton {
										id:removeImporter
										isCustom: true
										backgroundRadius: 90
										colorSet: SettingsAdvancedStyle.cancel
										onClicked:ContactsImporterListModel.removeContactsImporter($modelData)
									}
									Text{
										height:parent.height
										width:parent.width-removeImporter.width
										text:importerLine.pluginDescription['pluginTitle']
										horizontalAlignment:Text.AlignHCenter
										verticalAlignment: Text.AlignVCenter
										elide: Text.ElideRight
										wrapMode: Text.WordWrap
										font {
											bold: true
											pointSize: FormTableStyle.entry.text.pointSize
										}
										TooltipArea{
											text:importerLine.pluginDescription['pluginDescription']
										}
									}
								}
							}
							
							Repeater{
								model:importerLine.pluginDescription['fields']
								delegate: FormTableEntry {
									Loader{
										sourceComponent: ($modelData['type']==0 ? textComponent:textFieldComponent)
										active:true
										width:parent.width
										Component{
											id: textComponent
											Text {
												color: FormTableStyle.entry.text.colorModel.color
												elide: Text.ElideRight
												horizontalAlignment: Text.AlignHCenter
												text: importerLine.fields[$modelData['fieldId']]?importerLine.fields[$modelData['fieldId']]:''
												height: FormTableStyle.entry.height
												width: parent.width
												font {
													bold: true
													pointSize: FormTableStyle.entry.text.pointSize
												}
											}
										}
										Component{
											id: textFieldComponent
											TextField {
												readOnly: false
												width:parent.width
												placeholderText : $modelData['placeholder']
												text: importerLine.fields[$modelData['fieldId']]?importerLine.fields[$modelData['fieldId']]:''
												echoMode: ($modelData['hiddenText']?TextInput.Password:TextInput.Normal)
												onEditingFinished:{
													importerLine.fields[$modelData['fieldId']] = text
												}
												Component.onCompleted: importerLine.fields[$modelData['fieldId']] = text
											}
										}
									}
								}
							}// Repeater : Fields
							FormTableEntry {
								Switch {
									checked: $modelData.fields["enabled"]>0
									onClicked: {
										checked = !checked
										importerLine.fields["enabled"] = (checked?1:0)
										ContactsImporterListModel.addContactsImporter(importerLine.fields, importerLine.identity)
										
										if(checked){
											ContactsImporterListModel.importContacts(importerLine.identity)
										}else
											contactsImporterStatus.text = ''
									}
								}
							}//FormTableEntry
						}//FormTableLine
						FormTableLine{
							width:parent.width-parent.legendLineWidth
							FormTableEntry {
								id:contactsImporterStatusEntry
								visible:contactsImporterStatus.text!==''
								width:parent.width
								TextEdit{
									id:contactsImporterStatus
									property bool isError:false
									selectByMouse: true
									readOnly:true
									color: (isError?SettingsAdvancedStyle.error.colorModel.color : SettingsAdvancedStyle.info.colorModel.color)
									width:parent.width
									horizontalAlignment:Text.AlignRight
									font {
										italic: true
										pointSize: SettingsAdvancedStyle.info.pointSize
									}
									Connections{
										target:$modelData
										onStatusMessage:{contactsImporterStatus.isError=false;contactsImporterStatus.text=message;}
										onErrorMessage:{contactsImporterStatus.isError=true;contactsImporterStatus.text=message;}
									}
								}
							}
						}
					}//Column
				}// Repeater : Importer
				
			}
			Row{
				spacing:SettingsAdvancedStyle.buttons.spacing
				anchors.horizontalCenter: parent.horizontalCenter
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: SettingsAdvancedStyle.options
					onClicked:{
						ContactsImporterPluginsManager.openNewPlugin();
						pluginChoice.model = ContactsImporterPluginsManager.getPlugins();
					}
				}
				ComboBox{
					id: pluginChoice
					model:ContactsImporterPluginsManager.getPlugins()
					textRole: "pluginTitle"
					//: 'No Plugins to load' : Text in combobox
					displayText: currentIndex === -1 ? qsTr('noPlugin') : currentText
					Text{// Hack, combobox show empty text when empty
						anchors.fill:parent
						visible:pluginChoice.currentIndex===-1
						verticalAlignment: Qt.AlignVCenter
						horizontalAlignment: Qt.AlignHCenter
						text: qsTr('noPlugin')
						font {
							bold:false
							italic: true
							pointSize: FormTableStyle.entry.text.pointSize
						}
					}
					Connections{
						target:SettingsModel
						onContactImporterChanged:pluginChoice.model=ContactsImporterPluginsManager.getPlugins()
					}
				}
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: SettingsAdvancedStyle.add
					visible:pluginChoice.currentIndex>=0
					onClicked:{
						if( pluginChoice.currentIndex >= 0)
							ContactsImporterListModel.createContactsImporter({"pluginID":pluginChoice.model[pluginChoice.currentIndex]["pluginID"]})
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		//								VFS
		// -------------------------------------------------------------------------
		
		Form {
		//: 'VFS'
			title: qsTr('vfsTitle')
			width: parent.width
			
			FormLine {
				FormGroup {
				//: 'Encrypt all the application' : Label to encrypt application
					label: qsTr('vfsEncryption')
					
					Switch {
						checked: SettingsModel.isVfsEncrypted
						
						onClicked: {
								window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
													descriptionText: (checked
													//: 'Are you sure to deactivate the encryption? The application will exit and all your data will be lost. You must delete them before using the application.' : Explanation to deactivate the VFS encryption.
																			? qsTr('vfsDeactivation')
													//: 'Are you sure to activate the encryption? You cannot revert without deleting ALL your data' : Explanation to activate the VFS encryption.
																			: qsTr('vfsActivation'))
													, buttonTexts : (checked
																			?[qsTr('cancel'), 
																			//: 'Delete data' : Action to delete all data.
																				qsTr('deleteData')]
																			: [qsTr('cancel'), qsTr('confirm')])
													, height:320
												}, function (status) {
													if(status > 0){
														if (status == 1 && checked){// Test on 1 in case if we want more options (aka more buttons)
															window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
															//: 'The application will delete your application data files. Do you confirm ?'
																descriptionText: qsTr('vfsDeletion')
																, height: 320
															}, function (deleteStatus) {
															if( deleteStatus)
																SettingsModel.setVfsEncrypted(!checked, true)
															})
														}else
															SettingsModel.setVfsEncrypted(!checked, false)
													}
												})
						}
					}
				}
			}
		}
		// -------------------------------------------------------------------------
		// Developer settings.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('developerSettingsTitle')
			visible: SettingsModel.isDeveloperSettingsAvailable()
			width: parent.width
			
			FormLine {
				FormGroup {
					label: qsTr('developerSettingsEnabledLabel')
					
					Switch {
						checked: SettingsModel.developerSettingsEnabled
						
						onClicked: SettingsModel.developerSettingsEnabled = !checked
					}
				}
			}
		}
	}
}

/*##^##
Designer {
	D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
