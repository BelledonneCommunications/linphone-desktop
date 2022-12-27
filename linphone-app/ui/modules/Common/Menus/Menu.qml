import QtQuick 2.7
import QtQuick.Controls 2.3 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.Menu {
	id: menu
	property var menuStyle : MenuStyle.normal
	width: menuStyle.width ? menuStyle.width : parent.width
	background: Rectangle {
		implicitWidth: menu.width
		color: menuStyle.colorModel.color
		radius: menuStyle.radius
		
		border{
			color:menuStyle.border.colorModel.color
			width: menuStyle.border.width
		}
		
		layer {
			enabled: menuStyle.shadowEnabled
			effect: PopupShadow {}
		}    
	}
}
