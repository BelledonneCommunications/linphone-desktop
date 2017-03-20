import QtQuick 2.7
import QtTest 1.1

// Explicit import, `utils.js` is not accessible in resources file
// when tests are executed.
import './utils.js' as Utils

// =============================================================================

TestCase {
  id: testCase

  // ===========================================================================
  // QML helpers.
  // ===========================================================================

  function test_clearTimeout_data () {
    return [
      { time: 0 },
      { time: 100 }
    ]
  }

  function test_clearTimeout (data) {
    var failed = false
    var timeout = Utils.setTimeout(testCase, data.time, function () {
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

  // ---------------------------------------------------------------------------

  function test_qmlTypeof_data () {
    return [
      {
        component: 'import QtQuick 2.7; ListModel {}',
        result: true,
        type: 'QQmlListModel'
      }, {
        component: 'import QtQuick 2.7; ListView {}',
        result: true,
        type: 'QQuickListView'
      }, {
        component: 'import QtQuick 2.7; MouseArea {}',
        result: true,
        type: 'QQuickMouseArea'
      }, {
        component: 'import QtQuick 2.7; import QtQuick.Window 2.2; Window {}',
        result: true,
        type: 'QQuickWindowQmlImpl'
      }
    ]
  }

  function test_qmlTypeof (data) {
    var object = Qt.createQmlObject(data.component, testCase)
    verify(object)

    compare(Utils.qmlTypeof(object, data.type), data.result)
  }

  // ---------------------------------------------------------------------------

  function test_setTimeoutWithoutParent () {
    try {
      Utils.setTimeout(null, 0, function () {
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
    Utils.setTimeout(testCase, data.time, function () {
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

  // ===========================================================================
  // GENERIC.
  // ===========================================================================

  function test_ensureArray_data () {
    return [
      { input: [ 1, 2, 3 ], output: [ 1, 2, 3 ] },
      { input: { toto: 4, ro: 5 }, output: [ 4, 5 ] },
      { input: new Object(), output: [] },
      { input: new Array(), output: [] },
      { input: { a: 0, b: 1, c: 0 }, output: [ 0, 1, 0 ] }
    ]
  }

  function test_ensureArray (data) {
    // Use `sort` because transform a object in array hasn't a
    // guarantee ordering.
    compare(Utils.ensureArray(data.input).sort(), data.output.sort())
  }

  // ---------------------------------------------------------------------------

  function test_execAll_data () {
    return [
      {
        cb: function () {
          return 'failed'
        },
        regex: /x/g,
        text: '',

        output: []
      }, {
        cb: function (c, valid) {
          return !valid && c
        },
        regex: /x/g,
        text: 'n',

        output: [ 'n' ]
      }, {
        cb: function (c, valid) {
          return valid && String.fromCharCode(c.charCodeAt(0) + 1)
        },
        regex: /[a-z]/g,
        text: 'abcdefgh',

        output: [ 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i' ]
      }, {
        cb: function (n, valid) {
          return !valid ? '*' : Math.abs(n)
        },
        regex: /\d+/g,
        text: 'abc 5 def -4 ghi 452-12',

        output: [ '*', 5, '*', 4, '*', 452, '*', 12 ]
      }, {
        regex: /candy-shop/g,
        text: 'candy-hop candy-shop cndy-shop candyshop',

        output: [ 'candy-hop ', 'candy-shop', ' cndy-shop candyshop' ]
      }, {
        cb: function (text, valid) {
          return valid ? text + ' Batman!' : text
        },
        regex: /(?:na)+\.\.\./g,
        text: 'Nananana. Nanananananananana... Nanananananananana... Nananananananananananana...',

        output: [
          'Nananana. Na',
          'nananananananana... Batman!',
          ' Na',
          'nananananananana... Batman!',
          ' Na',
          'nanananananananananana... Batman!'
        ]
      }
    ]
  }

  function test_execAll (data) {
    compare(Utils.execAll(data.regex, data.text, data.cb), data.output)
  }

  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------

  function test_getExtension_data () {
    return [
      { input: 'foobar.baz', output: 'baz' },
      { input: 'classe.george.abitbol', output: 'abitbol' },
      { input: '', output: '' },
      { input: 'cotcotcot', output: '' }
    ]
  }

  function test_getExtension (data) {
    compare(Utils.getExtension(data.input), data.output)
  }

  // ---------------------------------------------------------------------------

  function test_includes_data () {
    return [
      // Test arrays.
      { input: [], value: 0, output: false },
      { input: [ 1, 2, 3 ], value: 4, output: false },
      { input: [ 6 ], value: 6, output: true },
      { input: [ 4, 8, 'foo' ], value: 8, output: true },
      { input: [ 12, NaN, 47 ], value: NaN, output: true },
      { input: Array(1), value: undefined, output: true },
      { input: [ 'a', 'b', 'c' ], startIndex: 1, value: 'a', output: false },
      { input: [ 6, 5, 4, 9 ], startIndex: 3, value: 9, output: true },

      // Test objects.
      { input: {}, value: 0, output: false },
      { input: { a: 1, b: 2, c: 3 }, value: 4, output: false },
      { input: { a: 6 }, value: 6, output: true },
      { input: { a: 4, b: 8, c: 'foo' }, value: 8, output: true },
      { input: { a: 12, b: NaN, c: 47 }, value: NaN, output: true },
      { input: new Object(), value: undefined, output: false },
      { input: { a: 'a', b: 'b', c: 'c' }, startIndex: 1, value: 'a', output: false },
      { input: { a: 6, b: 5, c: 4, d: 9 }, startIndex: 3, value: 9, output: true },
    ]
  }

  function test_includes (data) {
    compare(
      Utils.includes(data.input, data.value, data.startIndex),
      data.output
    )
  }

  // ---------------------------------------------------------------------------

  function test_isArray_data () {
    return [
      { input: [], output: true },
      { input: {}, output: false },
      { input: [ 6 ], output: true },
      { input: /bar/, output: false },
      { input: new Error, output: false },
      { input: true, output: false },
      { input: 42, output: false },
      { input: new Array(), output: true },
      { input: [ 15, new Date(), 'ij' ], output: true }
    ]
  }

  function test_isArray (data) {
    compare(Utils.isArray(data.input), data.output)
  }

  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------

  function test_startsWith_data () {
    return [
      { string: 'foo', searchStr: undefined, result: true },
      { string: 'bar', searchStr: null, result: true },
      { string: 'abitbol', searchStr: 'abitboll', result: false },
      { string: '', searchStr: NaN, result: false },
      { string: '', searchStr: '', result: true },
      { string: '', searchStr: Infinity, result: false },
      { string: '', searchStr: 0, result: false },
      { string: 'george', searchStr: 'geo', result: true },
      { string: 'george', searchStr: 'george', result: true },
      { string: 'george', searchStr: 'georg', result: true },
      { string: 'ruby', searchStr: '', result: true }
    ]
  }

  function test_startsWith (data) {
    compare(
      Utils.startsWith(data.string, data.searchStr),
      data.result
    )
  }

  // ---------------------------------------------------------------------------

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
}
