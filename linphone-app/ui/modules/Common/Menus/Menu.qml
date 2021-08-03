import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.Menu {
  id: menu
  property var menuStyle : MenuStyle.normal

  background: Rectangle {
    implicitWidth: menuStyle.width
    color: menuStyle.color
    radius: menuStyle.radius
	
	border{
		color:menuStyle.border.color
		width: menuStyle.border.width
	}
	
    layer {
      enabled: menuStyle.shadowEnabled
      effect: PopupShadow {}
    }    
  }
}
