import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0

import ColorsList 1.0


import 'Conversation.js' as Logic

// =============================================================================
RowLayout{
	spacing: 0
	Component.onDestruction: timeline.model.unselectAll()
	
	Timeline{
		id: timeline
		Layout.fillHeight: true
		Layout.preferredWidth: MainWindowStyle.menu.width
		
		showHistoryButton: false
		
		onEntrySelected:{
			if( entry ) {
				if( entry.selected){
					console.debug("Load conversation from entry selected on timeline")
					content.setSource('Conversation.qml', {
								chatRoomModel:entry.chatRoomModel
							   })
				}
			}else{
				//window.setView('Home', {})
			}
			//menu.resetSelectedEntry()
		}
		onShowHistoryRequest: {
			//timeline.model.unselectAll()
			//window.setView('HistoryView')
		}
		Component.onCompleted: {
			var selectedTimeline = timeline.model.selectedTimeline;
			if( selectedTimeline){
				content.setSource('Conversation.qml', {
								chatRoomModel:selectedTimeline.chatRoomModel
							   })
			}
		}
	}
	Loader{
		id: content
		Layout.fillHeight: true
		Layout.fillWidth: true
	}
}
