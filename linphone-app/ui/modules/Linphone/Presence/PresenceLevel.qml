import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

// Wrapper to use `icon` property.
Item {
	property var level: null
	property bool betterIcon : false
	property var timestamp
	property string text: {
		if( level === 0)
			//: 'Online⁣': Presence text
			return qsTr('presenceOnline');
		else if(visible){
			var d = new Date(timestamp)
			if(isNaN(d))
				return qsTr('presenceAway')
			var yesterday = new Date()
			yesterday.setDate(yesterday.getDate() - 1)
			if (Utils.equalDate(d, new Date()))
				//: 'Online today at %1' : Presence text for today (%1 is the hour)
				return qsTr('presenceLastSeenToday').arg(d.toLocaleString(App.locale, 'HH:mm'))
			else if(Utils.equalDate(d,yesterday))
				//: 'Online yesterday at %1' : Presence text for yesterday (%1 is the hour)
				return qsTr('presenceLastSeenYesterday').arg(d.toLocaleString(App.locale, 'HH:mm'))
			else
				//: 'Online on %1' : Presence text for latter days (%1 is a date)
				return qsTr('presenceLastSeen').arg(d.toLocaleDateString(App.locale))
		}else
			return Presence.getPresenceStatusAsString(level)
	}
	visible: icon.icon != ''
	
	Icon {
		id: icon
		anchors.centerIn: parent
		
		icon: (level !== -1 && level != null && level !== 3)// Hide Offline status as it is not fully supported
			  ? (betterIcon? Presence.getBetterPresenceLevelIconName(level) : Presence.getPresenceLevelIconName(level))
			  : ''
		iconSize: parent.height > parent.width
				  ? parent.width
				  : parent.height
	}
}
