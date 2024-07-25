
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control

import Linphone

Rectangle {
	id: mainItem
	width: container.width
	height: container.height
	property string titleText
	property var component
	property var model
	color: 'white'
	property var container

	Control.ScrollView {
		id: scrollView
		height: parent.height
		width: parent.width - 2 * 45 * DefaultStyle.dp
		anchors.centerIn: parent
		contentHeight: content.height + 20 * DefaultStyle.dp
		contentWidth: parent.width - 2 * 45 * DefaultStyle.dp
		Control.ScrollBar.vertical: ScrollBar {
			active: scrollView.contentHeight > container.height
			interactive: true
			policy: Control.ScrollBar.AsNeeded
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.rightMargin: -15 * DefaultStyle.dp
		}
		Control.ScrollBar.horizontal: ScrollBar {
			active: false
		}
		ColumnLayout {
			id: content
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

