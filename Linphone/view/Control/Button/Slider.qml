import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone

Control.Slider {
    id: mainItem
	property bool shadowEnabled: mainItem.hovered || mainItem.activeFocus
	hoverEnabled: true
    background: Item{
		x: mainItem.leftPadding
		y: mainItem.topPadding + mainItem.availableHeight / 2 - height / 2
        implicitWidth: Math.round(200 * DefaultStyle.dp)
        implicitHeight: Math.round(4 * DefaultStyle.dp)
		width: mainItem.availableWidth
		height: implicitHeight
		Rectangle {
			id: sliderBackground
			anchors.fill: parent
            radius: Math.round(30 * DefaultStyle.dp)
			// TODO : change the colors when mockup indicates their names
			color: DefaultStyle.grey_850
	
			Rectangle {
				width: mainItem.visualPosition * parent.width
				height: parent.height
				gradient: Gradient {
					orientation: Gradient.Horizontal
					GradientStop { position: 0.0; color: "#FF9E79" }
					GradientStop { position: 1.0; color: "#FE5E00" }
				}
                radius: Math.round(40 * DefaultStyle.dp)
			}
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: sliderBackground
			source: sliderBackground
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		}
    }

    handle: Item {
		x: mainItem.leftPadding + mainItem.visualPosition * (mainItem.availableWidth - width)
		y: mainItem.topPadding + mainItem.availableHeight / 2 - height / 2
        implicitWidth: Math.round(16 * DefaultStyle.dp)
        implicitHeight: Math.round(16 * DefaultStyle.dp)
		Rectangle {
			id: handleRect
			anchors.fill: parent
            radius: Math.round(30 * DefaultStyle.dp)
			color: DefaultStyle.grey_0
		}
		MultiEffect {
			source: handleRect
			anchors.fill: handleRect
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: 0.1
		}
	}
}
