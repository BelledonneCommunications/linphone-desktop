pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property color color: Colors.i
  property int duration: 1250
  property int nSpheres: 6
}
