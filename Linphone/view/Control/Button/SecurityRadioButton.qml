import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
  
Control.RadioButton {
	id: mainItem
	property string title
	property string contentText
	property string imgUrl
	property color color
	hoverEnabled: true

	MouseArea {
		anchors.fill: parent
		hoverEnabled: false
		cursorShape: mainItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
		onClicked: if (!mainItem.checked) mainItem.toggle()
	}

	background: Rectangle {
		color: DefaultStyle.grey_100
		border.color: mainItem.checked ? mainItem.color : "transparent"
		radius: 20 * DefaultStyle.dp
	}

	indicator: RowLayout {
		anchors.left: parent.left
		anchors.leftMargin: 13 * DefaultStyle.dp
		anchors.top: parent.top
		anchors.topMargin: 8 * DefaultStyle.dp
		spacing: 4 * DefaultStyle.dp
		Rectangle {
			implicitWidth: 16 * DefaultStyle.dp
			implicitHeight: 16 * DefaultStyle.dp
			radius: implicitWidth/2
			border.color: mainItem.color

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
		Text {
			visible: mainItem.title.length > 0
			text: mainItem.title
			font.bold: true
			color: DefaultStyle.grey_900
			font.pixelSize: 16 * DefaultStyle.dp
		}
		Button {
			padding: 0
			background: Item {
				visible: false
			}
			icon.source: AppIcons.info
			Layout.preferredWidth: 2 * DefaultStyle.dp
			Layout.preferredHeight: 2 * DefaultStyle.dp
			width: 2 * DefaultStyle.dp
			height: 2 * DefaultStyle.dp
			icon.width: 2 * DefaultStyle.dp
			icon.height: 2 * DefaultStyle.dp
		}
	}
	
	contentItem: ColumnLayout {
		anchors.top: indicator.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 13 * DefaultStyle.dp
		RowLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.bottomMargin: 10 * DefaultStyle.dp
			Layout.rightMargin: 10 * DefaultStyle.dp
			Layout.alignment: Qt.AlignVCenter
			Text {
				id: innerText
				verticalAlignment: Text.AlignVCenter
				Layout.preferredWidth: 220 * DefaultStyle.dp
				Layout.preferredHeight: 100 * DefaultStyle.dp
				font.pixelSize: 14 * DefaultStyle.dp
				text: mainItem.contentText
				Layout.fillHeight: true
			}
			Image {
				id: image
				Layout.fillHeight: true
				Layout.preferredWidth: 100 * DefaultStyle.dp
				Layout.preferredHeight: 100 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				source: mainItem.imgUrl
			}
		}
	}
}
