
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control

import Linphone

Rectangle {
	id: mainItem
	anchors.fill: parent
	property string titleText
	property var component
	color: 'white'
	
	Rectangle {
		width: parent.width - 2 * 45 * DefaultStyle.dp
		height: parent.height
		anchors.centerIn: parent
		
		ColumnLayout {
			width: parent.width
			spacing: 10 * DefaultStyle.dp
			Text {
				text: titleText
				font: Typography.h3
				Layout.fillWidth: true
				Layout.topMargin: 20 * DefaultStyle.dp
				color: DefaultStyle.main2_600
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.topMargin: 16 * DefaultStyle.dp
				height: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
			}
			Loader {
				id:loader
				Layout.fillWidth: true
				sourceComponent: mainItem.component
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
}

