import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0

import App.Styles 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

import ContactsImporterPluginsManager 1.0

import 'SettingsAdvanced.js' as Logic

// =============================================================================

TabContainer {
	color: "#00000000"
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
                text: qsTr('cleanLogs')
                
                onClicked: Logic.cleanLogs()
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
                            property var fields : modelData.fields
                            property int identity : modelData.identity
                            property var pluginDescription : ContactsImporterPluginsManager.getContactsImporterPluginDescription(fields["pluginID"]) // Plugin definition
                            
                            FormTableEntry {
                                Row{
                                    width :parent.width
                                    ActionButton {
                                        id:removeImporter
                                        icon: 'cancel'
                                        iconSize:CallsStyle.entry.iconActionSize
                                        onClicked:ContactsImporterListModel.removeContactsImporter(modelData)
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
                                        sourceComponent: (modelData['type']==0 ? textComponent:textFieldComponent)
                                        active:true
                                        width:parent.width
                                        Component{
                                            id: textComponent
                                            Text {
                                                color: FormTableStyle.entry.text.color
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter
                                                text: importerLine.fields[modelData['fieldId']]?importerLine.fields[modelData['fieldId']]:''
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
                                                placeholderText : modelData['placeholder']
                                                text: importerLine.fields[modelData['fieldId']]?importerLine.fields[modelData['fieldId']]:''
                                                echoMode: (modelData['hiddenText']?TextInput.Password:TextInput.Normal)
                                                onEditingFinished:{
                                                    importerLine.fields[modelData['fieldId']] = text
                                                }
                                                Component.onCompleted: importerLine.fields[modelData['fieldId']] = text
                                            }
                                        }
                                    }
                                }
                            }// Repeater : Fields
                            FormTableEntry {
                                Switch {
                                    checked: modelData.fields["enabled"]>0
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
                                    color: (isError?SettingsAdvancedStyle.error.color:SettingsAdvancedStyle.info.color)
                                    width:parent.width
                                    horizontalAlignment:Text.AlignRight
                                    font {
                                        italic: true
                                        pointSize: SettingsAdvancedStyle.info.pointSize
                                    }
                                    Connections{
                                        target:modelData
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
                    icon: 'options'
                    iconSize:CallsStyle.entry.iconActionSize
                    onClicked:{
                        ContactsImporterPluginsManager.openNewPlugin();
                        pluginChoice.model = ContactsImporterPluginsManager.getPlugins();
                    }
                }
                ComboBox{
                    id: pluginChoice
                    model:ContactsImporterPluginsManager.getPlugins()
                    textRole: "pluginTitle"
                    displayText: currentIndex === -1 ? 'No Plugins to load' : currentText
                    Text{// Hack, combobox show empty text when empty
                        anchors.fill:parent
                        visible:pluginChoice.currentIndex===-1
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: 'No Plugins to load'
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
                    icon: 'add'
                    iconSize:CallsStyle.entry.iconActionSize
                    visible:pluginChoice.currentIndex>=0
                    onClicked:{
                        if( pluginChoice.currentIndex >= 0)
                            ContactsImporterListModel.createContactsImporter({"pluginID":pluginChoice.model[pluginChoice.currentIndex]["pluginID"]})
                    }
                }
            }
        }

        // -------------------------------------------------------------------------
        // Developer settings.
        // -------------------------------------------------------------------------

        Form {
            title: qsTr('developerSettingsTitle')
            visible: SettingsModel.developerSettingsEnabled
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
