import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Control.ScrollBar {
	id: mainItem
	padding: 0
    property color color: DefaultStyle.grey_850
	contentItem: Rectangle {
        implicitWidth: Math.round(6 * DefaultStyle.dp)
        radius: Math.round(32 * DefaultStyle.dp)
        color: mainItem.color
	}
}
