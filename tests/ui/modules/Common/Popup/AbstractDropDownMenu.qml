import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// ===================================================================
// Low component to display a list/menu in a popup.
// ===================================================================

Item {
  id: menu

  // Optionnal parameter, if defined and if a click is detected
  // on it, menu is not closed.
  property var launcher

  // Optionnal parameters, set the position of Menu relative
  // to this item.
  property var relativeTo
  property int relativeX: 0
  property int relativeY: 0

  default property alias _content: content.data
  property bool _isOpen: false

  signal menuClosed
  signal menuOpened

  // -----------------------------------------------------------------

  function isOpen () {
    return _isOpen
  }

  function showMenu () {
    if (_isOpen) {
      return
    }

    if (relativeTo != null) {
      this.x = relativeTo.mapToItem(null, relativeX, relativeY).x
      this.y = relativeTo.mapToItem(null, relativeX, relativeY).y
    }

    _isOpen = true
  }

  function hideMenu () {
    if (!_isOpen) {
      return
    }

    _isOpen = false
  }

  function _computeHeight () {
    console.exception('Virtual method must be implemented.')
  }

  // -----------------------------------------------------------------

  implicitHeight: _computeHeight()
  opacity: 0
  visible: false
  z: Constants.zPopup

  Keys.onEscapePressed: hideMenu()

  // Set parent menu to root.
  Component.onCompleted: {
    if (relativeTo != null) {
      parent = Utils.getTopParent(this)
    }
  }

  // Block clicks, wheel... below menu.
  MouseArea {
    anchors.fill: content
    hoverEnabled: true
    onWheel: {}
  }

  // Menu content.
  Rectangle {
    id: content

    anchors.fill: parent
    color: PopupStyle.backgroundColor

    layer {
      enabled: true
      effect: PopupShadow {}
    }
  }

  // Inverted mouse area to detect click outside menu.
  InvertedMouseArea {
    anchors.fill: parent
    enabled: parent.visible

    onPressed: {
      if (launcher != null && pointIsInItem(launcher)) {
        return
      }
      hideMenu()
    }
  }

  // -----------------------------------------------------------------

  states: State {
    name: 'opened'
    when: _isOpen

    PropertyChanges {
      focus: true // Necessary to use `Keys.onEscapePressed`.
      opacity: 1.0
      target: menu
    }
  }

  transitions: [
    Transition {
      from: ''
      to: 'opened'

      ScriptAction {
        script: menu.visible = true
      }

      NumberAnimation {
        duration: PopupStyle.animation.openingDuration
        easing.type: Easing.InOutQuad
        property: 'opacity'
        target: menu
      }

      SequentialAnimation {
        PauseAnimation {
          duration: PopupStyle.animation.openingDuration
        }

        ScriptAction {
          script: menuOpened()
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      NumberAnimation {
        duration: PopupStyle.animation.closingDuration
        easing.type: Easing.InOutQuad
        property: 'opacity'
        target: menu
      }

      SequentialAnimation {
        PauseAnimation {
          duration: PopupStyle.animation.closingDuration
        }

        ScriptAction {
          script: {
            visible = false
            menuClosed()
          }
        }
      }
    }
  ]
}
