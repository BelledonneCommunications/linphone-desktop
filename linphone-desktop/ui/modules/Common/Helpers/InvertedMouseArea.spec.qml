import QtQuick 2.7
import QtTest 1.1

import Utils 1.0

// =============================================================================

Rectangle {
  id: root

  color: 'violet'
  height: 200
  width: 300

  Rectangle {
    id: item

    color: 'pink'
    height: 80
    width: 100
    x: 120
    y: 100

    InvertedMouseArea {
      id: invertedMouseArea

      anchors.fill: parent
    }
  }

  SignalSpy {
    id: spy

    signalName: 'pressed'
    target: invertedMouseArea
  }

  TestCase {
    when: windowShown

    function init () {
      spy.clear()
    }

    function test_randomClickInsideMouseArea () {
      Utils.times(100, function () {
        var x = Math.floor(Utils.genRandomNumber(item.x, item.x + width))
        var y = Math.floor(Utils.genRandomNumber(item.y, item.y + height))

        mouseClick(root, x, y)
      })

      wait(100)
      compare(spy.count, 0, '`pressed` signal was emitted')
    }

    // -------------------------------------------------------------------------

    function test_randomClickOutsideMouseArea () {
      Utils.times(50, function () {
        var x = Math.floor(Utils.genRandomNumberBetweenIntervals([
          [ 0, item.x ], [ item.x + item.width, root.width ]
        ]))
        var y = Math.floor(Utils.genRandomNumberBetweenIntervals([
          [ 0, item.y ], [ item.y + item.height, root.height ]
        ]))

        mouseClick(root, x, y)
        spy.wait(100)
      })

      Utils.times(50, function () {
        var x = Math.floor(Utils.genRandomNumber(item.x, item.x + item.width))
        var y = Math.floor(Utils.genRandomNumberBetweenIntervals([
          [ 0, item.y ], [ item.y + item.height, root.height ]
        ]))

        mouseClick(root, x, y)
        spy.wait(100)
      })
    }

    // -------------------------------------------------------------------------

    function test_clickInsideMouseArea_data () {
      return [
        { x: item.x, y: item.y },
        { x: item.x + item.width - 1, y: item.y },
        { x: item.x, y: item.y + item.height - 1},
        { x: item.x + item.width - 1, y: item.y + item.height - 1 },
        { } // (x, y) = item center.
      ]
    }

    function test_clickInsideMouseArea (data) {
      mouseClick(root, data.x, data.y)
      wait(100)
      compare(spy.count, 0, '`pressed` signal was emitted')
    }

    // -------------------------------------------------------------------------

    function test_clickOutsideMouseArea_data () {
      return [
        { x: item.x - 1, y: item.y - 1},
        { x: item.x + item.width, y: item.y },
        { x: item.x, y: item.y + item.height },
        { x: item.x + item.width, y: item.y + item.height }
      ]
    }

    function test_clickOutsideMouseArea (data) {
      mouseClick(root, data.x, data.y)
      spy.wait(100)
    }
  }
}
