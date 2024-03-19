import QtQuick 2.7
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone

Control.Page {
	id: mainItem
	property alias headerContent: header.children

	background: Rectangle {
		width: mainItem.width
		height: mainItem.height
		color: DefaultStyle.grey_100
		radius: 15 * DefaultStyle.dp
	}
	
	header: Control.Control {
		id: pageHeader
		width: mainItem.width
		height: 56 * DefaultStyle.dp
		leftPadding: 10 * DefaultStyle.dp
		rightPadding: 10 * DefaultStyle.dp
		background: Rectangle {
			id: headerBackground
			width: pageHeader.width
			height: pageHeader.height
			color: DefaultStyle.grey_0
			radius: 15 * DefaultStyle.dp
			Rectangle {
				y: pageHeader.height/2
				height: pageHeader.height/2
				width: pageHeader.width
			}
		}
		contentItem: RowLayout {
			Item {
				id: header
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			Button {
				id: closeButton
				background: Item {
					visible: false
				}
				icon.source: AppIcons.closeX
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				onClicked: mainItem.visible = false
			}
		}
	}
}
