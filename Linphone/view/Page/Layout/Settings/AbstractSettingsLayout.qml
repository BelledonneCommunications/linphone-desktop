
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone

Rectangle {
	id: mainItem
	width: container.width
	height: container.height
	property string titleText
	property var contentComponent
	property var topbarOptionalComponent
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
			RowLayout {
				Layout.fillWidth: true
				Layout.topMargin: 20 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				Button {
					id: backButton
					Layout.preferredHeight: 24 * DefaultStyle.dp
					Layout.preferredWidth: 24 * DefaultStyle.dp
					icon.source: AppIcons.leftArrow
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
					focus: true
					visible: mainItem.container.depth > 1
					Layout.rightMargin: 41 * DefaultStyle.dp
					onClicked: {
						mainItem.container.pop()
					}
					background: Item {
						anchors.fill: parent
					}
				}
				Text {
					text: titleText
					color: DefaultStyle.main2_600
					font: Typography.h3
				}
				Item {
					Layout.fillWidth: true
				}
				Loader {
					Layout.alignment: Qt.AlignRight
					sourceComponent: mainItem.topbarOptionalComponent
					Layout.rightMargin: 34 * DefaultStyle.dp
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.topMargin: 16 * DefaultStyle.dp
				height: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
			}
			Loader {
				Layout.fillWidth: true
				sourceComponent: mainItem.contentComponent
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
}

