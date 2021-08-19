pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.g.color
  property color color: Colors.q.color
  property int arrowSize: 8
  property int delay: 1000
  property int pointSize: Units.dp * 9
  property int margins: 8
  property int padding: 4
  property int radius: 4
  property int minWidth: 130
}
