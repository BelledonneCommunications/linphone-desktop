import QtQuick 2.7
import QtQuick.Window 2.2

import Common.Styles 1.0

// =============================================================================

Item {
  id: wrapper

  // ---------------------------------------------------------------------------

  property alias popupX: window.x
  property alias popupY: window.y
  property bool requestActivate: false
  property int flags: Qt.SplashScreen

  readonly property alias popupWidth: window.width
  readonly property alias popupHeight: window.height

  default property alias _content: content.data
  property bool _isOpen: false

  // ---------------------------------------------------------------------------

  function open () {
    _isOpen = true
  }

  function close () {
    _isOpen = false
  }

  // ---------------------------------------------------------------------------

  // DO NOT TOUCH THESE PROPERTIES.

  // No visible.
  visible: false

  // No size, no position.
  height: 0
  width: 0
  x: 0
  y: 0

  Window {
    id: window

    // Used for internal purposes only. Like Notifications.
    objectName: '__internalWindow'

    flags: wrapper.flags
    opacity: 0
    height: _content[0] != null ? _content[0].height : 0
    width: _content[0] != null ? _content[0].width : 0

    Item {
      id: content

      property var $parent: wrapper
    }
  }

  // ---------------------------------------------------------------------------

  states: State {
    name: 'opened'
    when: _isOpen

    PropertyChanges {
      opacity: 1.0
      target: window
    }
  }

  transitions: [
    Transition {
      from: ''
      to: 'opened'

      ScriptAction {
        script: {
          window.showNormal()

          if (wrapper.requestActivate) {
            window.requestActivate()
          }
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      ScriptAction {
        script: window.hide()
      }
    }
  ]
}
