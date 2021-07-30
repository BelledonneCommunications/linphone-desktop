pragma Singleton
import QtQml 2.2
import QtQuick 2.3

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
	property QtObject normal : QtObject{
		property int leftMargin: 5
		property int rightMargin: 5
		
		property QtObject background: QtObject {
			property int height: 30
			
			property QtObject color: QtObject {
				property color hovered: Colors.o
				property color normal: Colors.q
				property color pressed: Colors.o
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Bold
			
			property QtObject color: QtObject {
				property color hovered: Colors.j
				property color normal: Colors.j
				property color pressed: Colors.j
				property color disabled: Colors.l50
			}
		}
	}
	property QtObject aux : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: Colors.v
				property color normal: Colors.a
				property color pressed: Colors.v
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.j
				property color normal: Colors.j
				property color pressed: Colors.j
				property color disabled: Colors.l50
			}
		}
	}
	property QtObject auxRed : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: Colors.v
				property color normal: Colors.a
				property color pressed: Colors.v
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.error
				property color normal: Colors.error
				property color pressed: Colors.error
				property color disabled: Colors.l50
			}
		}
	}
	property QtObject aux2 : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 50
			
			property QtObject color: QtObject {
				property color hovered: Colors.w
				property color normal: Colors.w
				property color pressed: Colors.w
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: Colors.m
				property color normal: Colors.j
				property color pressed: Colors.m
				property color disabled: Colors.l50
			}
		}
	}
}
