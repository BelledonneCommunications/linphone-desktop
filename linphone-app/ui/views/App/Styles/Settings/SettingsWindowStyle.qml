pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property color color: Colors.k.color
  property int height: 640
  property int width: 1024

  property QtObject forms: QtObject {
    property int spacing: 10
  }

  property QtObject validButton: QtObject {
    property int bottomMargin: 30
    property int rightMargin: 30
    property int topMargin: 30
  }

  property QtObject sipAccounts: QtObject {
    property int buttonsSpacing: 8
    property int iconSize: 22
    property int legendLineWidth: 280
  }
  property QtObject video: QtObject {
    property QtObject warningMessage: QtObject {
      property int iconSize: 20
    }
  }
}
