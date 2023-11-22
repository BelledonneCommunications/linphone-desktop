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
						: DefaultStyle.grey_0
					: mainItem.pressed 
						? DefaultStyle.buttonPressedBackground
						: DefaultStyle.main1_500_main
			radius: 24
			border.color: inversedColors ? DefaultStyle.main1_500_main : DefaultStyle.grey_0

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

	contentItem: Text {
		horizontalAlignment: Text.AlignHCenter
		anchors.centerIn: parent
		wrapMode: Text.WordWrap
		text: mainItem.text
		color: inversedColors ? DefaultStyle.main1_500_main : DefaultStyle.grey_0
		font {
			bold: mainItem.boldText
			pointSize: mainItem.textSize
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
		}
	}
}
