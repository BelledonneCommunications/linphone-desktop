import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0


// =============================================================================

DialogPlus {
	id:dialog
	buttons: [
		TextButtonA {
			//: 'CANCEL' : button text for cancelling operation
			text: qsTr('cancelButton')
			capitalization: Font.AllUppercase
			onClicked:{
				exit(0)
			}
		},
		TextButtonB {
			//: 'CALL' : Button that lead to a call
			text: (addressToCall != '' ? qsTr('callButton') 
				//: 'OK' : Button that validate the popup to be redirected to the device list
				: qsTr('okButton')
			)
			textButtonStyle: InfoEncryptionStyle.okButton
			onClicked: {
				dialog.ok()
			}
		}
	]
	//: 'End-to-end encrypted' Popup title about encryption information.
	title: qsTr('infoEncryptionTitle')
	showCloseCross:false
	
	property int securityLevel
	property string addressToCall
	
	buttonsAlignment: Qt.AlignCenter
	
	height: InfoEncryptionStyle.height
	width: InfoEncryptionStyle.width
	
	function ok(){
		if(addressToCall != ''){
			CallsListModel.launchSecureAudioCall(addressToCall, LinphoneEnums.MediaEncryptionZrtp)
		}
		exit(1)
	}
	
	// ---------------------------------------------------------------------------
	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: InfoEncryptionStyle.mainLayout.topMargin
		anchors.leftMargin: InfoEncryptionStyle.mainLayout.leftMargin
		anchors.rightMargin: InfoEncryptionStyle.mainLayout.rightMargin
		spacing: InfoEncryptionStyle.mainLayout.spacing
		
		Layout.alignment: Qt.AlignCenter
		
		Icon{
			icon: dialog.securityLevel === 2?'secure_level_1': dialog.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'
			iconSize: InfoEncryptionStyle.securityIcon.iconSize
			Layout.preferredHeight: InfoEncryptionStyle.securityIcon.preferredHeight
			Layout.preferredWidth: InfoEncryptionStyle.securityIcon.preferredWidth
			Layout.alignment: Qt.AlignCenter
		}
		Text{
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: InfoEncryptionStyle.descriptionText.leftMargin
			Layout.rightMargin: InfoEncryptionStyle.descriptionText.rightMargin
			
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: InfoEncryptionStyle.descriptionText.pointSize
			color: InfoEncryptionStyle.descriptionText.colorModel.color
			
			wrapMode: Text.Wrap
			//: "Instant messages are end-to-end encrypted in secured conversations. It is possible to upgrade the security level of a conversation by authentificating participants."
			//~ Context Explanation of Encryption
			text: qsTr('encryptionExplanation')
		}
		Text{
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: InfoEncryptionStyle.descriptionText.leftMargin
			Layout.rightMargin: InfoEncryptionStyle.descriptionText.rightMargin
			
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: InfoEncryptionStyle.descriptionText.pointSize
			color: InfoEncryptionStyle.descriptionText.colorModel.color
			
			wrapMode: Text.Wrap
			//: "To do so, call the contact and follow the authentification process."
			//~ Context Explanation process
			text:  qsTr('encryptionProcessExplanation')
		}
		CheckBoxText{
			id: dontAskAgainCheckBox
			Layout.bottomMargin: 10
			Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
			visible: dialog.addressToCall == ''
			checked: SettingsModel.dontAskAgainInfoEncryption
			onCheckedChanged: SettingsModel.dontAskAgainInfoEncryption = checked
			
			//: "Don't ask again" : Checkbox text to avoid showing the popup information on encryptions.
			text: qsTr('dontAskAgain')
		}
	}
}