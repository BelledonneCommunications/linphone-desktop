import QtQuick 2.7
import QtQuick.Controls 2.1 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.Menu {
  id: menu

  background: Rectangle {
    implicitWidth: MenuStyle.width
    color: MenuStyle.color

    layer {
      enabled: true
      effect: PopupShadow {}
    }
  }
}
