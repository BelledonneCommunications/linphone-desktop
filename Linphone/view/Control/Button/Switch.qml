import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone

Control.Switch {
    id: mainItem
    property bool shadowEnabled: mainItem.hovered || mainItem.activeFocus
    hoverEnabled: true
	font {
        pixelSize: Typography.p1.pixelSize
        weight: Typography.p1.weight
	}
    indicator: Item{
        implicitWidth: Math.round(32 * DefaultStyle.dp)
        implicitHeight: Math.round(20 * DefaultStyle.dp)
		x: mainItem.leftPadding
		y: parent.height / 2 - height / 2
		Rectangle {
			id: indicatorBackground
			anchors.fill: parent			
            radius: Math.round(10 * DefaultStyle.dp)
			color: mainItem.checked? DefaultStyle.success_500main : DefaultStyle.main2_400
	
			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
                property real margin: Math.round(4 * DefaultStyle.dp)
				x: mainItem.checked ? parent.width - width - margin : margin
                width: Math.round(12 * DefaultStyle.dp)
                height: Math.round(12 * DefaultStyle.dp)
                radius: Math.round(10 * DefaultStyle.dp)
				color: DefaultStyle.grey_0
				Behavior on x {
					NumberAnimation{duration: 100}
				}
			}
		}
        MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: indicatorBackground
			source: indicatorBackground
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		}
    }

    contentItem: Text {
        text: mainItem.text
        font: mainItem.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: mainItem.indicator.width + mainItem.spacing
    }
}
