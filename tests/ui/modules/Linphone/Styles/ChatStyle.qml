pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject sectionHeading: QtObject {
    property int padding: 5
    property int bottomMargin: 20

    property QtObject border: QtObject {
      property color color: Colors.p
      property int width: 1
    }

    property QtObject text: QtObject {
      property int fontSize: 10
      property color color: Colors.g
    }
  }

  property QtObject sendArea: QtObject {
    property int height: 80

    property QtObject border: QtObject {
      property color color: Colors.u
      property int width: 1
    }
  }

  property QtObject entry: QtObject {
    property int bottomMargin: 10
    property int deleteIconSize: 17
    property int leftMargin: 18
    property int lineHeight: 30
    property int metaWidth: 40

    property QtObject event: QtObject {
      property int iconSize: 18

      property QtObject text: QtObject {
        property color color: Colors.r
        property int fontSize: 10
      }
    }

    property QtObject message: QtObject {
      property int padding: 8
      property int radius: 4

      property QtObject extraContent: QtObject {
        property int leftMargin: 10
        property int spacing: 5
        property int rightMargin: 5
      }

      property QtObject images: QtObject {
        property int height: 48
        // `width` can be used.
      }

      property QtObject incoming: QtObject {
        property color backgroundColor: Colors.y
        property int avatarSize: 20

        property QtObject text: QtObject {
          property color color: Colors.r
          property int fontSize: 10
        }
      }

      property QtObject outgoing: QtObject {
        property color backgroundColor: Colors.e
        property int sendIconSize: 12

        property QtObject text: QtObject {
          property color color: Colors.r
          property int fontSize: 10
        }
      }
    }

    property QtObject time: QtObject {
      property color color: Colors.x
      property int fontSize: 10
      property int width: 44
    }
  }
}
