pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.g
  property color color: Colors.k
  property int arrowSize: 8
  property int delay: 1000
  property int pointSize: Units.dp * 9
  property int margins: 8
  property int padding: 4
  property int radius: 4
}
