import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property color color: DefaultStyle.main1_500_main
	property color disabledColor: DefaultStyle.main1_500_main_darker
	property color borderColor: "transparent"
	property color pressedColor: DefaultStyle.main1_500_main_darker
	property bool inversedColors: false
	property int textSize: 18 * DefaultStyle.dp
	property int textWeight: 600 * DefaultStyle.dp
	property int radius: 48 * DefaultStyle.dp
	property color textColor: DefaultStyle.grey_0
	property bool underline: false
	property bool shadowEnabled: false
	property var contentImageColor
	hoverEnabled: true

	// leftPadding: 20 * DefaultStyle.dp
	// rightPadding: 20 * DefaultStyle.dp
	// topPadding: 11 * DefaultStyle.dp
	// bottomPadding: 11 * DefaultStyle.dp

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
			color: mainItem.enabled
				? inversedColors
					? mainItem.pressed 
						? DefaultStyle.grey_100
						: DefaultStyle.grey_0
					: mainItem.pressed 
						? mainItem.pressedColor
						: mainItem.color
				: mainItem.disabledColor
			radius: mainItem.radius
			border.color: inversedColors ? mainItem.color : mainItem.borderColor

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

	component ButtonText: Text {
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		width: mainItem.text != undefined ? implicitWidth : 0
		height: implicitHeight
		wrapMode: Text.WrapAnywhere
		// Layout.fillWidth: true
		// Layout.fillHeight: true
		text: mainItem.text
		maximumLineCount: 1
		color: inversedColors ? mainItem.color : mainItem.textColor
		font {
			pixelSize: mainItem.textSize
			weight: mainItem.textWeight
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
			underline: mainItem.underline
		}
	}

	component ButtonImage: EffectImage {
		// Layout.fillWidth: true
		// Layout.fillHeight: true
		imageSource: mainItem.icon.source
		imageWidth: mainItem.icon.width
		imageHeight: mainItem.icon.height
		colorizationColor: mainItem.contentImageColor
	}

	contentItem: StackLayout {
		id: stacklayout
		currentIndex: mainItem.text.length != 0 && mainItem.icon.source.toString().length != 0
			? 0
			: mainItem.text.length != 0
				? 1
				: mainItem.icon.source.toString().length != 0
					? 2
					: 3

		width: mainItem.width
		RowLayout {
			spacing: mainItem.spacing
			ButtonImage{
				Layout.preferredWidth: mainItem.icon.width
				Layout.preferredHeight: mainItem.icon.height
			}
			ButtonText{}
		}
		ButtonText {}
		ButtonImage{
		}
		Item {
			Layout.fillWidth : true
			Layout.fillHeight : true
		}
	}
}
