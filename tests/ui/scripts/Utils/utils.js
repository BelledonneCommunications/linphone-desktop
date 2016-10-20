// ===================================================================
// Contains many common helpers.
// ===================================================================

// Load by default a window in the ui/views folder.
// If options.isString is equals to true, a marshalling component can
// be used.
//
// Supported options: isString, exitHandler.
//
// If exitHandler is used, window must implement exitStatus signal.
function openWindow (window, parent, options) {
  var object

  if (options && options.isString) {
    object = Qt.createQmlObject(window, parent)
  } else {
    var component = Qt.createComponent(
      'qrc:/ui/views/' + window + '.qml'
    )

    if (component.status !== Component.Ready) {
      console.debug('Window not ready.')
      if (component.status === Component.Error) {
        console.debug('Error:' + component.errorString())
      }
      return // Error.
    }

    object = component.createObject(parent)
  }

  console.debug('Open window.')

  object.closing.connect(function () {
    console.debug('Destroy window.')
    object.destroy()
  })
  object.exitStatus.connect(function (status) {
    console.debug('Exit status: ' + status)
  })

  if (options && options.exitHandler) {
    object.exitStatus.connect(
      // Bind to access parent properties.
      options.exitHandler.bind(parent)
    )
  }

  object.show()

  return object
}

// Display a simple ConfirmDialog component.
// Wrap the openWindow function.
function openConfirmDialog (parent, options) {
  return openWindow(
    'import QtQuick 2.7;' +
      'import Common 1.0;' +
      'ConfirmDialog {' +
      'descriptionText: \'' + options.descriptionText + '\';' +
      'title: \'' + options.title + '\'' +
      '}',
    parent, {
      isString: true,
      exitHandler: options.exitHandler
    }
  )
}

// -------------------------------------------------------------------

function _computeOptimizedCb (func, context) {
  return (context != null)
    ? (function () {
      return func.apply(context, arguments)
    }) : func
}

// -------------------------------------------------------------------

// Convert a snake_case string to a lowerCamelCase string.
function snakeToCamel (s) {
  return s.replace(/(\_\w)/g, function (matches) {
    return matches[1].toUpperCase()
  })
}

// -------------------------------------------------------------------

// A copy of `Window.setTimeout` from js.
// Use setTimeout.call(parentContext, delayTime, cb) to use it.
//
// delay is in milliseconds.
function setTimeout (delay, cb) {
  var timer = new (function (parent) {
    return Qt.createQmlObject('import QtQuick 2.7; Timer { }', parent)
  })(this)

  timer.interval = delay
  timer.repeat = false
  timer.triggered.connect(cb)
  timer.start()

  return timer
}

// Destroy timeout.
function clearTimeout (timer) {
  timer.stop() // NECESSARY.
  timer.destroy()
}

// -------------------------------------------------------------------

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

// -------------------------------------------------------------------

// Test if a var is a string.
function isString (string) {
  return typeof string === 'string' || string instanceof String
}
