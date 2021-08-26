pragma Singleton
import QtQml 2.2

// =============================================================================
QtObject{
	property QtObject normal :QtObject {
	  property QtObject animation: QtObject {
		property int duration: 200
	  }
	
	  property QtObject indicator: QtObject {
		property int height: 18
		property int radius: 10
		property int width: 48
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: Colors.i.color
			property color disabled: Colors.c.color
			property color normal: Colors.c.color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: Colors.i.color
		  property color disabled: Colors.e.color
		  property color normal: Colors.q.color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: Colors.i.color
			property color disabled: Colors.c.color
			property color normal: Colors.n.color
			property color pressed: Colors.n.color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: Colors.c.color
		  property color disabled: Colors.e.color
		  property color normal: Colors.q.color
		}
	  }
	}
	property QtObject aux : QtObject{
	  property QtObject animation: QtObject {
		property int duration: 200
	  }
	
	  property QtObject indicator: QtObject {
		property int height: 18
		property int radius: 10
		property int width: 48
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: Colors.s.color
			property color disabled: Colors.c.color
			property color normal: Colors.c.color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: Colors.s.color
		  property color disabled: Colors.e.color
		  property color normal: Colors.q.color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: Colors.s.color
			property color disabled: Colors.c.color
			property color normal: Colors.n.color
			property color pressed: Colors.n.color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: Colors.c.color
		  property color disabled: Colors.e.color
		  property color normal: Colors.q.color
		}
	  }
	}
}
