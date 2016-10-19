import QtQuick 2.7
import QtTest 1.1

// Explicit import, `utils.js` is not accessible in resources file
// when tests are executed.
import './utils.js' as Utils

// ===================================================================

TestCase {
  id: testCase

  name: 'UtilsTests'

  function test_snakeToCamel_data () {
    return [
      { input: 'foo_bar', output: 'fooBar' },
      { input: 'george_abitbol', output: 'georgeAbitbol' },
      { input: 'billTremendousAndHubert', output: 'billTremendousAndHubert' },
      { input: 'foo_bAr_BAZ', output: 'fooBArBAZ' },
    ]
  }

  function test_snakeToCamel (data) {
    compare(Utils.snakeToCamel(data.input), data.output)
  }

  function test_setTimeoutWithoutParent () {
    try {
      Utils.setTimeout(0, function () {
        fail('`setTimeout` was called without parent.')
      })
    } catch (e) {
      compare(e, 'Error: Qt.createQmlObject(): Missing parent object')
    }
  }

  function test_setTimeout_data () {
    return [
      { time: 0 },
      { time: 100 }
    ]
  }

  function test_setTimeout (data) {
    var failed = true
    Utils.setTimeout.call(testCase, data.time, function () {
      failed = false
    })

    if (!failed) {
      fail('`setTimeout` callback was called before `wait`')
    }

    wait(200)

    if (failed) {
      fail('`setTimeout` failed because callback it was not called in due course')
    }
  }
}
