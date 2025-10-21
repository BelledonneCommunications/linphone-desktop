import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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
        radius: Utils.getSizeWithScreenRatio(20)
	}

	indicator: RowLayout {
		anchors.left: parent.left
        anchors.leftMargin: Utils.getSizeWithScreenRatio(13)
		anchors.top: parent.top
        anchors.topMargin: Utils.getSizeWithScreenRatio(8)
        spacing: Utils.getSizeWithScreenRatio(4)
		Rectangle {
            implicitWidth: Utils.getSizeWithScreenRatio(16)
            implicitHeight: Utils.getSizeWithScreenRatio(16)
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
            font.pixelSize: Utils.getSizeWithScreenRatio(16)
		}
		Button {
			padding: 0
			background: Item {
				visible: false
			}
			icon.source: AppIcons.info
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(2)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(2)
            width: Utils.getSizeWithScreenRatio(2)
            height: Utils.getSizeWithScreenRatio(2)
            icon.width: Utils.getSizeWithScreenRatio(2)
            icon.height: Utils.getSizeWithScreenRatio(2)
		}
	}
	
	contentItem: ColumnLayout {
		anchors.top: indicator.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
        anchors.leftMargin: Utils.getSizeWithScreenRatio(13)
		RowLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
            Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
			Layout.alignment: Qt.AlignVCenter
			Text {
				id: innerText
				verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(220)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
                font.pixelSize: Utils.getSizeWithScreenRatio(14)
				text: mainItem.contentText
				Layout.fillHeight: true
			}
			Image {
				id: image
				Layout.fillHeight: true
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(100)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
				fillMode: Image.PreserveAspectFit
				source: mainItem.imgUrl
			}
		}
	}
}
