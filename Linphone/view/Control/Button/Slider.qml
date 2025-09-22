import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Slider {
    id: mainItem
    property bool keyboardFocus: FocusHelper.keyboardFocus
    property bool shadowEnabled: mainItem.hovered || mainItem.activeFocus && !keyboardFocus
	hoverEnabled: true
    // Border properties
    property color borderColor: "transparent"
    property color keyboardFocusedBorderColor: DefaultStyle.main2_900
    property real borderWidth: 0
    property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)
    background: Item{
		x: mainItem.leftPadding
		y: mainItem.topPadding + mainItem.availableHeight / 2 - height / 2
        implicitWidth: Utils.getSizeWithScreenRatio(200)
        implicitHeight: Utils.getSizeWithScreenRatio(4)
		width: mainItem.availableWidth
		height: implicitHeight
		Rectangle {
			id: sliderBackground
			anchors.fill: parent
            radius: Math.round(height / 2)
			// TODO : change the colors when mockup indicates their names
			color: DefaultStyle.grey_850
	
			Rectangle {
				width: mainItem.visualPosition * parent.width
				height: parent.height
				gradient: Gradient {
					orientation: Gradient.Horizontal
					GradientStop { position: 0.0; color: DefaultStyle.main1_300 }
					GradientStop { position: 1.0; color: DefaultStyle.main1_500_main }
				}
                radius: Math.round(height / 2)
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
        implicitWidth: Utils.getSizeWithScreenRatio(16)
        implicitHeight: Utils.getSizeWithScreenRatio(16)
		Rectangle {
			id: handleRect
			anchors.fill: parent
            radius: Math.round(height / 2)
			color: DefaultStyle.grey_0
            border.color: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderColor : mainItem.borderColor
            border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth
		}
		MultiEffect {
			source: handleRect
			anchors.fill: handleRect
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: 0.5
		}
	}
}
