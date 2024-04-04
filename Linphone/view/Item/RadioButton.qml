import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Layouts
import Linphone
  
Control.RadioButton {
	id: mainItem
	property string title
	property string contentText
	property string imgUrl
	property bool checkOnClick: true
	property color color
	property int indicatorSize: 16 * DefaultStyle.dp
	//onClicked: if (checkOnClick && !mainItem.checked) mainItem.toggle()

	MouseArea{
		anchors.fill:parent
		hoverEnabled: true
		acceptedButtons: Qt.NoButton
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
	}

	indicator: Rectangle {
		implicitWidth: mainItem.indicatorSize
		implicitHeight: mainItem.indicatorSize
		radius: implicitWidth/2
		color: "transparent"
		border.color: mainItem.color
		border.width: 2 * DefaultStyle.dp
		anchors.verticalCenter: mainItem.verticalCenter

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
}
