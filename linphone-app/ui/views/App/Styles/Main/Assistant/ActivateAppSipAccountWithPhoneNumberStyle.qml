pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 20

  property QtObject activationSteps: QtObject {
    property color color: Colors.g.color
    property int pointSize: Units.dp * 10
  }
}
