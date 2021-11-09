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


GridView{
	id: deliveryLayout
	
	property ChatMessageModel chatMessageModel
		
	//height: visible ? ChatStyle.composingText.height*container.proxyModel.composers.length : 0
	height: visible ? (ChatStyle.composingText.height-5)*deliveryLayout.model.count : 0
	cellWidth: parent.width; cellHeight: ChatStyle.composingText.height-5
	visible:false
	model: ParticipantImdnStateProxyModel{
		id: imdnStatesModel
		chatMessageModel: deliveryLayout.visible ? deliveryLayout.chatMessageModel: null
	}
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
		else return ''
	}
	delegate:Text{
		height: ChatStyle.composingText.height-5
		width: GridView.width
		text: deliveryLayout.getText(modelData.state, modelData.displayName, UtilsCpp.toDateTimeString(modelData.stateChangeTime))
		color: ChatStyle.entry.event.text.color
		font.pointSize: Units.dp * 8
		elide: Text.ElideMiddle
	}
}
