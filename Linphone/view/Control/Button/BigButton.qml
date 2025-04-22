import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.b1.pixelSize
	textWeight: Typography.b1.weight
    leftPadding: Math.round(20 * DefaultStyle.dp)
    rightPadding: Math.round(20 * DefaultStyle.dp)
    topPadding: Math.round(11 * DefaultStyle.dp)
    bottomPadding: Math.round(11 * DefaultStyle.dp)
    icon.width: Math.round(24 * DefaultStyle.dp)
    icon.height: Math.round(24 * DefaultStyle.dp)
}
