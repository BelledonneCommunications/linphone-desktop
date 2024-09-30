import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone

Button {
	id: mainItem
	property string iconUrl
	property string checkedIconUrl
	property color color: DefaultStyle.grey_500
	property color checkedColor: color
	property color backgroundColor: mainItem.enabled
					? mainItem.pressed || mainItem.checked
						? mainItem.checkedColor
						: mainItem.color
					: DefaultStyle.grey_600
	checkable: true
	background: Rectangle {
		anchors.fill: parent
		color: mainItem.backgroundColor
		radius: mainItem.width /2
	}
	icon.source: checkedIconUrl && mainItem.checked ? checkedIconUrl : iconUrl
	icon.width: width * 0.58
	icon.height: width * 0.58
	contentImageColor: enabled ? DefaultStyle.grey_0 : DefaultStyle.grey_500
}
