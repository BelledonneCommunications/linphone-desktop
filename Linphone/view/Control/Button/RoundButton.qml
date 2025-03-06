import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.p1s.pixelSize
	textWeight: Typography.p1s.weight
    topPadding: Math.round(16 * DefaultStyle.dp)
    bottomPadding: Math.round(16 * DefaultStyle.dp)
    leftPadding: Math.round(16 * DefaultStyle.dp)
    rightPadding: Math.round(16 * DefaultStyle.dp)
    icon.width: Math.round(24 * DefaultStyle.dp)
    icon.height: Math.round(24 * DefaultStyle.dp)
    radius: Math.round(40 * DefaultStyle.dp)
    width: Math.round(24 * DefaultStyle.dp)
    height: Math.round(24 * DefaultStyle.dp)
}
