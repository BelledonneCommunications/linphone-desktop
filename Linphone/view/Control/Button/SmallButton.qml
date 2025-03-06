import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

Button {
	id: mainItem
	textSize: Typography.b3.pixelSize
	textWeight: Typography.b3.weight
    leftPadding: Math.round(12 * DefaultStyle.dp)
    rightPadding: Math.round(12 * DefaultStyle.dp)
    topPadding: Math.round(6 * DefaultStyle.dp)
    bottomPadding: Math.round(6 * DefaultStyle.dp)
    icon.height: Math.round(14 * DefaultStyle.dp)
    icon.width: Math.round(14 * DefaultStyle.dp)
}
