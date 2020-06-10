import QtQuick 2.7
import QtTest 1.1

// =============================================================================

Item {
  id: root

  function buildExclusiveButtons (defaultSelectedButton) {
    var container = builder.createObject(root)
    testCase.verify(container)

    container.data[0].selectedButton = defaultSelectedButton
    return container
  }

  // Avoid `Test 'XXX' has invalid size QSize(0, 0), resizing.` warning.
  height: 100
  width: 300

  Component {
    id: builder

    Item {
      ExclusiveButtons {
        id: exclusiveButtons

        texts: ['A', 'B', 'C', 'D', 'E']
      }
    }
  }

  // ---------------------------------------------------------------------------

  TestCase {
    id: testCase
    when: windowShown

    function test_signals_data () {
      return [
        { defaultSelectedButton: 0, buttonToClick: 2 },
        { defaultSelectedButton: 1, buttonToClick: 4 },
        { defaultSelectedButton: 3, buttonToClick: 1 },
        { defaultSelectedButton: 4, buttonToClick: 0 }
      ]
    }

    function test_signals (data) {
      var container = buildExclusiveButtons(data.defaultSelectedButton)
      var exclusiveButtons = container.data[0]
      var buttonToClick = data.buttonToClick

      // Test default selected button.
      compare(exclusiveButtons.selectedButton, data.defaultSelectedButton)

      var button = -1
      var count = 0

      exclusiveButtons.clicked.connect(function (_button) {
        button = _button
        count += 1
      })

      // Test a click to change the selected button.
      mouseClick(exclusiveButtons.data[buttonToClick])

      compare(button, buttonToClick)
      compare(exclusiveButtons.selectedButton, buttonToClick)
      compare(count, 1)

      // No signal must be emitted.
      mouseClick(exclusiveButtons.data[buttonToClick])

      compare(button, buttonToClick)
      compare(exclusiveButtons.selectedButton, buttonToClick)
      compare(count, 1)

      container.destroy()
    }
  }
}
