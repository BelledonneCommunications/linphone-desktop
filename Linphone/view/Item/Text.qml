import QtQuick 2.7 as Quick
import QtQuick.Layouts
import Linphone

Quick.Text {
	property double scaleLettersFactor: 1.
	width: txtMeter.advanceWidth
	id: innerItem
	// Layout.preferredWidth: mainItem.width
	// width: mainItem.width
	font.family: DefaultStyle.defaultFont
	font.pointSize: DefaultStyle.defaultFontPointSize
	color: DefaultStyle.defaultTextColor
	wrapMode: Quick.Text.Wrap
	elide: Quick.Text.ElideRight
	transformOrigin: Quick.Item.TopLeft
	transform: Quick.Scale { 
		yScale: scaleLettersFactor//mainItem.scaleLettersFactor
	}

	Quick.TextMetrics {
		id: txtMeter
		text: innerItem.text
		font: innerItem.font
	}
}