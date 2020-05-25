import QtQuick 2.7
import QtQuick.Window 2.2

import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Common.Styles 1.0

// =============================================================================

Item {
  id: wrapper
  objectName: '__internalWrapper'

  // ---------------------------------------------------------------------------

  property alias popupX: windowId.x
  property alias popupY: windowId.y
  property bool requestActivate: false
  property int flags: Qt.SplashScreen

  readonly property alias popupWidth: windowId.width
  readonly property alias popupHeight: windowId.height

  default property alias _content: content.data
  property bool _isOpen: false
  signal isOpened()
  signal isClosed()
  signal dataChanged()

  on_ContentChanged: dataChanged(_content)
  // ---------------------------------------------------------------------------

  function open () {
    _isOpen = true;
    isOpened();
  }

  function close () {
    _isOpen = false
    isClosed()
  }

  // ---------------------------------------------------------------------------

  // No size, no position.
  height: 0
  width: 0
  visible:true

  Window {
    id: windowId
    objectName: '__internalWindow'
    property bool isFrameLess : false;
    // Don't use Popup for flags : it could lead to error in geometry
    flags: Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint | Qt.Window | Qt.FramelessWindowHint;
    opacity: 1.0
    height: _content[0] != null ? _content[0].height : 0
    width: _content[0] != null ? _content[0].width : 0
    visible:true
    Item {
      id: content
      anchors.fill:parent

      property var $parent: wrapper
    }
  }

  // ---------------------------------------------------------------------------

  states: State {
    name: 'opening'
    when: _isOpen

    PropertyChanges {
      opacity: 1.0
      target: windowId
    }
  }

  transitions: [
    Transition {
      from: ''
      to: 'opening'
      ScriptAction {
        script: {
          if (wrapper.requestActivate) {
            windowId.requestActivate()
          }
        }
      }
    },
    Transition {
      from: '*'
      to: ''
      ScriptAction {
        script: windowId.hide()
      }
    }
  ]
}
