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
import Linphone.Styles 1.0
import Units 1.0

import ColorsList 1.0


import 'Conversation.js' as Logic

// =============================================================================

RowLayout{
	spacing: 0
	CallTimeline{
		Layout.fillHeight: true
		Layout.preferredWidth: MainWindowStyle.menu.width
		
		onEntrySelected:{
						content.setSource('HistoryView.qml', {
								callHistoryModel: model
							   })
					}
	}
	Loader{
		id: content
		Layout.fillHeight: true
		Layout.fillWidth: true
	}
}



