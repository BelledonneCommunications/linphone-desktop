pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject bar: QtObject {
    property color backgroundColor: Colors.e
    property int avatarSize: 60
    property int height: 80
    property int leftMargin: 40
    property int rightMargin: 30
    property int spacing: 20

    property QtObject actions: QtObject {
      property int spacing: 40

      property QtObject call: QtObject {
        property int iconSize: 40
      }

      property QtObject del: QtObject {
        property int iconSize: 22
      }

      property QtObject edit: QtObject {
        property int iconSize: 22
      }
    }

    property QtObject description: QtObject {
      property color sipAddressColor: Colors.g
      property color usernameColor: Colors.j
    }
  }

  property QtObject filters: QtObject {
    property color backgroundColor: Colors.k
    property int height: 51
    property int leftMargin: 40

    property QtObject border: QtObject {
      property color color: Colors.p
      property int bottomWidth: 1
      property int topWidth: 0
    }
  }
}
