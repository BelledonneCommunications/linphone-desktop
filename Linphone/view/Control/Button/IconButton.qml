import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Button {
	id: mainItem
	icon.width: 24 * DefaultStyle.dp
	icon.height: 24 * DefaultStyle.dp
	textSize: 14 * DefaultStyle.dp
	textWeight: 400 * DefaultStyle.dp
	radius: 5 * DefaultStyle.dp
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
