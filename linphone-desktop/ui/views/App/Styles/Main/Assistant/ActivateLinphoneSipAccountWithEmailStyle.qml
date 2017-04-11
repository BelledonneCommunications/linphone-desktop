pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int spacing: 20

  property QtObject activationSteps: QtObject {
    property color color: Colors.g
    property int fontSize: 10
  }
}
