import QtQuick 2.7
import QtQuick.Layouts
import Linphone

RowLayout {
	id: mainItem
	property alias textItem: innerItem
	property double scaleLettersFactor: 1.
	Text {
		id: innerItem
		font.family: DefaultStyle.defaultFont
		font.pointSize: DefaultStyle.defaultFontPointSize
		color: DefaultStyle.defaultTextColor
		wrapMode: Text.Wrap
		elide: Text.ElideRight
		transformOrigin: Item.TopLeft
		transform: Scale { 
			yScale: mainItem.scaleLettersFactor
		}
	}
}