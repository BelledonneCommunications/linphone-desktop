import QtQuick 2.7
import QtTest 1.1

import Utils 1.0

// ===================================================================

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
  }

  TestCase {
    when: windowShown

    function test_randomInsideMouseArea () {
      var failFun = function () {
        fail('`pressed` signal was emitted.')
      }

      invertedMouseArea.pressed.connect(failFun)

      Utils.times(100, function () {
        var x = Math.floor(Utils.genRandomNumber(item.x, item.x + width))
        var y = Math.floor(Utils.genRandomNumber(item.y, item.y + height))

        mouseClick(root, x, y)
      })

      wait(100)
      invertedMouseArea.pressed.disconnect(failFun)
    }

    function test_randomOutsideMouseArea () {
      spy.target = invertedMouseArea

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
  }
}
