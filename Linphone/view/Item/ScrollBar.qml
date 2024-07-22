import QtQuick 2.7
import QtQuick.Controls.Basic 2.2 as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Control.ScrollBar {
	id: mainItem
	padding: 0
	background: Item{}
	contentItem: Rectangle {
		implicitWidth: 6 * DefaultStyle.dp
		radius: 32 * DefaultStyle.dp
		// TODO : ask for color names
		color: "#D9D9D9"
	}
}