import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Control.ScrollBar {
	id: mainItem
	padding: 0
	background: Item{}
	contentItem: Rectangle {
		implicitWidth: 6
		radius: 32 * DefaultStyle.dp
		color: "#D9D9D9"
	}
}