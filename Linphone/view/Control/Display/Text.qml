import QtQuick as Quick
import QtQuick.Layouts
import Linphone

Quick.Text {
	id: mainItem
	property double scaleLettersFactor: 1.
	width: txtMeter.advanceWidth
	font {
		family: DefaultStyle.defaultFont
        pixelSize: Math.round(10 * DefaultStyle.dp)
        weight: Typography.p1.weight
		bold: true
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
