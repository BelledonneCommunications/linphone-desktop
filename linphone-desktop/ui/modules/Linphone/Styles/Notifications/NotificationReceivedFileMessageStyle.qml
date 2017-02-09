pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
	property color color: Colors.k
	property int height: 55
	property int iconSize: 40
	property int leftMargin: 25
	property int rightMargin: 15
	property int spacing: 10
	property int width: 300

	property QtObject fileName: QtObject {
		property color color: Colors.h
		property int fontSize: 10
	}

	property QtObject fileSize: QtObject {
		property color color: Colors.h
		property int fontSize: 9
		property int width: 100
	}
}
