import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

MouseArea {
	id: mainItem
	property string iconSource
	property string title
	property string subTitle
	property int iconSize: 32 * DefaultStyle.dp
	hoverEnabled: true
	width: content.implicitWidth
	height: content.implicitHeight
	cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
	RowLayout {
		id: content
		anchors.verticalCenter: parent.verticalCenter
		anchors.fill:parent
		EffectImage {
			Layout.preferredWidth: mainItem.iconSize
			Layout.preferredHeight: mainItem.iconSize
			width: mainItem.iconSize
			height: mainItem.iconSize
			imageSource: mainItem.iconSource
			colorizationColor: DefaultStyle.main1_500_main
		}
		ColumnLayout {
			width: implicitWidth
			height: implicitHeight
			Layout.leftMargin: 16 * DefaultStyle.dp
			Text {
				Layout.fillWidth: true
				text: mainItem.title
				color: DefaultStyle.main2_600
				font: Typography.p2
				Layout.alignment: Qt.AlignBottom
				verticalAlignment: Text.AlignBottom
			}
			Text {
				Layout.alignment: Qt.AlignTop
				verticalAlignment: Text.AlignTop
				Layout.fillWidth: true
				text: mainItem.subTitle
				color: DefaultStyle.main2_500main
				visible: subTitle.length > 0
				font: Typography.p1
			}
		}
	}
}
