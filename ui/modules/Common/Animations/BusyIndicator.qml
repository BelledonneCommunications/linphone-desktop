import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

BusyIndicator {
  id: busyIndicator

  // ---------------------------------------------------------------------------

  property color color: BusyIndicatorStyle.color

  readonly property int _rotation: 360
  readonly property int _size: width < height ? width : height

  // ---------------------------------------------------------------------------

  visible: running

  contentItem: Item {
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    height: _size
    width: _size

    Item {
      id: item

      height: parent.height
      width: parent.width

      // -----------------------------------------------------------------------
      // Animation.
      // -----------------------------------------------------------------------

      RotationAnimator {
        duration: BusyIndicatorStyle.duration
        loops: Animation.Infinite
        running: busyIndicator.visible && busyIndicator.running
        target: item

        from: 0
        to: busyIndicator._rotation
      }

      // -----------------------------------------------------------------------
      // Items to draw.
      // -----------------------------------------------------------------------

      Repeater {
        id: repeater

        model: BusyIndicatorStyle.nSpheres

        Rectangle {
          x: item.width / 2 - width / 2
          y: item.height / 2 - height / 2

          height: item.height / 3
          width: item.width / 3

          color: busyIndicator.color
          radius: (width > height ? width : height) / 2

          transform: [
            Translate {
              y: busyIndicator._size / 2
            },
            Rotation {
              angle: index / repeater.count * busyIndicator._rotation
              origin {
                x: width / 2
                y: height / 2
              }
            }
          ]
        }
      }
    }
  }
}
