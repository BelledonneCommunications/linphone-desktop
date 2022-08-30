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
	height: visible ? (ChatStyle.composingText.height-5)*(loader.imdnStatesModel.count/2 + 1) : 0
	visible:false
	active: visible
	sourceComponent: 
		GridView{
		id: deliveryLayout
		
		cellWidth: parent.width/2; cellHeight: ChatStyle.composingText.height-5
		interactive: false
		model: loader.imdnStatesModel
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
			else
				//: "Error while sending to %1" Little message to indicate the state of a message
				//~ Context %1 is someone. The state is that the message hasn't been delivered because of an error.
				return qsTr('deliveryError').arg(displayName)
		}
		delegate:Text{
			height: ChatStyle.composingText.height-5
			width: GridView.width
			text: deliveryLayout.getText($modelData.state, $modelData.displayName, UtilsCpp.toDateTimeString($modelData.stateChangeTime))
			color: ChatStyle.entry.event.text.color
			font.pointSize: Units.dp * 8
			elide: Text.ElideMiddle
		}
	}
}
