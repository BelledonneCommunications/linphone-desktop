pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int minimumHeight: 480
  property int minimumWidth: 960
  property string title: 'Linphone'

	property QtObject callsList: QtObject {
		property color color: Colors.k

		property QtObject header: QtObject {
			property int height: 60
			property color color1: Colors.k
			property color color2: Colors.v
		}
	}
}
