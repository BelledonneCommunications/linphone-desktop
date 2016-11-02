import QtQuick 2.7

import Common 1.0
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

  implicitHeight: button.iconSize
  implicitWidth: button.iconSize

  ActionButton {
    id: button

    anchors.centerIn: parent
    icon: 'collapse'
    iconSize: CollapseStyle.iconSize
    useStates: false

    onClicked: _collapsed = !_collapsed
  }

  // -----------------------------------------------------------------

  states: State {
    when: _collapsed

    PropertyChanges {
      rotation: 180
      target: button
    }

    PropertyChanges {
      id: targetChanges

      height: collapse.targetHeight
      maximumHeight: Constants.sizeMax
      maximumWidth: Constants.sizeMax
      minimumHeight: collapse.targetHeight
    }
  }

  transitions: Transition {
    SequentialAnimation {
      RotationAnimation {
        direction: RotationAnimation.Clockwise
        duration: CollapseStyle.animationDuration
        property: 'rotation'
        target: button
      }

      ScriptAction {
        script: collapsed(_collapsed)
      }
    }
  }
}
