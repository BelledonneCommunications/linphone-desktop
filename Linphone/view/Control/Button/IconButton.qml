import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Button {
	id: mainItem
    icon.width: Utils.getSizeWithScreenRatio(24)
    icon.height: Utils.getSizeWithScreenRatio(24)
    textSize: Typography.p1.pixelSize
    textWeight: Typography.p1.weight
    radius: Utils.getSizeWithScreenRatio(5)
	shadowEnabled: mainItem.activeFocus || hovered
	style: ButtonStyle.hoveredBackground

    background: Rectangle {
        anchors.fill: parent
        radius: mainItem.radius
        color: mainItem.pressed
            ? mainItem.pressedColor
            : mainItem.hovered || mainItem.hasNavigationFocus
                ? mainItem.hoveredColor
                : mainItem.color
        border.color: mainItem.borderColor
    }
	
    contentItem: EffectImage {
        imageSource: mainItem.icon.source
        imageWidth: mainItem.icon.width
        imageHeight: mainItem.icon.height
        colorizationColor: mainItem.pressed
            ? mainItem.pressedImageColor
            : mainItem.hovered
                ? mainItem.hoveredImageColor
                : mainItem.contentImageColor
        Layout.preferredWidth: mainItem.icon.width
        Layout.preferredHeight: mainItem.icon.height
    }
}
