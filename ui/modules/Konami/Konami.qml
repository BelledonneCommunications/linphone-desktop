/*
 * Konami.qml
 * Copyright 2017 Ronan Abhamon (https://github.com/Wescoeur)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick 2.7

// =============================================================================

Item {
  id: konami

  property var code: [
    Qt.Key_Up,
    Qt.Key_Up,
    Qt.Key_Down,
    Qt.Key_Down,
    Qt.Key_Left,
    Qt.Key_Right,
    Qt.Key_Left,
    Qt.Key_Right,
    Qt.Key_B,
    Qt.Key_A
  ]

  property int delay: 2000

  signal triggered

  // ---------------------------------------------------------------------------

  Keys.forwardTo: core

  Timer {
    id: timer

    interval: konami.delay

    onTriggered: core.index = 0
  }

  Item {
    id: core

    property int index: 0

    anchors.fill: parent

    Keys.onPressed: {
      timer.stop()

      var code = konami.code
      if (event.key === code[index]) {
        // 1. Code OK.
        if (++index === code.length) {
          index = 0

          konami.triggered()
          return
        }

        // 2. Actual key OK.
        if (delay > 0) {
          timer.start()
        }

        return
      }

      // 3. Wrong key.
      index = 0
    }
  }
}
