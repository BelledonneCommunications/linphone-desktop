import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property bool inversedColors: false
	property int textSize: DefaultStyle.buttonTextSize
	property bool boldText: true

	background: Rectangle {
		color: inversedColors 
				? mainItem.pressed 
					? DefaultStyle.buttonPressedInversedBackground
					: DefaultStyle.buttonInversedBackground
				: mainItem.pressed 
					? DefaultStyle.buttonPressedBackground
					: DefaultStyle.buttonBackground
		radius: 24
		border.color: inversedColors ? DefaultStyle.buttonBackground : DefaultStyle.buttonInversedBackground

		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
		}
	}

	leftPadding: 13
	rightPadding: 13
	topPadding: 10
	bottomPadding: 10
	
	contentItem: Text {
		horizontalAlignment: Text.AlignHCenter
		anchors.centerIn: parent
		wrapMode: Text.WordWrap
		text: mainItem.text
		color: inversedColors ? DefaultStyle.buttonInversedTextColor : DefaultStyle.buttonTextColor
		font {
			bold: mainItem.boldText
			pointSize: mainItem.textSize
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
		}
	}
	
	hoverEnabled: true
}
