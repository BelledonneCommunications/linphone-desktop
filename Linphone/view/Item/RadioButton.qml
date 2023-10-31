import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Layouts
import Linphone
  
Control.RadioButton {
	id: mainItem
	property bool inversedColors: false
	property string title
	property string contentText
	property string imgUrl
	hoverEnabled: true

	MouseArea {
		anchors.fill: parent
		hoverEnabled: false
		cursorShape: mainItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
		onClicked: if (!mainItem.checked) mainItem.toggle()
	}

	background: Rectangle {
		color: DefaultStyle.formItemBackgroundColor
		border.color: mainItem.checked ? DefaultStyle.radioButtonCheckedColor : "transparent"
		radius: 20
	}

	indicator: RowLayout {
		anchors.left: parent.left
		anchors.leftMargin: 13
		anchors.top: parent.top
		anchors.topMargin: 8
		spacing: 4
		Rectangle {
			implicitWidth: 16
			implicitHeight: 16
			radius: implicitWidth/2
			border.color: mainItem.checked ? DefaultStyle.radioButtonCheckedColor : DefaultStyle.radioButtonUncheckedColor

			Rectangle {
				width: parent.width/2
				height: parent.height/2
				x: parent.width/4
				y: parent.width/4
				radius: width/2
				color: DefaultStyle.radioButtonCheckedColor
				visible: mainItem.checked
			}
		}
		Text {
			text: mainItem.title
			font.bold: true
			color: DefaultStyle.radioButtonTitleColor
			font.pointSize: DefaultStyle.radioButtonTitleSize
		}
		Control.Button {
			padding: 0
			background: Item {
				visible: false
			}
			contentItem: Image {
				fillMode: Image.PreserveAspectFit
				source: AppIcons.info
				width: 2
				height: 2
			}
		}
	}
	
	contentItem: ColumnLayout {
		anchors.top: indicator.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 13
		RowLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.bottomMargin: 10
			Layout.rightMargin: 10
			Layout.alignment: Qt.AlignVCenter
			Text {
				id: innerText
				verticalAlignment: Text.AlignVCenter
				Layout.preferredWidth: 220
				Layout.preferredHeight: 100
				font.pointSize: DefaultStyle.defaultTextSize
				text: mainItem.contentText
				Layout.fillHeight: true
			}
			Image {
				id: image
				Layout.fillHeight: true
				Layout.preferredWidth: 100
				Layout.preferredHeight: 100
				fillMode: Image.PreserveAspectFit
				source: mainItem.imgUrl
			}
		}
	}
}
