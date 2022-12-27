import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.Switch {
  id: control

  // ---------------------------------------------------------------------------

  property bool enabled: true
  property QtObject indicatorStyle : SwitchStyle.normal
  onIndicatorStyleChanged: if( !indicatorStyle) indicatorStyle = SwitchStyle.normal

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  checked: false

  indicator: Rectangle {
    implicitHeight: indicatorStyle.indicator.height
    implicitWidth: indicatorStyle.indicator.width

    border.color: control.enabled
      ? (
        control.checked
          ? indicatorStyle.indicator.border.color.checked.color
          : indicatorStyle.indicator.border.color.normal.color
      ) : indicatorStyle.indicator.border.color.disabled.color

    color: control.enabled
      ? (
        control.checked
          ? indicatorStyle.indicator.color.checked.color
          : indicatorStyle.indicator.color.normal.color
      ) : indicatorStyle.indicator.color.disabled.color

    radius: indicatorStyle.indicator.radius
    x: control.leftPadding
    y: parent.height / 2 - height / 2

    Rectangle {
      id: sphere

      height: indicatorStyle.sphere.size
      width: indicatorStyle.sphere.size

      anchors.verticalCenter: parent.verticalCenter

      border.color: control.enabled
        ?
          (
          control.checked
            ? (
              control.down
                ? indicatorStyle.sphere.border.color.pressed.color
                : indicatorStyle.sphere.border.color.checked.color
            ) : indicatorStyle.sphere.border.color.normal.color
        ) : indicatorStyle.sphere.border.color.disabled.color

      color: control.enabled
        ?
          (
          control.down
            ? indicatorStyle.sphere.color.pressed.color
            : indicatorStyle.sphere.color.normal.color
        ) : indicatorStyle.sphere.color.disabled.color

      radius: width / 2

      // -----------------------------------------------------------------------

      states: State {
        when: control.checked

        PropertyChanges {
          target: sphere
          x: parent.width - width
        }
      }

      transitions: Transition {
        NumberAnimation {
          properties: 'x'

          duration: indicatorStyle.animation.duration
          easing.type: Easing.InOutQuad
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  MouseArea {
    anchors.fill: parent
    
	onClicked: control.enabled && control.clicked()
    onPressed: control.enabled && control.forceActiveFocus()
  }
}
