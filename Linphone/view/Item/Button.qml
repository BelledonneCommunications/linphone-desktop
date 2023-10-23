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
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		leftPadding: 11
		rightPadding: 11
		topPadding: 6
		bottomPadding: 6

		wrapMode: Text.WordWrap
		text: mainItem.text
		color: inversedColors ? DefaultStyle.buttonInversedTextColor : DefaultStyle.buttonTextColor
		font {
			bold: true
			pointSize: mainItem.textSize
			capitalization: mainItem.capitalization
		}
	}
	
	hoverEnabled: true
}
