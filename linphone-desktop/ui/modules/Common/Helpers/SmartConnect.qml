import QtQuick 2.7

import Utils 1.0

// =============================================================================

Item {
  property var handlers: ({})

  function connect (emitter, signalName, handler) {
    emitter[signalName].connect(handler)

    if (!handlers[signalName]) {
      handlers[signalName] = []
    }

    handlers[signalName].push([emitter, handler])
  }

  Component.onDestruction: {
    for (var signalName in handlers) {
      handlers[signalName].forEach(function (value) {
        var component = value[0][signalName]

        if (component) {
          component.disconnect(value[1])
        }
      })
    }
  }
}
