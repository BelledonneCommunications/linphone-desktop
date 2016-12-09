import QtQuick 2.7

import Utils 1.0

// ===================================================================

Item {
  property bool _connected: false

  function connect (emitter, signalName, handler) {
    Utils.assert(!_connected, 'Smart connect is already connected!')

    emitter[signalName].connect(handler)
    _connected = true

    Component.onDestruction.connect(function () {
      emitter[signalName].disconnect(handler)
    })
  }
}
