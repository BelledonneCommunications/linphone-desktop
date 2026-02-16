import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
  
Control.TabBar {
	id: mainItem
	property var model
	readonly property int originX: count > 0 
							? itemAt(0).x 
							: 0
    property real pixelSize: Typography.h3.pixelSize
    property real textWeight: Typography.h3.weight
	property int capitalization: Font.Capitalize
	wheelEnabled: true
	background: Item {
		id: tabBarBackground
		anchors.fill: parent

		Rectangle {
			id: barBG
            height: Utils.getSizeWithScreenRatio(4)
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
			property bool keyboardFocus: FocusHelper.keyboardFocus
			width: implicitWidth
			activeFocusOnTab: true
			hoverEnabled: true
			Accessible.name: modelData
			ToolTip {
				visible: tabText.truncated && hovered
				delay: 1000
				text: modelData
			}
			MouseArea{
				anchors.fill: parent
				cursorShape: tabButton.hovered ? Qt.PointingHandCursor: Qt.ArrowCursor
				acceptedButtons: Qt.NoButton
			}

			background: Item {
				anchors.fill: parent
				Rectangle {
					id: tabBackground
					visible: mainItem.currentIndex === index || tabButton.hovered
                    height: Utils.getSizeWithScreenRatio(5)
					color: mainItem.currentIndex === index ? DefaultStyle.main1_500_main : DefaultStyle.main2_400
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
				}
				MultiEffect {
					visible: (mainItem.currentIndex === index || tabButton.hovered) && tabButton.shadowEnabled
					enabled: tabButton.shadowEnabled
					anchors.fill: tabBackground
					source: tabBackground
					// Crash : https://bugreports.qt.io/browse/QTBUG-124730
					shadowEnabled: true //mainItem.shadowEnabled
					shadowColor: DefaultStyle.grey_1000
					shadowBlur: 0.1
					shadowOpacity: tabButton.shadowEnabled ? 0.5 : 0.0
				}
				Rectangle{
					id: borderBackground
					visible: tabButton.keyboardFocus
					height: tabButton.height
					width: tabButton.width
					color: "transparent"
					border.color: "black"
					border.width: 3
				}
			}

			contentItem: Text {
				id: tabText
				width: implicitWidth
				textFormat: Text.RichText
				font {
					pixelSize: mainItem.pixelSize
					weight: mainItem.textWeight
					capitalization: mainItem.capitalization
				}
				color: mainItem.currentIndex === index ? DefaultStyle.main2_600 : DefaultStyle.main2_400
				elide: Text.ElideRight
				maximumLineCount: 1
				text: modelData
                bottomPadding: Utils.getSizeWithScreenRatio(5)
			}
		}
	}
}
