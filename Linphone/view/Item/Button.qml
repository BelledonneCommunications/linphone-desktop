import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property color color: DefaultStyle.main1_500_main
	property color pressedColor: DefaultStyle.main1_500_main_darker
	property bool inversedColors: false
	property int textSize: 18 * DefaultStyle.dp
	property int textWeight: 600 * DefaultStyle.dp
	property bool underline: false
	property bool shadowEnabled: false
	hoverEnabled: true

	leftPadding: 20 * DefaultStyle.dp
	rightPadding: 20 * DefaultStyle.dp
	topPadding: 11 * DefaultStyle.dp
	bottomPadding: 11 * DefaultStyle.dp

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		acceptedButtons: Qt.NoButton
	}

	background: Item {
		Rectangle {
			anchors.fill: parent
			id: buttonBackground
			color: inversedColors
					? mainItem.pressed 
						? DefaultStyle.grey_100
						: DefaultStyle.grey_0
					: mainItem.pressed 
						? mainItem.pressedColor
						: mainItem.color
			radius: 48 * DefaultStyle.dp
			border.color: inversedColors ? mainItem.color : DefaultStyle.grey_0

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			}
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: buttonBackground
			source: buttonBackground
			shadowEnabled: mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 1
			shadowOpacity: 0.1
		}
	}

	contentItem: Text {
		id: contentText
		horizontalAlignment: Text.AlignHCenter
		anchors.centerIn: parent
		wrapMode: Text.WordWrap
		text: mainItem.text
		color: inversedColors ? mainItem.color : DefaultStyle.grey_0
		font {
			pixelSize: mainItem.textSize
			weight: mainItem.textWeight
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
			underline: mainItem.underline
		}
	}
}
