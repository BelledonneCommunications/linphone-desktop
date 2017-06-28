pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k

  property QtObject sectionHeading: QtObject {
    property int padding: 5
    property int bottomMargin: 20

    property QtObject border: QtObject {
      property color color: Colors.p
      property int width: 1
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 10
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

  property QtObject composingText: QtObject {
    property color color: Colors.b
    property int height: 25
    property int leftPadding: 20
    property int pointSize: Units.dp * 9
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
        property int pointSize: Units.dp * 10
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

      property QtObject file: QtObject {
        property int height: 64
        property int iconSize: 18
        property int margins: 8
        property int spacing: 8
        property int width: 250

        property QtObject animation: QtObject {
          property int duration: 200
          property real to: 1.5
        }

        property QtObject extension: QtObject {
          property QtObject background: QtObject {
            property color color: Colors.l50
          }

          property QtObject text: QtObject {
            property color color: Colors.k
          }
        }

        property QtObject status: QtObject {
          property int spacing: 4

          property QtObject bar: QtObject {
            property int height: 6
            property int radius: 3

            property QtObject background: QtObject {
              property color color: Colors.f
            }

            property QtObject contentItem: QtObject {
              property color color: Colors.z
            }
          }
        }
      }

      property QtObject images: QtObject {
        property int height: 48
      }

      property QtObject incoming: QtObject {
        property color backgroundColor: Colors.y
        property int avatarSize: 20

        property QtObject text: QtObject {
          property color color: Colors.r
          property int pointSize: Units.dp * 10
        }
      }

      property QtObject outgoing: QtObject {
        property color backgroundColor: Colors.e
        property int sendIconSize: 12

        property QtObject text: QtObject {
          property color color: Colors.r
          property int pointSize: Units.dp * 10
        }
      }
    }

    property QtObject time: QtObject {
      property color color: Colors.x
      property int pointSize: Units.dp * 10
      property int width: 44
    }
  }
}
