pragma Singleton
import QtQml 2.2
import QtQuick 2.3

import Units 1.0

// =============================================================================

QtObject {
	property QtObject normal : QtObject{
		property int leftMargin: 5
		property int rightMargin: 5
		
		property QtObject background: QtObject {
			property int height: 30
			
			property QtObject color: QtObject {
				property color hovered: Colors.o.color
				property color normal: Colors.q.color
				property color pressed: Colors.o.color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Bold
			
			property QtObject color: QtObject {
				property color hovered: Colors.j.color
				property color normal: Colors.j.color
				property color pressed: Colors.j.color
				property color disabled: Colors.l50.color
			}
		}
	}
	property QtObject aux : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: Colors.v.color
				property color normal: Colors.a.color
				property color pressed: Colors.v.color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.j.color
				property color normal: Colors.j.color
				property color pressed: Colors.j.color
				property color disabled: Colors.l50.color
			}
		}
	}
	property QtObject auxRed : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: Colors.v.color
				property color normal: Colors.a.color
				property color pressed: Colors.v.color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.error.color
				property color normal: Colors.error.color
				property color pressed: Colors.error.color
				property color disabled: Colors.l50.color
			}
		}
	}
	property QtObject aux2 : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 50
			
			property QtObject color: QtObject {
				property color hovered: Colors.w.color
				property color normal: Colors.w.color
				property color pressed: Colors.w.color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.m.color
				property color normal: Colors.j.color
				property color pressed: Colors.m.color
				property color disabled: Colors.l50.color
			}
		}
	}
}
