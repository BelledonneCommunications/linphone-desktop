pragma Singleton
import QtQuick 2.7

// =============================================================================

QtObject {
  property color color: '#444444' // Not a `Common.Color`. Specific case.
  property int height: 350
  property int width: 620
  property url image: 'qrc:/assets/images/splash_screen.svg'

  property QtObject busyIndicator: QtObject {
    property int bottomMargin: 25
    property int height: 24
    property int width: 24
  }
}
