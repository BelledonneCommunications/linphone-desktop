import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
  
Popup {
	id: mainItem
	modal: true
	anchors.centerIn: parent
	closePolicy: Control.Popup.NoAutoClose
	rightPadding: 10 * DefaultStyle.dp
	leftPadding: 10 * DefaultStyle.dp
	topPadding: 10 * DefaultStyle.dp
	bottomPadding: 10 * DefaultStyle.dp + buttonsLayout.height
	property int radius: 16 * DefaultStyle.dp
	property color underlineColor: DefaultStyle.main1_500_main
	property string text
	signal accepted()
	signal rejected()

	background: Item {
		anchors.fill: parent
		Rectangle {
			visible: mainItem.underlineColor != undefined
			width: mainItem.width
			height: mainItem.height + 2 * DefaultStyle.dp
			color: mainItem.underlineColor
			radius: mainItem.radius
		}
		Rectangle{
			id: backgroundItem
			width: mainItem.width
			height: mainItem.height
			radius: mainItem.radius
			color: DefaultStyle.grey_0
			border.color: DefaultStyle.grey_0
		}
		MultiEffect {
			anchors.fill: backgroundItem
			source: backgroundItem
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_900
			shadowBlur: 1.0
			shadowOpacity: 0.1
		}
		RowLayout {
			id: buttonsLayout
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: 10 * DefaultStyle.dp
			Button {
				text: qsTr("Oui")
				onClicked: {
					mainItem.accepted()
					mainItem.close()
				}
			}
			Button {
				text: qsTr("Non")
				onClicked: {
					mainItem.rejected()
					mainItem.close()
				}
			}
		}
	}

	contentItem: Text {
		width: parent.width
		Layout.preferredWidth: 278 * DefaultStyle.dp
		text: mainItem.text
		font {
			pixelSize: 14 * DefaultStyle.dp
			weight: 400 * DefaultStyle.dp
		}
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
	}
}