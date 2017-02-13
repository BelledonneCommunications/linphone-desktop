import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

Switch {
  id: control

  checked: false

  indicator: Rectangle {
    implicitHeight: SwitchStyle.indicator.height
    implicitWidth: SwitchStyle.indicator.width

    border.color: control.checked
      ? SwitchStyle.indicator.border.color.checked
      : SwitchStyle.indicator.border.color.normal

    color: control.checked
      ? SwitchStyle.indicator.color.checked
      : SwitchStyle.indicator.color.normal

    radius: SwitchStyle.indicator.radius
    x: control.leftPadding
    y: parent.height / 2 - height / 2

    Rectangle {
      id: sphere

      height: SwitchStyle.sphere.size
      width: SwitchStyle.sphere.size

      anchors.verticalCenter: parent.verticalCenter
      border.color: control.checked
        ? (control.down
          ? SwitchStyle.sphere.border.color.pressed
          : SwitchStyle.sphere.border.color.checked
        ) : SwitchStyle.sphere.border.color.normal

      color: control.down
        ? SwitchStyle.sphere.color.pressed
        : SwitchStyle.sphere.color.normal

      radius: width / 2
      x: control.checked ? parent.width - width : 0

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

          duration: SwitchStyle.animation.duration
          easing.type: Easing.InOutQuad
        }
      }
    }
  }
}
