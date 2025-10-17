import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Switch {
    id: mainItem
    hoverEnabled: true
    property bool keyboardFocus: FocusHelper.keyboardFocus
    property bool shadowEnabled: mainItem.hovered || mainItem.activeFocus && !keyboardFocus
    // Text properties
    font {
        pixelSize: Typography.p1.pixelSize
        weight: Typography.p1.weight
    }
    // Border properties
    property color borderColor: "transparent"
    property color keyboardFocusedBorderColor: DefaultStyle.main2_900
    property real borderWidth: 0
    property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)

    indicator: Item {
        id: indicatorItem
        x: mainItem.leftPadding
        y: parent.height / 2 - height / 2
        // Size properties
        implicitHeight: Utils.getSizeWithScreenRatio(20)
        implicitWidth: Math.round(implicitHeight * 1.6)
        Rectangle {
            id: indicatorBackground
            anchors.fill: parent
            radius: Math.round(indicatorItem.height / 2)
            color: mainItem.checked ? DefaultStyle.success_500_main : DefaultStyle.main2_400
            border.color: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderColor : mainItem.borderColor
            border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: Math.round(indicatorItem.height * 0.6)
                width: height
                property real margin: Math.round((indicatorItem.height - height) / 2)
                radius: Math.round(height / 2)
                x: mainItem.checked ? parent.width - width - margin : margin
                color: DefaultStyle.grey_0
                Behavior on x {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }
        }
        MultiEffect {
            enabled: mainItem.shadowEnabled
            anchors.fill: indicatorBackground
            source: indicatorBackground
            visible: mainItem.shadowEnabled
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
