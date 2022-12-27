pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ZrtpTokenAuthenticationDialog'
	
	property int height: 50
	property string pqIcon: 'secure_pq_zrtp'
	property string secureIcon: 'secure_on'
	property string icon: 'secure_level_2'
	
	property int iconSize: 60
	
	property QtObject buttons: QtObject {
		property int spacing: 10
	}
	
	property QtObject text: QtObject {
		property var colorA: ColorsList.add(sectionName+'_zrtp_text_a', 'j')
		property var colorB: ColorsList.add(sectionName+'_zrtp_text_b', 's')
		property int pointSize: Units.dp * 10
		property int titlePointSize: Units.dp * 12
		property int sasPointSize: Units.dp * 13
		property int wordsSpacing: 5
	}
}
