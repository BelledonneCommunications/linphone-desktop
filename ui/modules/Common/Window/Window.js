// =============================================================================
// Windows (qml) Logic.
// =============================================================================

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

// Create a dynamic component hover the main content of one window.
// The object parameter must have a `exitStatus` signal which is used
// at item destruction.
//
// The exit status handler is optional.
function attachVirtualWindow (component, properties, exitStatusHandler) {
  if (virtualWindow.visible) {
    return
  }

  var object = Utils.createObject(component, null, {
    properties: properties
  })

  if (exitStatusHandler) {
    object.exitStatus.connect(exitStatusHandler)
  }
  object.exitStatus.connect(detachVirtualWindow)

  virtualWindow.setContent(object)

  window.attachedVirtualWindow()
}

function detachVirtualWindow () {
  var object = virtualWindow.unsetContent()
  if (object) {
    object.destroy()
    window.detachedVirtualWindow()
  }
}
