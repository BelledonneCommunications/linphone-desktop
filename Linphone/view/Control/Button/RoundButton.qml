import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.p1s.pixelSize
	textWeight: Typography.p1s.weight
	topPadding: 16 * DefaultStyle.dp
	bottomPadding: 16 * DefaultStyle.dp
	leftPadding: 16 * DefaultStyle.dp
	rightPadding: 16 * DefaultStyle.dp
	icon.width: 24 * DefaultStyle.dp
	icon.height: 24 * DefaultStyle.dp
	radius: 40 * DefaultStyle.dp
	width: 24 * DefaultStyle.dp
	height: 24 * DefaultStyle.dp
}