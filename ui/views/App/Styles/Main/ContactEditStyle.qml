pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject buttons: QtObject {
    property int spacing: 20
    property int topMargin: 20
  }

  property QtObject bar: QtObject {
    property color color: Colors.e
    property int avatarSize: 60
    property int height: 80
    property int leftMargin: 40
    property int rightMargin: 20
    property int spacing: 20

    property QtObject actions: QtObject {
      property int spacing: 40

      property QtObject del: QtObject {
        property int iconSize: 22
      }

      property QtObject edit: QtObject {
        property int iconSize: 22
      }

      property QtObject history: QtObject {
        property int iconSize: 40
      }
    }

    property QtObject buttons: QtObject {
      property int size: 40
      property int spacing: 20
    }

    property QtObject username: QtObject {
      property color color: Colors.j
      property int pointSize: Units.dp * 13
    }
  }

  property QtObject content: QtObject {
    property color color: Colors.k
  }

  property QtObject values: QtObject {
    property int bottomMargin: 20
    property int leftMargin: 40
    property int rightMargin: 20
    property int topMargin: 20

    property QtObject separator: QtObject {
      property color color: Colors.f
      property int height: 1
    }
  }
}
