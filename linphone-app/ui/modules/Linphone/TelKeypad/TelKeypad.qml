import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

import 'TelKeypad.js' as Logic

// =============================================================================

Rectangle {
	id: telKeypad
	property bool showHistory: false
	property var container: parent
	property var call
	signal sendDtmf(var dtmf)
	signal keyPressed(var event)
	
	color: TelKeypadStyle.color   // useless as it is overridden by buttons color, but keep it if buttons are transparent
	onActiveFocusChanged: {if(activeFocus) selectedArea.border.width=TelKeypadStyle.selectedBorderWidth; else selectedArea.border.width=0}
	Keys.onPressed: keyPressed(event)
	layer {
		effect: PopupShadow {}
		enabled: true
	}
	
	height: TelKeypadStyle.height + (showHistory ? history.contentHeight : 0)
	width: TelKeypadStyle.width
	radius:TelKeypadStyle.radius+1.0 // +1 for avoid mixing color with border slection (some pixels can be print after the line)
	onVisibleChanged: if(visible) telKeypad.forceActiveFocus()

	// ---------------------------------------------------------------------------
	MouseArea{
			anchors.fill:parent
			onClicked: telKeypad.forceActiveFocus()
	}
	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: TelKeypadStyle.rowSpacing+5
		anchors.bottomMargin: TelKeypadStyle.rowSpacing+5
		anchors.leftMargin: TelKeypadStyle.columnSpacing+5
		anchors.rightMargin: TelKeypadStyle.columnSpacing+5
		
		Text{
			id: history
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: implicitHeight
			color: 'white'
			wrapMode: Text.WrapAnywhere
			horizontalAlignment: Qt.AlignCenter
			visible: showHistory
			MouseArea{
				anchors.fill: parent
				onClicked: parent.text = ''
			}
		}
		
		GridLayout {
			id: grid
			
			columns: 4 // Not a style.
			rows: 4 // Same idea.
			
			columnSpacing: TelKeypadStyle.columnSpacing
			rowSpacing: TelKeypadStyle.rowSpacing
			
			Repeater {
				model: [
					'1', '2', '3', 'A',
					'4', '5', '6', 'B',
					'7', '8', '9', 'C',
					'*', '0', '#', 'D',
				]
				
				TelKeypadButton {
					id: telKeypadButton
					property var _timeout
					showVoicemail: index === 0
					auxSymbol: index === 13 ? '+' : ''
					
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					text: modelData
					onSendDtmf: {
						telKeypad.forceActiveFocus()
						if(telKeypad.call) telKeypad.call.sendDtmf(dtmf) 
						telKeypad.sendDtmf(dtmf)
						if(showHistory)
							history.text += dtmf
					}
					Connections{
						target: telKeypad
						onKeyPressed: telKeypadButton.activateEvent(event.key)
					}
				}
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	
	Rectangle{
		id: selectedArea
		anchors.fill:parent
		color:"transparent"
		border.color:TelKeypadStyle.selectedColor
		border.width:0 
		focus:false
		enabled:false
		radius:TelKeypadStyle.radius
	}
}
