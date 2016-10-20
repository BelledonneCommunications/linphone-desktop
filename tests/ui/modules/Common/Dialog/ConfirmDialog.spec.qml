import QtQuick 2.7
import QtTest 1.1

// ===================================================================

TestCase {
  id: testCase

  name: 'ConfirmDialogTests'

  function createDialog () {
    var component = Qt.createComponent(
      './ConfirmDialog.qml'
    )

    if (component.status !== Component.Ready) {
      if(component.status === Component.Error) {
        fail('Error:' + component.errorString())
      } else {
        fail('Dialog not ready.')
      }
    }

    var dialog = component.createObject(testCase)
    dialog.closing.connect(dialog.destroy.bind(dialog))
    return dialog
  }


  function test_exitStatusViaButtons_data () {
    return [
      { button: 0, expectedStatus: 0 },
      { button: 1, expectedStatus: 1 },
    ]
  }

  function test_exitStatusViaButtons (data) {
    var dialog = createDialog()

    dialog.exitStatus.connect(function (status) {
      compare(status, data.expectedStatus)
    })

    dialog.show()
    mouseClick(dialog.buttons[data.button])
  }

  function test_exitStatusViaClose () {
    var dialog = createDialog()

    dialog.exitStatus.connect(function (status) {
      compare(status, 0)
    })
    dialog.close()
  }
}
