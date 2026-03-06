import QtQuick as Quick
import QtQuick.Controls.Basic as Control
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.ToolTip {
	id: mainItem
	delay: 800
	clip: true
	background: Quick.Rectangle {
		id: tooltipBackground
		opacity: 0.7
		color: DefaultStyle.main2_200
        radius: Utils.getSizeWithScreenRatio(15)
	}
	contentItem: Quick.Text {
		text: mainItem.text
		color: DefaultStyle.main2_600
		width: tooltipBackground.width
		wrapMode: Text.Wrap
		elide: Text.ElideRight
		font {
			family: DefaultStyle.defaultFont
			pixelSize: Utils.getSizeWithScreenRatio(10)
			weight: Typography.p1.weight
		}
	}
}
