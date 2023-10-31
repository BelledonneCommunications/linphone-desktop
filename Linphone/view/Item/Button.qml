import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property bool inversedColors: false
	property int textSize: DefaultStyle.buttonTextSize

	background: Rectangle {
		color: inversedColors ? DefaultStyle.buttonInversedBackground : DefaultStyle.buttonBackground
		radius: 24
		border.color: inversedColors ? DefaultStyle.buttonBackground : DefaultStyle.buttonInversedBackground
	}
	
	contentItem: Text {
		textItem.horizontalAlignment: Text.AlignHCenter
		textItem.verticalAlignment: Text.AlignVCenter
		textItem.leftPadding: 11
		textItem.rightPadding: 11
		textItem.topPadding: 6
		textItem.bottomPadding: 6

		textItem.wrapMode: Text.WordWrap
		textItem.text: mainItem.text
		textItem.color: inversedColors ? DefaultStyle.buttonInversedTextColor : DefaultStyle.buttonTextColor
		textItem.font {
			bold: true
			pointSize: mainItem.textSize
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
		}
	}
	
	hoverEnabled: true
}
