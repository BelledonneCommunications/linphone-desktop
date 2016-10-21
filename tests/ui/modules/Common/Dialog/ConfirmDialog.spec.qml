import QtQuick 2.7
import QtTest 1.1

// ===================================================================

TestCase {
  id: testCase

  name: 'ConfirmDialogTests'

  Component {
    id: builder

    ConfirmDialog {}
  }

  function buildConfirmDialog () {
    var dialog = builder.createObject(testCase)
    verify(dialog)
    dialog.closing.connect(dialog.destroy.bind(dialog))
    return dialog
  }

  function test_exitStatusViaButtons_data () {
    return [
      { button: 0, expectedStatus: 0 },
      { button: 1, expectedStatus: 1 }
    ]
  }

  function test_exitStatusViaButtons (data) {
    var dialog = buildConfirmDialog()

    dialog.exitStatus.connect(function (status) {
      compare(status, data.expectedStatus)
    })

    mouseClick(dialog.buttons[data.button])
  }

  function test_exitStatusViaClose () {
    var dialog = buildConfirmDialog()

    dialog.exitStatus.connect(function (status) {
      compare(status, 0)
    })

    dialog.close()
  }
}
