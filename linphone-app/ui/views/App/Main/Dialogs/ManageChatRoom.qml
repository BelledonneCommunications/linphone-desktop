import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0


// =============================================================================

DialogPlus {
	property ChatRoomModel chatRoomModel
	property var participantAddress : (chatRoomModel?chatRoomModel.getParticipants(): null)
												  
				  buttons: [
					  TextButtonA {
						  text: 'cancel'
						  
						  onClicked: exit(0)
					  },
					  TextButtonB {
						  text: 'del'
						  visible:chatRoomModel
						  
						  onClicked: {
							  if(chatRoomModel){
								  chatRoomModel.leaveChatRoom()
								  exit(0)
							  }
						  }
					  },
					  TextButtonB {
						  text: 'ok'
						  
						  onClicked: {
							  if(chatRoomModel && CallsListModel.createSecureChat(subject.text, participantAddress))
								  exit(0)
						  }
					  }
				  ]
	   
	   buttonsAlignment: Qt.AlignCenter
	   
	   height: ManageAccountsStyle.height
	   width: ManageAccountsStyle.width
	   
	   // ---------------------------------------------------------------------------
	   
	   Form {
		   anchors.fill: parent
		   orientation: Qt.Vertical
		   
		   FormLine {
			   
			   FormGroup {
				   label: 'Details'
				   
				   FormLine {
					   FormGroup {
						   label: 'Subject*'
						   TextField {
							   id:subject
							   placeholderText :"Subject"
							   text:(chatRoomModel?chatRoomModel.getSubject():'')
							   Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							   error : text == ''
							   TooltipArea{
								   text : 'Current subject of the ChatRoom. It cannot be empty'
							   }
						   }
					   }
				   }
			   }
		   }
		   
		   
		   FormLine {
			   FormGroup {
				   label: 'Participants : '+participantAddress
				   /*
ScrollableListViewField {
width: parent.width
height: ManageAccountsStyle.accountSelector.height

radius: 0

ScrollableListView {
id: view

property string textRole: 'fullSipAddress' // Used by delegate.

anchors.fill: parent
model: AccountSettingsModel.accounts

onModelChanged: currentIndex = Utils.findIndex(AccountSettingsModel.accounts, function (account) {
return account.sipAddress === AccountSettingsModel.sipAddress
})

delegate: CommonItemDelegate {
id: item
container: view
flattenedModel: modelData
itemIcon: ''//Start with no error and let some time before getting status with the below timer
width: parent.width

Timer{// This timer is used to synchronize registration state by proxy, without having to deal with change signals
interval: 1000; running: item.visible; repeat: true
onTriggered:itemIcon= Logic.getItemIcon(flattenedModel)
}

ActionButton {
icon: 'options'
iconSize: 30
anchors.fill: parent
visible:false
//TODO handle click and jump to proxy config settings
}

onClicked: {
container.currentIndex = index
if(flattenedModel.proxyConfig)
AccountSettingsModel.setDefaultProxyConfig(flattenedModel.proxyConfig)
else
AccountSettingsModel.setDefaultProxyConfig()
}

MessageCounter {
anchors.fill: parent
count: flattenedModel.unreadMessageCount+flattenedModel.missedCallCount
}
}
}
}
*/
			   }
			   
		   }
		   
	   }
}
									   
