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
	bottomPadding: 10 * DefaultStyle.dp
	property int radius: 16 * DefaultStyle.dp
	property color underlineColor: DefaultStyle.main1_500_main
  	property alias buttons: buttonsLayout.data
  	property alias content: contentLayout.data
	property string title
	property string text
	property string details
	property alias firstButton: firstButtonId
	property alias secondButton: secondButtonId
	property bool firstButtonAccept: true
	property bool secondButtonAccept: false

	signal accepted()
	signal rejected()

	background: Item {
		anchors.fill: parent
		Rectangle {
			visible: mainItem.underlineColor != undefined
			width: mainItem.width
			x: backgroundItem.x
			y: backgroundItem.y
			height: backgroundItem.height + 2 * DefaultStyle.dp
			color: mainItem.underlineColor
			radius: mainItem.radius
		}
		Rectangle {
			id: backgroundItem
			anchors.fill: parent
			width: mainItem.width
			height: mainItem.implicitHeight
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
	}

	contentItem: ColumnLayout {
		spacing: 20 * DefaultStyle.dp
		Text{
			id: titleText
			Layout.fillWidth: true
			visible: text.length != 0
			text: mainItem.title
			font {
				pixelSize: 16 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignLeft
		}
		Rectangle{
			Layout.fillWidth: true
			Layout.preferredHeight: 1
			color: DefaultStyle.main2_400
			visible: titleText.visible
		}

		Text {
			id: defaultText
			visible: text.length != 0
			Layout.fillWidth: true
			//Layout.preferredWidth: 278 * DefaultStyle.dp
			Layout.alignment: Qt.AlignCenter
			text: mainItem.text
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
			wrapMode: Text.Wrap
			horizontalAlignment: titleText.visible ?  Text.AlignLeft : Text.AlignHCenter
		}
		Text {
			id: detailsText
			visible: text.length != 0
			Layout.fillWidth: true
			//Layout.preferredWidth: 278 * DefaultStyle.dp
			Layout.alignment: Qt.AlignCenter
			text: mainItem.details
			font {
				pixelSize: 13 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
				italic: true
			}
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
		}

		ColumnLayout {
			id: contentLayout
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.alignment: Qt.AlignHCenter
		}

		RowLayout {
			id: buttonsLayout
			Layout.alignment: Qt.AlignBottom | ( titleText.visible ? Qt.AlignRight : Qt.AlignHCenter)
			spacing: 10 * DefaultStyle.dp

			// Default buttons only visible if no other children
			// have been set
			Button {
				id:firstButtonId
				visible: mainItem.buttons.length === 2
				text: qsTr("Oui")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					if(firstButtonAccept)
						mainItem.accepted()
					else
						mainItem.rejected()
					mainItem.close()
				}
			}
			Button {
				id: secondButtonId
				visible: mainItem.buttons.length === 2
				text: qsTr("Non")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					if(secondButtonAccept)
						mainItem.accepted()
					else
						mainItem.rejected()
					mainItem.close()
				}
			}
		}
	}
}
