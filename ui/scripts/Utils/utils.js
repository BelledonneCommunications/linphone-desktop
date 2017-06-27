// =============================================================================
// Contains many common helpers.
// =============================================================================

.pragma library

.import QtQuick 2.7 as QtQuick

.import 'port-tools.js' as PortTools
.import 'uri-tools.js' as UriTools

// =============================================================================
// Constants.
// =============================================================================

var PORT_REGEX = PortTools.PORT_REGEX
var PORT_RANGE_REGEX = PortTools.PORT_RANGE_REGEX

// =============================================================================
// QML helpers.
// =============================================================================

function buildDialogUri (component) {
  return 'qrc:/ui/modules/Common/Dialog/' + component + '.qml'
}

// -----------------------------------------------------------------------------

// Destroy timeout.
function clearTimeout (timer) {
  timer.stop() // NECESSARY.
  timer.destroy()
}

// -----------------------------------------------------------------------------

function createObject (source, parent, options) {
  if (options && options.isString) {
    var object = Qt.createQmlObject(source, parent)

    var properties = options && options.properties
    if (properties) {
      for (var key in properties) {
        object[key] = properties[key]
      }
    }

    return object
  }

  var component = Qt.createComponent(source)
  if (component.status !== QtQuick.Component.Ready) {
    console.debug('Component not ready.')
    if (component.status === QtQuick.Component.Error) {
      console.debug('Error: ' + component.errorString())
    }
    return // Error.
  }

  var object = component.createObject(parent, (options && options.properties) || {})
  if (!object) {
    console.debug('Error: unable to create dynamic object.')
  }

  return object
}

// -----------------------------------------------------------------------------

function encodeTextToQmlRichFormat (text, options) {
  var images = ''

  if (!options) {
    options = {}
  }

  var formattedText = execAll(UriTools.URI_REGEX, text, function (str, valid) {
    if (!valid) {
      return unscapeHtml(str)
    }

    var uri = startsWith(str, 'www.') ? 'http://' + str : str

    var ext = getExtension(str)
    if (includes([ 'jpg', 'jpeg', 'gif', 'png', 'svg' ], ext)) {
      images += '<a href="' + uri + '"><img' + (
        options.imagesWidth != null
          ? ' width="' + options.imagesWidth + '"'
          : ''
      ) + (
        options.imagesHeight != null
        ? ' height="' + options.imagesHeight + '"'
        : ''
      ) + ' src="' + str + '" /></a>'
    }

    return '<a href="' + uri + '">' + unscapeHtml(str) + '</a>'
  }).join('')
  if (images.length > 0) {
    images = '<div>' + images + '</div>'
  }

  return images.concat('<p style="white-space:pre-wrap;">' + formattedText + '</p>')
}

function extractFirstUri (str) {
  var res = str.match(UriTools.URI_REGEX)
  return res == null || startsWith(res[0], 'www')
    ? undefined
    : res[0]
}

// -----------------------------------------------------------------------------

// Load by default a window in the ui/views folder.
// If options.isString is equals to true, a marshalling component can
// be used.
//
// Supported options: isString, exitHandler, properties.
//
// If exitHandler is used, window must implement exitStatus signal.
function openWindow (window, parent, options) {
  var object = createObject(window, parent, options)

  object.closing.connect(object.destroy.bind(object))

  if (options && options.exitHandler) {
    object.exitStatus.connect(
      // Bind to access parent properties.
      options.exitHandler.bind(parent)
    )
  }

  object.show()

  return object
}

// -----------------------------------------------------------------------------

function getSystemPathFromUri (uri) {
  var str = uri.toString()
  if (startsWith(str, 'file://')) {
    str = str.substring(7)

    // Absolute path.
    if (str.charAt(0) === '/') {
      return runOnWindows() ? str.substring(1) : str
    }
  }

  return str
}

function getUriFromSystemPath (path) {
  if (path.startsWith('file://')) {
    return path
  }

  if (runOnWindows()) {
    return 'file://' + (/^\w:/.exec(path) ? '/' : '') + path
  }

  return 'file://' + path
}

// -----------------------------------------------------------------------------

// Returns the top (root) parent of one object.
function getTopParent (object, useFakeParent) {
  function _getTopParent (object, useFakeParent) {
    return (useFakeParent && object.$parent) || object.parent
  }

  var parent = _getTopParent(object, useFakeParent)
  var p
  while ((p = _getTopParent(parent, useFakeParent)) != null) {
    parent = p
  }

  return parent
}

// -----------------------------------------------------------------------------

function runOnWindows () {
  var os = Qt.platform.os
  return os === 'windows' || os === 'winrt'
}

// -----------------------------------------------------------------------------

// Test if a point is in a item.
//
// `source` is the item that generated the point.
// `target` is the item to test.
// `point` is the point to test.
function pointIsInItem (source, target, point) {
  point = source.mapToItem(target.parent, point.x, point.y)

  return (
    point.x >= target.x &&
    point.y >= target.y &&
    point.x < target.x + target.width &&
    point.y < target.y + target.height
  )
}

// -----------------------------------------------------------------------------

// Test the type of a qml object.
// Warning: this function is probably not portable
// on new versions of Qt.
//
// So, if you want to use it on a specific `className`, please to add
// a test in `test_qmlTypeof_data` of `utils.spec.qml`.
function qmlTypeof (object, className) {
  var str = object.toString()

  return (
    str.indexOf(className + '(') == 0 ||
    str.indexOf(className + '_QML') == 0
  )
}

// -----------------------------------------------------------------------------

// A copy of `Window.setTimeout` from js.
// delay is in milliseconds.
function setTimeout (parent, delay, cb) {
  var timer = new (function (parent) {
    return Qt.createQmlObject('import QtQuick 2.7; Timer { }', parent)
  })(parent)

  timer.interval = delay
  timer.repeat = false
  timer.triggered.connect(cb)
  timer.start()

  return timer
}

// =============================================================================
// GENERIC.
// =============================================================================

function _computeOptimizedCb (func, context) {
  return context
    ? (function () {
      return func.apply(context, arguments)
    }) : func
}

function _indexFinder (array, cb, context) {
  var length = array.length

  for (var i = 0; i < length; i++) {
    if (cb(array[i], i, array)) {
      return i
    }
  }

  return -1
}

function _keyFinder (obj, cb, context) {
  var keys = Object.keys(obj)
  var length = keys.length

  for (var i = 0; i < length; i++) {
    var key = keys[i]
    if (cb(obj[key], key, obj)) {
      return key
    }
  }
}

// -----------------------------------------------------------------------------

// Basic assert function.
function assert (condition, message) {
  if (!condition) {
    throw new Error('Assert: ' + message)
  }
}

// -----------------------------------------------------------------------------

function basename (str) {
  if (!str) {
    return ''
  }

  if (runOnWindows()) {
    str = str.replace(/\\/g, '/')
  }

  var str2 = str
  var length = str2.length - 1

  if (str2[length] === '/') {
    str2 = str2.substring(0, length)
  }

  return str2.slice(str2.lastIndexOf('/') + 1)
}

// -----------------------------------------------------------------------------

function capitalizeFirstLetter (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

// -----------------------------------------------------------------------------

function dirname (str) {
  if (!str) {
    return ''
  }

  if (runOnWindows()) {
    str = str.replace(/\\/g, '/')
  }

  var str2 = str
  var length = str2.length - 1

  if (str2[length] === '/') {
    str2 = str2.substring(0, length)
  }

  return str2.slice(0, str2.lastIndexOf('/') + 1)
}

// -----------------------------------------------------------------------------

function execAll (regex, text, cb) {
  var index = 0
  var arr = []
  var match

  if (!cb) {
    cb = function (text) {
      return text
    }
  }

  while ((match = regex.exec(text))) {
    var curIndex = match.index
    var matchStr = match[0]

    if (curIndex > index) {
      arr.push(cb(text.substring(index, curIndex), false))
    }

    arr.push(cb(matchStr, true))

    index = curIndex + matchStr.length
  }

  var length = text.length
  if (index < length) {
    arr.push(cb(text.substring(index, length)))
  }

  return arr
}

// -----------------------------------------------------------------------------

function extractProperties (obj, pattern) {
  if (!pattern) {
    return {}
  }

  var obj2 = {}
  pattern.forEach(function (property) {
    obj2[property] = obj[property]
  })

  return obj2
}

// -----------------------------------------------------------------------------

// Returns an array from an `object` or `array` argument.
function ensureArray (obj) {
  if (isArray(obj)) {
    return obj
  }

  var keys = Object.keys(obj)
  var length = keys.length
  var values = Array(length)

  for (var i = 0; i < length; i++) {
    values[i] = obj[keys[i]]
  }

  return values
}

// -----------------------------------------------------------------------------

function escapeQuotes (str) {
  return str != null
    ? str.replace(/([^'\\]*(?:\\.[^'\\]*)*)'/g, '$1\\\'')
    : ''
}

// -----------------------------------------------------------------------------

// Get the first matching value in a array or object.
// The matching value is obtained if `cb` returns true.
function find (obj, cb, context) {
  cb = _computeOptimizedCb(cb, context)

  var finder = isArray(obj) ? _indexFinder : _keyFinder
  var key = finder(obj, cb, context)

  return key != null && key !== -1 ? obj[key] : null
}

// -----------------------------------------------------------------------------

function findIndex (array, cb, context) {
  cb = _computeOptimizedCb(cb, context)

  var key = _indexFinder(array, cb, context)
  return key != null && key !== -1 ? key : null
}

// -----------------------------------------------------------------------------

function formatElapsedTime (seconds) {
  seconds = parseInt(seconds, 10)

  var h = Math.floor(seconds / 3600)
  var m = Math.floor((seconds - h * 3600) / 60)
  var s = seconds - h * 3600 - m * 60

  if (h < 10 && h > 0) {
    h = '0' + h
  }

  if (m < 10) {
    m = '0' + m
  }

  if (s < 10) {
    s = '0' + s
  }

  return (h === 0 ? '' : h + ':') + m + ':' + s
}

// -----------------------------------------------------------------------------

function formatSize (size) {
  var units = ['KB', 'MB', 'GB', 'TB']
  var unit = 'B'

  if (size == null) {
    size = 0
  }

  var length = units.length
  for (var i = 0; size >= 1024 && i < length; i++) {
    unit = units[i]
    size /= 1024
  }

  return parseFloat(size.toFixed(2)) + unit
}

// -----------------------------------------------------------------------------

// Generate a random number in the [min, max[ interval.
// Uniform distrib.
function genRandomNumber (min, max) {
  return Math.random() * (max - min) + min
}

// -----------------------------------------------------------------------------

// Generate a random number between a set of intervals.
// The `intervals` param must be orderer like this:
// `[ [ 1, 4 ], [ 8, 16 ], [ 22, 25 ] ]`
function genRandomNumberBetweenIntervals (intervals) {
  if (intervals.length === 1) {
    return genRandomNumber(intervals[0][0], intervals[0][1])
  }

  // Compute the intervals size.
  var size = 0
  intervals.forEach(function (interval) {
    size += interval[1] - interval[0]
  })

  // Generate a value in the interval: `[0, size[`
  var n = genRandomNumber(0, size)

  // Map the value in the right interval.
  n += intervals[0][0]
  for (var i = 0; i < intervals.length - 1; i++) {
    if (n < intervals[i][1]) {
      break
    }

    n += intervals[i + 1][0] - intervals[i][1]
  }

  return n
}

// -----------------------------------------------------------------------------

// Returns the extension of a filename.
function getExtension (str) {
  var index = str.lastIndexOf('.')

  if (index === -1) {
    return ''
  }

  return str.slice(index + 1)
}

// -----------------------------------------------------------------------------

// Test if a value is included in an array or object.
function includes (obj, value, startIndex) {
  obj = ensureArray(obj)

  if (startIndex == null) {
    startIndex = 0
  }

  var length = obj.length

  for (var i = startIndex; i < length; i++) {
    if (
      value === obj[i] ||
      // Check `NaN`.
      (value !== value && obj[i] !== obj[i])
    ) {
      return true
    }
  }

  return false
}

// -----------------------------------------------------------------------------

function isArray (array) {
  return (array instanceof Array)
}

// -----------------------------------------------------------------------------

function isFunction (func) {
  return typeof func === 'function'
}

// -----------------------------------------------------------------------------

function isInteger (integer) {
  return integer === parseInt(integer, 10)
}

// -----------------------------------------------------------------------------

function isObject (object) {
  return object !== null && typeof object === 'object'
}

// -----------------------------------------------------------------------------

function isString (string) {
  return typeof string === 'string' || string instanceof String
}

// -----------------------------------------------------------------------------

// Convert a snake_case string to a lowerCamelCase string.
function snakeToCamel (s) {
  return s.replace(/(\_\w)/g, function (matches) {
    return matches[1].toUpperCase()
  })
}

// -----------------------------------------------------------------------------

// Test if a string starts by a given string.
function startsWith (str, searchStr) {
  if (searchStr == null) {
    searchStr = ''
  }

  return str.slice(0, searchStr.length) === searchStr
}

// -----------------------------------------------------------------------------

// Invoke a `cb` function with each value of the interval: `[0, n[`.
// Return a mapped array created with the returned values of `cb`.
function times (n, cb, context) {
  var arr = Array(Math.max(0, n))
  cb = _computeOptimizedCb(cb, context, 1)

  for (var i = 0; i < n; i++) {
    arr[i] = cb(i)
  }

  return arr
}

// -----------------------------------------------------------------------------

function unscapeHtml (str) {
  return str.replace(/&/g, '&amp;')
  .replace(/</g, '\u2063&lt;')
  .replace(/>/g, '\u2063&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#039;')
}
