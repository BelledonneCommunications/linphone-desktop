import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================
// A simple component to build collapsed item.
// =============================================================================

Item {
  id: collapse

  // ---------------------------------------------------------------------------

  property var target
  property int targetHeight
  readonly property alias isCollapsed: collapse._collapsed

  property bool _collapsed: false
  property var _savedHeight

  // ---------------------------------------------------------------------------

  signal collapsed (bool collapsed)

  // ---------------------------------------------------------------------------

  function setCollapsed (status) {
    if (_collapsed === status) {
      return
    }

    _collapsed = status

    // Warning: Unable to use `PropertyChanges` because the change order is unknown.
    // It exists a bug on Ubuntu if the `height` property is changed before `minimumHeight`.
    if (_collapsed) {
      _savedHeight = Utils.extractProperties(target, [
        'height',
        'maximumHeight',
        'minimumHeight'
      ])

      target.minimumHeight = collapse.targetHeight
      target.maximumHeight = Constants.sizeMax
      target.height = collapse.targetHeight
    } else {
      target.minimumHeight = _savedHeight.minimumHeight
      target.maximumHeight = _savedHeight.maximumHeight
      target.height = _savedHeight.height
    }
  }

  // ---------------------------------------------------------------------------

  implicitHeight: button.iconSize
  implicitWidth: button.iconSize

  property int savedHeight

  ActionButton {
    id: button

    anchors.centerIn: parent
    icon: 'collapse'
    iconSize: CollapseStyle.iconSize
    useStates: false

    onClicked: setCollapsed(!_collapsed)
  }

  // ---------------------------------------------------------------------------

  states: State {
    when: _collapsed

    PropertyChanges {
      rotation: 180
      target: button
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
