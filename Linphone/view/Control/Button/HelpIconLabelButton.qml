import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

MouseArea {
	id: mainItem
	property string iconSource
	property string title
	property string subTitle
    property real iconSize: Utils.getSizeWithScreenRatio(32)
	property bool shadowEnabled: containsMouse || activeFocus
	property alias image: image
	hoverEnabled: true
	width: content.implicitWidth
	height: content.implicitHeight
	cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
	activeFocusOnTab: true
	Keys.onPressed: (event) => {
		if(event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return){
			mainItem.clicked(undefined)
			event.accepted = true
		}
	}
	RowLayout {
		id: content
		anchors.verticalCenter: parent.verticalCenter
		anchors.fill:parent
		EffectImage {
			id: image
			Layout.preferredWidth: mainItem.iconSize
			Layout.preferredHeight: mainItem.iconSize
			width: mainItem.iconSize
			height: mainItem.iconSize
			imageSource: mainItem.iconSource
			colorizationColor: DefaultStyle.main1_500_main
		}
		ColumnLayout {
			width: implicitWidth
			Layout.preferredWidth: width
			height: implicitHeight
            Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
			Text {
				Layout.fillWidth: true
				maximumLineCount: 1
				text: mainItem.title
				color: DefaultStyle.main2_600
				font: Typography.p2
				Layout.alignment: Qt.AlignBottom
				verticalAlignment: Text.AlignBottom
			}
			Text {
				Layout.alignment: Qt.AlignTop
				verticalAlignment: Text.AlignTop
				maximumLineCount: 2
				Layout.fillWidth: true
				text: mainItem.subTitle
				color: DefaultStyle.main2_500_main
				visible: subTitle.length > 0
				font: Typography.p1
			}
		}
	}
	MultiEffect {
		enabled: mainItem.shadowEnabled
		anchors.fill: content
		source: content
		visible:  mainItem.shadowEnabled
		// Crash : https://bugreports.qt.io/browse/QTBUG-124730
		shadowEnabled: true //mainItem.shadowEnabled
		shadowColor: DefaultStyle.grey_1000
		shadowBlur: 0.1
		shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
	}
}
