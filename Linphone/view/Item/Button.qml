import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property bool inversedColors: false
	property int textSize: DefaultStyle.buttonTextSize
	property bool boldText: true
	property bool shadowEnabled: false
	hoverEnabled: true

	background: Item {
		Rectangle {
			anchors.fill: parent
			id: buttonBackground
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
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: buttonBackground
			source: buttonBackground
			shadowEnabled: mainItem.shadowEnabled
			shadowColor: "black"//DefaultStyle.numericPadShadowColor
			shadowHorizontalOffset: 1.0
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
}
