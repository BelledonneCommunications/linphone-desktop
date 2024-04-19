import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone

Popup {
	id: mainItem
	property bool isSuccess: true
	property string title
	property string description
	property int index
	onAboutToShow: {
		autoClosePopup.restart()
	}
	onAboutToHide: {
		popupLayout.popupList.splice(mainItem.index, 1)
	}
	closePolicy: Popup.NoAutoClose
	x : parent.x + parent.width - width
	// y : parent.y + parent.height - height
	rightMargin: 20 * DefaultStyle.dp
	bottomMargin: 20 * DefaultStyle.dp
	padding: 20 * DefaultStyle.dp
	underlineColor: mainItem.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
	radius: 0
	onHoveredChanged: {
		if (hovered) autoClosePopup.stop()
		else autoClosePopup.restart()
	}
	Timer {
		id: autoClosePopup
		interval: 5000
		onTriggered: {
			mainItem.close()
		} 
	}
	contentItem: RowLayout {
		spacing: 24 * DefaultStyle.dp
		EffectImage {
			imageSource: mainItem.isSuccess ? AppIcons.smiley : AppIcons.smileySad
			colorizationColor: mainItem.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
			Layout.preferredWidth: 32 * DefaultStyle.dp
			Layout.preferredHeight: 32 * DefaultStyle.dp
			width: 32 * DefaultStyle.dp
			height: 32 * DefaultStyle.dp
		}
		Rectangle {
			Layout.preferredWidth: 1 * DefaultStyle.dp
			Layout.preferredHeight: parent.height
			color: DefaultStyle.main2_200
		}
		ColumnLayout {
			spacing: 2 * DefaultStyle.dp
			RowLayout {
				spacing: 0
				Text {
					Layout.fillWidth: true
					text: mainItem.title
					color: mainItem.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Button {
					Layout.preferredWidth: 20 * DefaultStyle.dp
					Layout.preferredHeight: 20 * DefaultStyle.dp
					icon.width: 20 * DefaultStyle.dp
					icon.height: 20 * DefaultStyle.dp
					Layout.alignment: Qt.AlignTop | Qt.AlignRight
					visible: mainItem.hovered || hovered
					background: Item{}
					icon.source: AppIcons.closeX
					onClicked: mainItem.close()
				}
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				Layout.maximumWidth: 300 * DefaultStyle.dp
				text: mainItem.description
				wrapMode: Text.WordWrap
				color: DefaultStyle.main2_500main
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
				}
			}
		}
	}
}
