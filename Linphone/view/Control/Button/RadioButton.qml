import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
Control.RadioButton {
	id: mainItem
	property string title
	property string contentText
	property string imgUrl
	property bool checkOnClick: true
	property color color
    property real indicatorSize: Math.round(16 * DefaultStyle.dp)
	property bool shadowEnabled: mainItem.activeFocus || mainItem.hovered
	//onClicked: if (checkOnClick && !mainItem.checked) mainItem.toggle()

	MouseArea{
		id: mouseArea
		anchors.fill:parent
		hoverEnabled: true
		acceptedButtons: Qt.NoButton
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
	}

	indicator: Item{
		implicitWidth: mainItem.indicatorSize
		implicitHeight: mainItem.indicatorSize
		anchors.verticalCenter: mainItem.verticalCenter
		Rectangle {
			id: backgroundArea
			anchors.fill: parent
			radius: mainItem.indicatorSize/2
			color: "transparent"
			border.color: mainItem.color
            border.width: Math.round(2 * DefaultStyle.dp)
			Rectangle {
				width: parent.width/2
				height: parent.height/2
				x: parent.width/4
				y: parent.width/4
				radius: width/2
				color: mainItem.color
				visible: mainItem.checked
			}
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: backgroundArea
			source: backgroundArea
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		}
	}
}
