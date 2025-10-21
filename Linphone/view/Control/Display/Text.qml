import QtQuick as Quick
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Quick.Text {
	id: mainItem
	property double scaleLettersFactor: 1.
	width: txtMeter.advanceWidth
	font {
		family: DefaultStyle.defaultFont
        pixelSize: Utils.getSizeWithScreenRatio(10)
        weight: Typography.p1.weight
	}
	color: DefaultStyle.main2_600
	wrapMode: Quick.Text.Wrap
	elide: Quick.Text.ElideRight
	transformOrigin: Quick.Item.TopLeft
	transform: Quick.Scale { 
		yScale: scaleLettersFactor
	}

	Quick.TextMetrics {
		id: txtMeter
		text: mainItem.text
		font: mainItem.font
	}
}
