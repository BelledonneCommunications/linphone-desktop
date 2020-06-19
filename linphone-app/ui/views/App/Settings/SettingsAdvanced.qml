import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0
import Linphone.Styles 1.0

import 'SettingsAdvanced.js' as Logic

// =============================================================================

TabContainer {
  Column {
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
    // ADDRESS BOOK
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('contactsTitle')
      width: parent.width
      FormTable {
        width :parent.width
        titles: [
          qsTr('contactsDomain'),
          qsTr('contactsURL'),
          qsTr('contactsUsername'),
          qsTr('contactsActivate')
        ]
        legendLineWidth:80
        FormTableLine {
          id:enswitchLine
          title: 'Enswitch'
          property var enswitchAccount : SettingsModel.contactImportEnswitch
          
          FormTableEntry {
            TextField {
              readOnly: false
              width:parent.width
              text: enswitchLine.enswitchAccount.domain 
              onEditingFinished: {  enswitchLine.enswitchAccount.domain = text
                                    SettingsModel.contactImportEnswitch = enswitchLine.enswitchAccount
                                }
            }
          }
          FormTableEntry {
            TextField {
              readOnly: false
              width:parent.width
              text: enswitchLine.enswitchAccount.url 
              onEditingFinished: {  enswitchLine.enswitchAccount.url = text
                                    SettingsModel.contactImportEnswitch = enswitchLine.enswitchAccount
                                }
            }
          }
          FormTableEntry {
            TextField {
              readOnly: false
              width:parent.width
              text: enswitchLine.enswitchAccount.username
              onEditingFinished:{   enswitchLine.enswitchAccount.username = text
                                    SettingsModel.contactImportEnswitch = enswitchLine.enswitchAccount
                                }
            }
          }
          FormTableEntry {
            Switch {
              id: enswitch
              checked: enswitchLine.enswitchAccount.enabled>0
              onClicked: {  checked = !checked
                            enswitchLine.enswitchAccount.enabled = checked
                            SettingsModel.contactImportEnswitch = enswitchLine.enswitchAccount
                            if(checked)
                                SettingsModel.importContacts()
                            else
                                enswitchStatus.text = ''
                        }
            }
          }
        }
        FormTableLine {
            width:parent.width-parent.legendLineWidth
            FormTableEntry {
                width:parent.width
                TextEdit{
                    id:enswitchStatus
                    visible:text!==''
                    selectByMouse: true
                    readOnly:true
                    color: RequestBlockStyle.error.color
                    width:parent.width
                    horizontalAlignment:Text.AlignRight
                    font {
                      italic: true
                      pointSize: RequestBlockStyle.error.pointSize
                    }

                    Connections{
                        target:SettingsModel
                        onContactImportEnswitchStatus:enswitchStatus.text=status
                    }
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
