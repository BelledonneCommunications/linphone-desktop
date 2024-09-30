import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
  
TextEdit {
	id: mainItem
	
	property string placeholderText
	property int placeholderPixelSize: 14 * DefaultStyle.dp
	property int placeholderWeight: 400 * DefaultStyle.dp
	property color placeholderTextColor: color
	property alias background: background.data
	property bool hoverEnabled: false
	property bool hovered: mouseArea.hoverEnabled && mouseArea.containsMouse
	topPadding: 5 * DefaultStyle.dp
	bottomPadding: 5 * DefaultStyle.dp
	activeFocusOnTab: true

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: mainItem.hoverEnabled
		// onPressed: mainItem.forceActiveFocus()
		acceptedButtons: Qt.NoButton
		cursorShape: mainItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
	}

	Item {
		id: background
		anchors.fill: parent
		z: -1
	}

	Text {
		anchors.verticalCenter: mainItem.verticalCenter
		text: mainItem.placeholderText
		color: mainItem.placeholderTextColor
		visible: mainItem.text.length == 0 && !mainItem.activeFocus
		x: mainItem.leftPadding
		font {
			pixelSize: mainItem.placeholderPixelSize
			weight: mainItem.placeholderWeight
		}
	}
}

