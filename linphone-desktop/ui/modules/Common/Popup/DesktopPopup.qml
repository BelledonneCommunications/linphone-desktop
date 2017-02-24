import QtQuick 2.7
import QtQuick.Window 2.2

import Common.Styles 1.0

// =============================================================================

Item {
  id: wrapper

  // ---------------------------------------------------------------------------

  property alias popupX: popup.x
  property alias popupY: popup.y
  property bool requestActivate: false
  property int flags: Qt.SplashScreen

  readonly property alias popupWidth: popup.width
  readonly property alias popupHeight: popup.height

  default property alias _content: content.data
  property bool _isOpen: false

  // ---------------------------------------------------------------------------

  function show () {
    _isOpen = true
  }

  function hide () {
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
    id: popup

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
      target: popup
    }
  }

  transitions: [
    Transition {
      from: ''
      to: 'opened'

      ScriptAction {
        script: {
          popup.showNormal()

          if (wrapper.requestActivate) {
            popup.requestActivate()
          }
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      ScriptAction {
        script: {
          popup.hide()
          popup.showMinimized()
        }
      }
    }
  ]
}
