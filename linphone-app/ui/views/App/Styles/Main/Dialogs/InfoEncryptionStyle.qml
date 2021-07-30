pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Colors 1.0
import Units 1.0


// =============================================================================

QtObject {
	property QtObject okButton : QtObject{
	  property QtObject backgroundColor: QtObject {
		property color disabled: Colors.i30
		property color hovered: Colors.b
		property color normal: Colors.s
		property color pressed: Colors.m
	  }
	
	  property QtObject textColor: QtObject {
		property color disabled: Colors.q
		property color hovered: Colors.q
		property color normal: Colors.q
		property color pressed: Colors.q
	  }
	 }
}