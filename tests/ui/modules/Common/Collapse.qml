import QtQuick 2.7

import Common.Styles 1.0

// ===================================================================
// A simple component to build collapsed item.
// ===================================================================

Item {
  id: collapse

  property alias target: targetChanges.target
  property int targetHeight

  property bool _collapsed: false

  signal collapsed (bool collapsed)

  // -----------------------------------------------------------------

  function isCollapsed () {
    return _collapsed
  }

  // -----------------------------------------------------------------

  ActionButton {
    id: button

    anchors.centerIn: parent
    background: CollapseStyle.background
    icon: 'collapse'
    iconSize: CollapseStyle.iconSize

    onClicked: _collapsed = !_collapsed
  }

  // -----------------------------------------------------------------

  states: State {
    name: 'collapsed'
    when: _collapsed

    PropertyChanges {
      rotation: 180
      target: button
    }

    PropertyChanges {
      id: targetChanges

      height: collapse.targetHeight
      maximumHeight: 99999
      maximumWidth: 99999
      minimumHeight: collapse.targetHeight
    }
  }

  transitions: Transition {
    RotationAnimation {
      direction: RotationAnimation.Clockwise
      duration: CollapseStyle.animationDuration
      property: 'rotation'
      target: button
    }

    SequentialAnimation {
      PauseAnimation {
        duration: CollapseStyle.animationDuration
      }

      ScriptAction {
        script: collapsed(_collapsed)
      }
    }
  }
}
