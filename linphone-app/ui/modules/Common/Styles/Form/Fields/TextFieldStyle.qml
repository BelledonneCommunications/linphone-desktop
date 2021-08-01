pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================
QtObject {
	property QtObject normal : QtObject {
		property QtObject background: QtObject {
		  property int height: 36
		  property int width: 200
	  
		  property int radius: 4
	  
		  property QtObject border: QtObject {
			property QtObject color: QtObject {
			  property color error: Colors.error.color
			  property color normal: Colors.c.color
			  property color selected: Colors.i.color
			}
	  
			property int width: 1
		  }
	  
		  property QtObject color: QtObject {
			property color normal: Colors.q.color
			property color readOnly: Colors.e.color
		  }
		}
	  
		property QtObject text: QtObject {
		  property color color: Colors.d.color
		  property int pointSize: Units.dp * 10
		  property int rightPadding: 10
		}
	}
	property QtObject unbordered : QtObject {
		property QtObject background: QtObject {
		  property int height: 36
		  property int width: 200
	  
		  property int radius: 4
	  
		  property QtObject border: QtObject {
			property QtObject color: QtObject {
			  property color error: Colors.error.color
			  property color normal: Colors.c.color
			  property color selected: Colors.i.color
			}
	  
			property int width: 0
		  }
	  
		  property QtObject color: QtObject {
			property color normal: Colors.q.color
			property color readOnly: Colors.e.color
		  }
		}
	  
		property QtObject text: QtObject {
		  property color color: Colors.d.color
		  property int pointSize: Units.dp * 10
		  property int rightPadding: 10
		}
	}
}
