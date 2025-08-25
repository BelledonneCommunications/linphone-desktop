import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.p1s.pixelSize
	textWeight: Typography.p1s.weight
    padding: Math.round(16 * DefaultStyle.dp)
    // icon.width: width
    // icon.height: width
    radius: width * 2
    // width: Math.round(24 * DefaultStyle.dp)
    height: width
}
