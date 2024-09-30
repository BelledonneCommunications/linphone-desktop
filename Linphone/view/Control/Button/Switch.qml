import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone

Control.Switch {
    id: mainItem
    property bool shadowEnabled: mainItem.hovered || mainItem.activeFocus
    hoverEnabled: true
	font {
		pixelSize: 14 * DefaultStyle.dp
		weight: 400 * DefaultStyle.dp
	}
    indicator: Item{
		implicitWidth: 32 * DefaultStyle.dp
		implicitHeight: 20 * DefaultStyle.dp
		x: mainItem.leftPadding
		y: parent.height / 2 - height / 2
		Rectangle {
			id: indicatorBackground
			anchors.fill: parent			
			radius: 10 * DefaultStyle.dp
			color: mainItem.checked? DefaultStyle.success_500main : DefaultStyle.main2_400
	
			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				property int margin: 4 * DefaultStyle.dp
				x: mainItem.checked ? parent.width - width - margin : margin
				width: 12 * DefaultStyle.dp
				height: 12 * DefaultStyle.dp
				radius: 10 * DefaultStyle.dp
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
