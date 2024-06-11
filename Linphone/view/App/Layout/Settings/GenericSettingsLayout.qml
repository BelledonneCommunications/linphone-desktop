
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control

import Linphone

Rectangle {
	id: mainItem
	Layout.fillWidth: true
	Layout.fillHeight: true
	color: DefaultStyle.grey_0

	property string titleText
	property var component
	property int horizontalMargin: 17 * DefaultStyle.dp
	property int verticalMargin: 21 * DefaultStyle.dp

	Control.ScrollView {
		anchors.fill: parent
		anchors.leftMargin: 55 * DefaultStyle.dp
		anchors.topMargin: 85 * DefaultStyle.dp
		ColumnLayout {
			width: parent.width
			spacing: 10 * DefaultStyle.dp
			Text {
				text: titleText
				font: Typography.h3m
				Layout.fillWidth: true
				Layout.leftMargin: 10 * DefaultStyle.dp
			}
			Rectangle {
				Layout.preferredWidth: loader.implicitWidth + 2 * mainItem.horizontalMargin
				Layout.preferredHeight: loader.implicitHeight + 2 * mainItem.verticalMargin
				color: DefaultStyle.grey_100
				radius: 15 * DefaultStyle.dp
				Loader {
					id:loader
					anchors.centerIn:parent
					anchors.topMargin: mainItem.verticalMargin
					anchors.bottomMargin: mainItem.verticalMargin
					anchors.leftMargin: mainItem.horizontalMargin
					anchors.rightMargin: mainItem.horizontalMargin
					sourceComponent: mainItem.component
				}
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
}


 
