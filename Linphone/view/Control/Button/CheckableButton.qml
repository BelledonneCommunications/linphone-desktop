import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Button {
	id: mainItem
	property string iconUrl
	property string checkedIconUrl
	style: ButtonStyle.checkable
	color: style?.color?.normal || DefaultStyle.grey_500
	pressedColor: checkedIconUrl ? color : style?.color?.pressed || DefaultStyle.grey_500
	hoveredColor: checked ? Qt.darker(pressedColor, 1.05) : style?.color?.hovered || DefaultStyle.grey_500
	property color backgroundColor: hovered
		? hoveredColor
		: checked
			? pressedColor
			: color
	checkable: true
	Accessible.role: Accessible.Button
	icon.source: checkedIconUrl && mainItem.checked ? checkedIconUrl : iconUrl
	icon.width: Math.round(width * 0.58)
	icon.height: Math.round(width * 0.58)
	contentImageColor: style?.image?.normal || DefaultStyle.grey_0
}
