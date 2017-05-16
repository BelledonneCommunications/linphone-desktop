import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

Switch {
  id: control

  // ---------------------------------------------------------------------------

  property bool enabled: true

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  checked: false

  indicator: Rectangle {
    implicitHeight: SwitchStyle.indicator.height
    implicitWidth: SwitchStyle.indicator.width

    border.color: control.enabled
      ? (
        control.checked
          ? SwitchStyle.indicator.border.color.checked
          : SwitchStyle.indicator.border.color.normal
      ) : SwitchStyle.indicator.border.color.disabled

    color: control.enabled
      ? (
        control.checked
          ? SwitchStyle.indicator.color.checked
          : SwitchStyle.indicator.color.normal
      ) : SwitchStyle.indicator.color.disabled

    radius: SwitchStyle.indicator.radius
    x: control.leftPadding
    y: parent.height / 2 - height / 2

    Rectangle {
      id: sphere

      height: SwitchStyle.sphere.size
      width: SwitchStyle.sphere.size

      anchors.verticalCenter: parent.verticalCenter

      border.color: control.enabled
        ?
          (
          control.checked
            ? (
              control.down
                ? SwitchStyle.sphere.border.color.pressed
                : SwitchStyle.sphere.border.color.checked
            ) : SwitchStyle.sphere.border.color.normal
        ) : SwitchStyle.sphere.border.color.disabled

      color: control.enabled
        ?
          (
          control.down
            ? SwitchStyle.sphere.color.pressed
            : SwitchStyle.sphere.color.normal
        ) : SwitchStyle.sphere.color.disabled

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

          duration: SwitchStyle.animation.duration
          easing.type: Easing.InOutQuad
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  MouseArea {
    anchors.fill: parent

    onClicked: control.enabled && control.clicked()
  }
}
