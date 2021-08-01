pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0

// =============================================================================

QtObject {
	property QtObject bar: QtObject {
		property color backgroundColor: Colors.e.color
		property int avatarSize: 60
		property int groupChatSize: 55
		property int height: 80
		property int leftMargin: 40
		property int rightMargin: 10
		property int spacing: 20
		
		property QtObject actions: QtObject {
			property int spacing: 20
			
			property QtObject call: QtObject {
				property int iconSize: 40
			}
			
			property QtObject del: QtObject {
				property int iconSize: 22
			}
			
			property QtObject edit: QtObject {
				property int iconSize: 22
			}
		}
		
		property QtObject contactDescription : QtObject {
			property QtObject sipAddress: QtObject {
				property color color: Colors.n.color
				property int pointSize: Units.dp * 10
				property int weight: Font.Light
			}
			
			property QtObject username: QtObject {
				property color color: Colors.j.color
				property int pointSize: Units.dp * 11
				property int weight: Font.Normal
				property QtObject status : QtObject{
					property color color : Colors.g.color
					property int pointSize : Units.dp * 9
				}
			}
		}
	}
	
	property QtObject filters: QtObject {
		property color backgroundColor: Colors.q.color
		property int height: 51
		property int leftMargin: 40
		
		property QtObject border: QtObject {
			property color color: Colors.g10.color
			property int bottomWidth: 1
			property int topWidth: 0
		}
	}
	
	
}
