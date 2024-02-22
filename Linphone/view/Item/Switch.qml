import QtQuick 2.12
import QtQuick.Controls as Control

import Linphone

Control.Switch {
    id: mainItem
	font {
		pixelSize: 14 * DefaultStyle.dp
		weight: 400 * DefaultStyle.dp
	}
    indicator: Rectangle {
        implicitWidth: 32 * DefaultStyle.dp
        implicitHeight: 20 * DefaultStyle.dp
        x: mainItem.leftPadding
        y: parent.height / 2 - height / 2
        radius: 10 * DefaultStyle.dp
        color: mainItem.checked ? DefaultStyle.success_500main : DefaultStyle.main2_400

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

    contentItem: Text {
        text: mainItem.text
        font: mainItem.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: mainItem.indicator.width + mainItem.spacing
    }
}