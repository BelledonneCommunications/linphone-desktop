import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.b1.pixelSize
	textWeight: Typography.b1.weight
    leftPadding: Math.round(20.04 * DefaultStyle.dp)
    rightPadding: Math.round(20.04 * DefaultStyle.dp)
    topPadding: Math.round(11.2 * DefaultStyle.dp)
    bottomPadding: Math.round(11.2 * DefaultStyle.dp)
    icon.width: Math.round(24.89 * DefaultStyle.dp)
    icon.height: Math.round(24.89 * DefaultStyle.dp)
}
