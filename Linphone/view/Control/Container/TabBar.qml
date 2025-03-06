import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone
  
Control.TabBar {
	id: mainItem
	property var model
	readonly property int originX: count > 0 
							? itemAt(0).x 
							: 0
    spacing: Math.round(40 * DefaultStyle.dp)
    property real pixelSize: Typography.h3.pixelSize
    property real textWeight: Typography.h3.weight
	wheelEnabled: true
	background: Item {
		id: tabBarBackground
		anchors.fill: parent

		Rectangle {
			id: barBG
            height: Math.round(4 * DefaultStyle.dp)
			color: DefaultStyle.grey_200
			anchors.bottom: parent.bottom
			width: parent.width
		}

		// Rectangle {
		// 	height: 4
		// 	color: DefaultStyle.main1_500_main
		// 	anchors.bottom: parent.bottom
		// 	// anchors.left: mainItem.currentItem.left
		// 	// anchors.right: mainItem.currentItem.right
		// 	x: mainItem.currentItem 
		// 		? mainItem.currentItem.x - mainItem.originX
		// 		: 0
		// 	width: mainItem.currentItem ? mainItem.currentItem.width : 0
		// 	// clip: true
		// 	Behavior on x { NumberAnimation {duration: 100}}
		// 	Behavior on width {NumberAnimation {duration: 100}}
		// }
	}

	Repeater {
		model: mainItem.model
		Control.TabButton {
			id: tabButton
			required property string modelData
			required property int index
			property bool shadowEnabled: activeFocus || hovered
			width: implicitWidth
			activeFocusOnTab: true
			hoverEnabled: true
			ToolTip {
				visible: tabText.truncated && hovered
				delay: 1000
				text: modelData
			}

			background: Item {
				anchors.fill: parent

				Rectangle {
					id: tabBackground
					visible: mainItem.currentIndex === index
                    height: Math.round(5 * DefaultStyle.dp)
					color: DefaultStyle.main1_500_main
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
				}
				MultiEffect {
					enabled: tabButton.shadowEnabled
					anchors.fill: tabBackground
					source: tabBackground
					visible:  tabButton.shadowEnabled
					// Crash : https://bugreports.qt.io/browse/QTBUG-124730
					shadowEnabled: true //mainItem.shadowEnabled
					shadowColor: DefaultStyle.grey_1000
					shadowBlur: 0.1
					shadowOpacity: tabButton.shadowEnabled ? 0.5 : 0.0
				}
			}

			contentItem: Text {
				id: tabText
				width: Math.min(implicitWidth, mainItem.width / mainItem.model.length)
				font.weight: mainItem.textWeight
				color: mainItem.currentIndex === index ? DefaultStyle.main2_600 : DefaultStyle.main2_400
				font.family: DefaultStyle.defaultFont
				font.pixelSize: mainItem.pixelSize
				elide: Text.ElideRight
				maximumLineCount: 1
				text: modelData
                bottomPadding: Math.round(5 * DefaultStyle.dp)
			}
		}
	}
}
