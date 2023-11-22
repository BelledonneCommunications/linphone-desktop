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
		color: DefaultStyle.callRightPanelBackgroundColor
		radius: 15
	}
	
	header: Control.Control {
		id: pageHeader
		width: mainItem.width
		background: Rectangle {
			id: headerBackground
			width: pageHeader.width
			height: pageHeader.height
			color: DefaultStyle.grey_0
			radius: 15
			Rectangle {
				y: pageHeader.height/2
				height: pageHeader.height/2
				width: pageHeader.width

			}
		}
		contentItem: RowLayout {
			width: pageHeader.width
			height: pageHeader.height
			anchors.leftMargin: 10
			anchors.left: pageHeader.left
			Item {
				id: header
			}
			Item {
				Layout.fillWidth: true
			}
			Button {
				id: closeButton
				Layout.alignment: Qt.AlignRight
				background: Item {
					visible: false
				}
				contentItem: Image {
					anchors.centerIn: closeButton
					source: AppIcons.closeX
					width: 10
					sourceSize.width: 10
					fillMode: Image.PreserveAspectFit
				}
				onClicked: mainItem.visible = false
			}
		}
	}
}