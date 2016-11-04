pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject sectionHeading: QtObject {
    property int padding: 5
    property int bottomMargin: 20

    property QtObject border: QtObject {
      property color color: '#E2E9EF'
      property int width: 1
    }

    property QtObject text: QtObject {
      property int fontSize: 10
      property color color: '#6B7A86'
    }
  }

  property QtObject sendArea: QtObject {
    property int height: 80

    property QtObject border: QtObject {
      property color color: '#B1B1B1'
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
        property color color: '#595759'
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

      property QtObject incoming: QtObject {
        property color backgroundColor: '#D0D8DE'

        property QtObject text: QtObject {
          property color color: '#595759'
          property int fontSize: 10
        }
      }

      property QtObject outgoing: QtObject {
        property color backgroundColor: '#F3F3F3'
        property int sendIconSize: 12

        property QtObject text: QtObject {
          property color color: '#595759'
          property int fontSize: 10
        }
      }
    }

    property QtObject time: QtObject {
      property color color: '#96A5B1'
      property int fontSize: 10
      property int width: 44
    }
  }
}
