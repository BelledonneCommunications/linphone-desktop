import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Control.Button {
	id: mainItem
	property int capitalization
	property color color: DefaultStyle.main1_500_main
	property color disabledColor: Qt.darker(color, 1.5)
	property color borderColor: DefaultStyle.grey_0
	readonly property color pressedColor: Qt.darker(color, 1.1)
	property bool inversedColors: false
	property int textSize: 18 * DefaultStyle.dp
	property int textWeight: 600 * DefaultStyle.dp
	property int radius: 48 * DefaultStyle.dp
	property color textColor: DefaultStyle.grey_0
	property bool underline: activeFocus || containsMouse
	property bool shadowEnabled: enabled && (activeFocus  || containsMouse)
	property var contentImageColor
	property alias containsMouse: mouseArea.containsMouse
	hoverEnabled: true
	activeFocusOnTab: true
	// leftPadding: 20 * DefaultStyle.dp
	// rightPadding: 20 * DefaultStyle.dp
	// topPadding: 11 * DefaultStyle.dp
	// bottomPadding: 11 * DefaultStyle.dp

	MouseArea {
		id: mouseArea
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
					? mainItem.pressed || mainItem.shadowEnabled
						? DefaultStyle.grey_100
						: mainItem.borderColor
					: mainItem.pressed || mainItem.shadowEnabled
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
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
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
			bold: mainItem.font.bold
		}
	}

	component ButtonImage: EffectImage {
		// Layout.fillWidth: true
		// Layout.fillHeight: true
		imageSource: mainItem.icon.source
		imageWidth: mainItem.icon.width
		imageHeight: mainItem.icon.height
		colorizationColor: mainItem.contentImageColor
		shadowEnabled: mainItem.shadowEnabled
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
		ButtonImage{}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
