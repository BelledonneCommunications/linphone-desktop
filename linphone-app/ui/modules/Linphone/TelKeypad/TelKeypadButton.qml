import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: button
  
	property string text: ''
	property bool showVoicemail: false
	property string auxSymbol: ''
	
	signal sendDtmf(var dtmf)
	
	function activateEvent(key){
		var keyString = String.fromCharCode(key)
		if( keyString == text || keyString == auxSymbol){
			actionButton.toggled = true;
			sendDtmf(keyString)
		}
	}
	// ---------------------------------------------------------------------------
	Timer{
		id: untoggledTimer
		interval: 100
		repeat: false
		onTriggered: actionButton.toggled = false
	}
	ActionButton {
		id: actionButton
		onToggledChanged: if(toggled) untoggledTimer.start()
		anchors.fill: parent
		colorSet: TelKeypadStyle.button.colorSet
		backgroundRadius: width/2
		isCustom: true
		property bool doNotSend: false
		
		onPressed: {actionButton.doNotSend = false}
		onReleased: {	if(actionButton.doNotSend)
							actionButton.doNotSend = false
						else {
							actionButton.doNotSend = true;
							button.sendDtmf(button.text)
						}
					}
		onLongPressed:{
							if(actionButton.doNotSend){
								actionButton.doNotSend = false
							}else{
								if( button.auxSymbol != '' && actionButton.hovered) {
									actionButton.doNotSend = true;
									button.sendDtmf(button.auxSymbol)
								}
							}
					}
		
		ColumnLayout {
			anchors.fill: parent
			spacing: 0
			anchors.topMargin: 5
			anchors.bottomMargin: 5
			
			RowLayout{
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignCenter
				Layout.leftMargin: 5
				Layout.rightMargin: 5
				spacing: 0
				Text {
					id: charText
					Layout.fillHeight: true
					Layout.fillWidth: true
					color: TelKeypadStyle.button.text.colorModel.color
					elide: Text.ElideRight
					
					font {
						bold: true
						pointSize: TelKeypadStyle.button.text.pointSize
					}
					
					text: button.text
					
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
				Icon{
					icon: TelKeypadStyle.voicemail.icon
					iconSize: charText.height/2
					overwriteColor: TelKeypadStyle.button.text.colorModel.color
					visible: button.showVoicemail
				}
			}
			Text {
				visible: text != ''
					Layout.fillHeight: true
					Layout.fillWidth: true
					color: TelKeypadStyle.button.text.colorModel.color
					elide: Text.ElideRight
					
					font {
						bold: true
						pointSize: TelKeypadStyle.button.text.pointSize
					}
					
					text: auxSymbol
					
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
		}
	}
 }
