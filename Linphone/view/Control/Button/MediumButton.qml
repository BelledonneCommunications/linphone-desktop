import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.b2.pixelSize
	textWeight: Typography.b2.weight
    leftPadding: Math.round(16 * DefaultStyle.dp)
    rightPadding: Math.round(16 * DefaultStyle.dp)
    topPadding: Math.round(10 * DefaultStyle.dp)
    bottomPadding: Math.round(10 * DefaultStyle.dp)
    icon.width: Math.round(16 * DefaultStyle.dp)
    icon.height: Math.round(16 * DefaultStyle.dp)
}
