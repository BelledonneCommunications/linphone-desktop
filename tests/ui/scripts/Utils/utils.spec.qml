import QtQuick 2.7
import QtTest 1.1

// Explicit import, `utils.js` is not accessible in resources file
// when tests are executed.
import './utils.js' as Utils

// ===================================================================

TestCase {
  id: testCase

  name: 'UtilsTests'

  // Test only if a confirm dialog can be opened.
  // The other tests are launched by `ConfirmDialog.spec.qml`.
  function test_openConfirmDialog () {
    var dialog

    try {
      dialog = Utils.openConfirmDialog(testCase, {
        descriptionText: '',
        title: ''
      })
    } catch (e) {
      fail(e)
    }

    if (dialog == null) {
      fail('`dialog` is not returned')
    }

    dialog.close()
  }

  // -----------------------------------------------------------------

  function test_snakeToCamel_data () {
    return [
      { input: 'foo_bar', output: 'fooBar' },
      { input: 'george_abitbol', output: 'georgeAbitbol' },
      { input: 'billTremendousAndHubert', output: 'billTremendousAndHubert' },
      { input: 'foo_bAr_BAZ', output: 'fooBArBAZ' }
    ]
  }

  function test_snakeToCamel (data) {
    compare(Utils.snakeToCamel(data.input), data.output)
  }

  // -----------------------------------------------------------------

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
      fail('`setTimeout` callback was called before `wait`.')
    }

    wait(200)

    if (failed) {
      fail('`setTimeout` failed because callback it was not called in due course.')
    }
  }

  // -----------------------------------------------------------------

  function test_clearTimeout_data () {
    return [
      { time: 0 },
      { time: 100 }
    ]
  }

  function test_clearTimeout (data) {
    var failed = false
    var timeout = Utils.setTimeout.call(testCase, data.time, function () {
      failed = true
    })

    if (failed) {
      fail('`setTimeout` callback was called before `wait`.')
    }

    Utils.clearTimeout(timeout)
    wait(100)

    if (failed) {
      fail('`setTimeout` callback was called after `wait`.')
    }
  }

  // -----------------------------------------------------------------

  function test_times1_data () {
    return [
      {
        cb: function (n) { return n * 2 },
        n: 10,
        output: [ 0, 2, 4, 6, 8, 10, 12, 14, 16, 18 ]
      },
      {
        cb: function (n) { return n % 2 },
        n: 6,
        output: [ 0, 1, 0, 1, 0, 1 ]
      }
    ]
  }

  function test_times1 (data) {
    compare(Utils.times(data.n, data.cb), data.output)
  }

  function test_times2 () {
    var sum = 0
    Utils.times(5, function (i) { sum += (i + 1) })
    compare(sum, 15)
  }

  // -----------------------------------------------------------------

  function test_isString_data () {
    return [
      { input: 'foo', output: true },
      { input: Object('bar'), output: true },
      { input: [ 0 ], output: false },
      { input: /baz/, output: false },
      { input: new Error, output: false },
      { input: true, output: false },
      { input: 42, output: false }
    ]
  }

  function test_isString (data) {
    compare(Utils.isString(data.input), data.output)
  }

  // -----------------------------------------------------------------

  function test_genRandomNumber_data () {
    return [
      { min: 42, max: 3600 },
      { min: 10, max: 100 },
      { min: 58, max: 61 },
      { min: 2, max: 3 }
    ]
  }

  function test_genRandomNumber (data) {
    Utils.times(10, function () {
      var n = Utils.genRandomNumber(data.min, data.max)
      compare(n >= data.min && n < data.max, true)
    })
  }

  function test_genRandomNumberId () {
    compare(Utils.genRandomNumber(42, 42), 42)
  }

  // -----------------------------------------------------------------

  function test_genRandomNumberBetweenIntervals_data () {
    return [
      { intervals: [ [ 1, 5 ] ] },
      { intervals: [ [ 8, 9 ], [ 10, 15 ] ] },
      { intervals: [ [ 1, 4 ], [ 8, 16 ], [ 22, 25 ] ] },
      { intervals: [ [ 11, 12 ], [ 50, 80 ], [ 92, 93 ], [ 1000, 1100 ] ] },
      { intervals: [ [ -5, -2 ] ] },
      { intervals: [ [ -5, -2 ], [ 12, 14 ] ] },
      { intervals: [ [ -127, -111 ], [ -35, -14 ], [ 1256, 1270 ], [ 10000, 10020 ] ] }
    ]
  }

  function test_genRandomNumberBetweenIntervals (data) {
    var intervals = data.intervals

    Utils.times(10, function () {
      var n = Utils.genRandomNumberBetweenIntervals(intervals)

      var soFarSoGood = false
      for (var i = 0; i < intervals.length; i++) {
        if (n >= intervals[i][0] && n < intervals[i][1]) {
          soFarSoGood = true
          break
        }
      }

      compare(
        soFarSoGood,
        true,
        'The generated number cannot be found in a interval.'
      )
    })
  }
}
