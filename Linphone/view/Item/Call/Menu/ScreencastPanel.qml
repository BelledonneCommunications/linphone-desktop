import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

ColumnLayout {
	property CallGui call

	spacing: 12 * DefaultStyle.dp

	Text {
		Layout.fillWidth: true
		text: qsTr("Veuillez choisir l’écran ou la fenêtre que vous souihaitez partager au autres participants")
		font.pixelSize: 14 * DefaultStyle.dp
		color: DefaultStyle.main2_500main
	}
	TabBar {
		Layout.fillWidth: true
		id: bar
		pixelSize: 16 * DefaultStyle.dp
		model: [qsTr("Ecran entier"), qsTr("Fenêtre")]
	}
	component ScreenPreviewLayout: Control.Control {
		id: screenPreview
		signal clicked()
		property var screenSource
		property int screenIndex
		property bool selected: false
		leftPadding: 18 * DefaultStyle.dp
		rightPadding: 18 * DefaultStyle.dp
		topPadding: 13 * DefaultStyle.dp
		bottomPadding: 13 * DefaultStyle.dp
		background: Rectangle {
			anchors.fill: parent
			color: screenPreview.selected ? DefaultStyle.main2_100 : DefaultStyle.grey_0
			border.width: 2 * DefaultStyle.dp
			border.color: screenPreview.selected ? DefaultStyle.main2_400 : DefaultStyle.main2_200
			radius: 10 * DefaultStyle.dp
			MouseArea {
				anchors.fill: parent
				onClicked: {
					screenPreview.clicked()
				}
			}
		}
		contentItem: ColumnLayout {
			spacing: 0
			// TODO : replace this by screen preview
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 170 * DefaultStyle.dp
			}
			Text {
				text: qsTr("Ecran %1").arg(screenIndex)
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: 14 * DefaultStyle.dp
				Layout.fillWidth: true
			}
		}
	}
	StackLayout {
		currentIndex: bar.currentIndex
		ColumnLayout {
			id: screensLayout
			spacing: 0
			property int selectedIndex
			Repeater {
				model: 2 //TODO : screensModel
				ScreenPreviewLayout {
					Layout.fillWidth: true
					screenIndex: index
					onClicked: screensLayout.selectedIndex = index
					selected: screensLayout.selectedIndex === index
				}
			}
		}
		Text {
			Layout.topMargin: 30 * DefaultStyle.dp
			font.pixelSize: 20 * DefaultStyle.dp
			text: qsTr("Cliquez sur la fenêtre à partager")
		}
	}
	Button {
		text: qsTr("Partager")
	}
}