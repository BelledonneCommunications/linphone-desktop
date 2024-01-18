import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

MouseArea {
	id: mainItem
	property string iconSource
	property string text
	property color color: DefaultStyle.main2_600
	property int iconSize: 17 * DefaultStyle.dp 
	property int textSize: 14 * DefaultStyle.dp
	property int textWeight: 400 * DefaultStyle.dp
	hoverEnabled: true
	cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
	width: content.implicitWidth
	RowLayout {
		id: content
		anchors.verticalCenter: parent.verticalCenter
		EffectImage {
			Layout.preferredWidth: mainItem.iconSize
			Layout.preferredHeight: mainItem.iconSize
			width: mainItem.iconSize
			height: mainItem.iconSize
			source: mainItem.iconSource
			colorizationColor: mainItem.color
		}
		Text {
			width: implicitWidth
			Layout.fillWidth: true
			text: mainItem.text
			color: mainItem.color
			font {
				pixelSize: mainItem.textSize
				weight: mainItem.textWeight
			}
		}
	}
}
