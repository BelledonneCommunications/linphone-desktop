import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

Item{
	id: mainItem
	property string iconSource
	property string text
	property color color: DefaultStyle.main2_600
	property int iconSize: 17 * DefaultStyle.dp 
	property int textSize: 14 * DefaultStyle.dp
	property int textWeight: 400 * DefaultStyle.dp
	property color backgroundColor: DefaultStyle.grey_0
	readonly property color backgroundPressedColor: Qt.darker(backgroundColor, 1.1)
	property int radius: 5 * DefaultStyle.dp
	property bool shadowEnabled: mainItem.activeFocus//  || containsMouse
	property alias containsMouse: mouseArea.containsMouse
	
	signal clicked(var mouse)
	
	implicitWidth: content.implicitWidth
	activeFocusOnTab: true
	
	Keys.onPressed: (event)=> {
		if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
			mainItem.clicked(undefined)
			event.accepted = true;
		}
	}
	Rectangle{
		anchors.fill: parent
		id: buttonBackground
		color: mainItem.shadowEnabled ? mainItem.backgroundPressedColor : mainItem.backgroundColor
		radius: mainItem.radius
	}/*
	MultiEffect {
		enabled: mainItem.shadowEnabled
		anchors.fill: buttonBackground
		source: buttonBackground
		visible:  mainItem.shadowEnabled
		// Crash : https://bugreports.qt.io/browse/QTBUG-124730
		shadowEnabled: true //mainItem.shadowEnabled
		shadowColor: DefaultStyle.grey_1000
		shadowBlur: 0.1
		shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
	}*/

	MouseArea {
		id: mouseArea
		anchors.verticalCenter: parent.verticalCenter
		width: content.implicitWidth
		height: mainItem.height
		hoverEnabled: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		
		onClicked: function(mouse){mainItem.clicked(mouse)}
		RowLayout {
			id: content
			anchors.verticalCenter: parent.verticalCenter
			EffectImage {
				Layout.preferredWidth: mainItem.iconSize
				Layout.preferredHeight: mainItem.iconSize
				width: mainItem.iconSize
				height: mainItem.iconSize
				imageSource: mainItem.iconSource
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
}
