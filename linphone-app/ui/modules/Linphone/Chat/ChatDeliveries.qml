import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import 'Message.js' as Logic

// =============================================================================


Loader{
	id: loader
	property ChatMessageModel chatMessageModel
	property ParticipantImdnStateProxyModel imdnStatesModel: ParticipantImdnStateProxyModel {
		chatMessageModel: loader.chatMessageModel
	}
	height: visible ? loader.cellHeight * Math.ceil(loader.imdnStatesModel.count/ columnCount): 0
	visible:false
	active: visible
	property int fitWidth: 0
	property int cellWidth: fitWidth > 0 ? Math.min(width/2, fitWidth): width/2
	property int cellHeight: ChatStyle.composingText.height-5
	property int reset : 0
	property int columnCount: width / cellWidth + reset
	
	Timer{// BUG: Force Qt to refresh the layout because its layout while loading is wrong.
		id: refreshLayout
		interval: 10
		onTriggered: {++loader.reset;--loader.reset}
	}
	sourceComponent: 
		GridView{
		id: deliveryLayout
		
		cellWidth: loader.cellWidth ; cellHeight: loader.cellHeight
		
		interactive: false
		model: loader.imdnStatesModel
		layoutDirection: chatMessageModel.isOutgoing ? Qt.RightToLeft : Qt.LeftToRight
		verticalLayoutDirection: chatMessageModel.isOutgoing ? GridView.BottomToTop : GridView.TopToBottom
		Component.onCompleted: refreshLayout.start()
		function getText(state, displayName, stateChangeTime){
			if(state == LinphoneEnums.ChatMessageStateDelivered)
				//: 'Send to %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state is that the message has been sent but not received.
				return qsTr('deliveryDelivered').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateDeliveredToUser)
				//: 'Retrieved by %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state is that the message has been retrieved
				return qsTr('deliveryDeliveredToUser').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateDisplayed)
				//: 'Read by %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state that the message has been read.
				return qsTr('deliveryDisplayed').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateNotDelivered)
				//: "%1 have nothing received" Little message to indicate the state of a message
				//~ Context %1 is someone. The state is that the message hasn't been delivered.
				return qsTr('deliveryNotDelivered').arg(displayName)
			else if(state == LinphoneEnums.ChatMessageStateIdle)
				return ''
			else
				//: "Error while sending to %1" Little message to indicate the state of a message
				//~ Context %1 is someone. The state is that the message hasn't been delivered because of an error.
				return qsTr('deliveryError').arg(displayName)
		}
		delegate:Text{
			id: textArea
			height: loader.cellHeight
			width: loader.cellWidth
			text: deliveryLayout.getText($modelData.state, $modelData.displayName, UtilsCpp.toDateTimeString($modelData.stateChangeTime))
			color: ChatStyle.entry.event.text.colorModel.color
			font.pointSize: Units.dp * 8
			elide: Text.ElideMiddle
			TextMetrics{
				text: textArea.text
				Component.onCompleted: loader.fitWidth = Math.max(loader.fitWidth, width)
			}
		}
	}
}
