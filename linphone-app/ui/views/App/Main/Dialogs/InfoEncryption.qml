import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
//import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0


// =============================================================================

DialogPlus {
	id:dialog
	buttons: [
		TextButtonA {
			text: 'CANCEL'
			//visible: addressToCall != ''
			onClicked:{
				exit(0)
			}
		},
		TextButtonB {
			text: (addressToCall != '' ? 'CALL' : 'OK')
			textButtonStyle: InfoEncryptionStyle.okButton
			onClicked: {
				if(addressToCall != ''){
					CallsListModel.launchSecureAudioCall(addressToCall, LinphoneEnums.MediaEncryptionZrtp)
				}
				exit(1)
			}
		}
	]
	flat : true
	
	title: "End-to-end encrypted"
	showCloseCross:false
	
	property int securityLevel
	property string addressToCall
	
	buttonsAlignment: Qt.AlignCenter
	
	height: ManageAccountsStyle.height
	width: ManageAccountsStyle.width
	
	// ---------------------------------------------------------------------------
	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: 15
		anchors.leftMargin: 10
		anchors.rightMargin: 10
		spacing: 0
		
		Layout.alignment: Qt.AlignCenter
		
		Icon{
			icon: dialog.securityLevel === 2?'secure_level_1': dialog.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'
			iconSize:40
			Layout.preferredHeight: 50
			Layout.preferredWidth: 50
			Layout.alignment: Qt.AlignCenter
		}
		Text{
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: 10
			Layout.rightMargin: 10
			
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: Units.dp * 11
			color: Colors.d.color
			
			wrapMode: Text.Wrap
			
			text: "Instant messages are end-to-end encrypted in secured conversations. It is possible to upgrade the security level of a conversation by authentificating participants."
		}
		Text{
		Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: 10
			Layout.rightMargin: 10
			
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: Units.dp * 11
			color: Colors.d.color
			
			wrapMode: Text.Wrap
			text :"To do so, call the contact and follow the authentification process."
		}
	}
}