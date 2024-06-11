import QtQuick 2.7
import QtQuick.Controls.Basic 2.2 as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Button {
	id: mainItem
	textSize: Typography.b2.pixelSize
	textWeight: Typography.b2.weight
	color: DefaultStyle.main1_100
	textColor: DefaultStyle.main1_500_main
	leftPadding: 16 * DefaultStyle.dp
	rightPadding: 16 * DefaultStyle.dp
	topPadding: 10 * DefaultStyle.dp
	bottomPadding: 10 * DefaultStyle.dp
}
