import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone

Control.TabBar {
	id: mainItem
	spacing: 32 * DefaultStyle.dp
	topPadding: 36 * DefaultStyle.dp

	property var model
	readonly property alias cornerRadius: bottomLeftCorner.radius
	
	contentItem: ListView {
		model: mainItem.contentModel
		currentIndex: mainItem.currentIndex

		spacing: mainItem.spacing
		orientation: ListView.Vertical
		// boundsBehavior: Flickable.StopAtBounds
		flickableDirection: Flickable.AutoFlickIfNeeded
		// snapMode: ListView.SnapToItem

		// highlightMoveDuration: 0
		// highlightRangeMode: ListView.ApplyRange
		// preferredHighlightBegin: 40
		// preferredHighlightEnd: width - 40
	}

	background: Item {
		id: background
		anchors.fill: parent
		Rectangle {
			id: bottomLeftCorner
			anchors.fill: parent
			color: DefaultStyle.main1_500_main
			radius: 25 * DefaultStyle.dp
		}
		Rectangle {
			color: DefaultStyle.main1_500_main
			anchors.left: parent.left
			anchors.top: parent.top
			width: parent.width/2
			height: parent.height/2
		}
		Rectangle {
			color: DefaultStyle.main1_500_main
			x: parent.x + parent.width/2
			y: parent.y + parent.height/2
			width: parent.width/2
			height: parent.height/2
		}
	}

	Repeater {
		id: actionsRepeater
		model: mainItem.model
		Control.TabButton {
			id: tabButton
			width: mainItem.width

			contentItem: ColumnLayout {
				// height: tabButton.height
				// width: tabButton.width
				EffectImage {
					id: buttonIcon
					property int buttonSize: 24 * DefaultStyle.dp
					imageSource: mainItem.currentIndex === index ? modelData.selectedIcon : modelData.icon
					Layout.preferredWidth: buttonSize
					Layout.preferredHeight: buttonSize
					Layout.alignment: Qt.AlignHCenter
					fillMode: Image.PreserveAspectFit
					colorizationColor: DefaultStyle.grey_0
				}
				Text {
					id: buttonText
					text: modelData.label
					font {
						weight: mainItem.currentIndex === index ? 800 * DefaultStyle.dp : 400 * DefaultStyle.dp
						pixelSize: 9 * DefaultStyle.dp
					}
					color: DefaultStyle.grey_0
					Layout.fillWidth: true
					Layout.preferredHeight: txtMeter.height
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					leftPadding: 3 * DefaultStyle.dp
					rightPadding: 3 * DefaultStyle.dp
				}
			}
			TextMetrics {
				id: txtMeter
				text: modelData.label
				font: buttonText.font
				Component.onCompleted: {
					font.weight = 800 * DefaultStyle.dp
					mainItem.implicitWidth = Math.max(mainItem.implicitWidth, advanceWidth + buttonIcon.buttonSize)
				}
			}

			background: Item {
			}
		}
	}
}
