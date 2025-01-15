import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Popup {
	id: mainItem
	modal: true
	anchors.centerIn: parent
	closePolicy: Control.Popup.NoAutoClose
	leftPadding: title.length === 0 ? 10 * DefaultStyle.dp : 33 * DefaultStyle.dp 
	rightPadding: title.length === 0 ? 10 * DefaultStyle.dp : 33 * DefaultStyle.dp 
	topPadding: title.length === 0 ? 10 * DefaultStyle.dp : 37 * DefaultStyle.dp
	bottomPadding: title.length === 0 ? 10 * DefaultStyle.dp : 37 * DefaultStyle.dp
	underlineColor: DefaultStyle.main1_500_main
	radius: title.length === 0 ? 16 * DefaultStyle.dp : 0
	property string title
	property var titleColor: DefaultStyle.main1_500_main
	property string text
	property string details
	property string firstButtonText: firstButtonAccept ? qsTr("Oui") : qsTr("Annuler")
	property string secondButtonText: secondButtonAccept ? qsTr("Confirmer") : qsTr("Non")
  	property alias content: contentLayout.data
  	property alias buttons: buttonsLayout.data
	property alias firstButton: firstButtonId
	property alias secondButton: secondButtonId
	property bool firstButtonAccept: true
	property bool secondButtonAccept: false

	signal accepted()
	signal rejected()

	contentItem: FocusScope {
		implicitWidth: child.implicitWidth
		implicitHeight: child.implicitHeight
		onVisibleChanged: {
			if(visible) forceActiveFocus()
		}
		Keys.onPressed: (event) => {
			if(visible && event.key == Qt.Key_Escape){
				mainItem.close()
				event.accepted = true
			}
		}
		ColumnLayout {
			id: child
			anchors.fill: parent
			spacing: 15 * DefaultStyle.dp
			
			Text{
				id: titleText
				Layout.fillWidth: true
				visible: text.length != 0
				text: mainItem.title
				color: mainItem.titleColor
				font {
					pixelSize: 22 * DefaultStyle.dp
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
				Layout.alignment: Qt.AlignHCenter
				Layout.fillHeight: false
			}
			
			RowLayout {
				id: buttonsLayout
				Layout.alignment: Qt.AlignBottom | ( titleText.visible ? Qt.AlignRight : Qt.AlignHCenter)
				spacing: titleText.visible ? 20 * DefaultStyle.dp : 10 * DefaultStyle.dp
	
				// Default buttons only visible if no other children
				// have been set
				MediumButton {
					id:firstButtonId
					visible: mainItem.buttons.length === 2
					text: mainItem.firstButtonText
					style: mainItem.firstButtonAccept ? ButtonStyle.main : ButtonStyle.secondary
					focus: !mainItem.firstButtonAccept
					onClicked: {
						if(mainItem.firstButtonAccept)
							mainItem.accepted()
						else
							mainItem.rejected()
						mainItem.close()
					}
					KeyNavigation.left: secondButtonId
					KeyNavigation.right: secondButtonId
				}
				MediumButton {
					id: secondButtonId
					visible: mainItem.buttons.length === 2
					text: mainItem.secondButtonText
					style: mainItem.firstButtonAccept ? ButtonStyle.secondary : ButtonStyle.main
					focus: !mainItem.secondButtonAccept
					onClicked: {
						if(mainItem.secondButtonAccept)
							mainItem.accepted()
						else
							mainItem.rejected()
						mainItem.close()
					}
					KeyNavigation.left: firstButtonId
					KeyNavigation.right: firstButtonId
				}
			}
		}
	}
}
