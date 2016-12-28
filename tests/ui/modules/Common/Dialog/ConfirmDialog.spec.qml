import QtQuick 2.7
import QtTest 1.1

// =============================================================================

TestCase {
  id: testCase

  function buildConfirmDialog () {
    var container = builder.createObject(testCase)
    verify(container)

    var dialog = container.data[0]
    dialog.closing.connect(dialog.destroy.bind(dialog))

    return container
  }

  // ---------------------------------------------------------------------------

  function test_exitStatusViaButtons_data () {
    return [
      { button: 0, expectedStatus: 0 },
      { button: 1, expectedStatus: 1 }
    ]
  }

  function test_exitStatusViaButtons (data) {
    var container = buildConfirmDialog()
    var dialog = container.data[0]
    var spy = container.data[1]

    mouseClick(dialog.buttons[data.button])
    spy.wait(100)
    compare(spy.signalArguments[0][0], data.expectedStatus)
  }

  // ---------------------------------------------------------------------------

  function test_exitStatusViaClose () {
    var container = buildConfirmDialog()
    var dialog = container.data[0]
    var spy = container.data[1]

    dialog.close()
    spy.wait(100)
    compare(spy.signalArguments[0][0], 0)
  }

  // ---------------------------------------------------------------------------

  Component {
    id: builder

    Item {
      ConfirmDialog {
        id: confirmDialog
      }

      SignalSpy {
        id: spy

        signalName: 'exitStatus'
        target: confirmDialog
      }
    }
  }
}
