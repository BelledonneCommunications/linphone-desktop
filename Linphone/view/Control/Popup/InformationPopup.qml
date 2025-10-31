import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Popup {
	id: mainItem
	property bool isSuccess: true
	property string title
	property string description
	property int index
	signal closePopup(int index)
	onClosed: closePopup(index)
	onAboutToShow: {
		autoClosePopup.restart()
	}
	closePolicy: Popup.NoAutoClose
	x : parent.x + parent.width - width
	// y : parent.y + parent.height - height
    rightMargin: Utils.getSizeWithScreenRatio(20)
    bottomMargin: Utils.getSizeWithScreenRatio(20)
    padding: Utils.getSizeWithScreenRatio(20)
	underlineColor: mainItem.isSuccess ? DefaultStyle.success_500_main : DefaultStyle.danger_500_main
	radius: 0
	focus: true

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
        spacing: Utils.getSizeWithScreenRatio(24)
		Accessible.role: Accessible.AlertMessage
		Accessible.name: "%1, %2".arg(mainItem.title).arg(mainItem.description)
		EffectImage {
			imageSource: mainItem.isSuccess ? AppIcons.smiley : AppIcons.smileySad
			colorizationColor: mainItem.isSuccess ? DefaultStyle.success_500_main : DefaultStyle.danger_500_main
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
            width: Utils.getSizeWithScreenRatio(32)
            height: Utils.getSizeWithScreenRatio(32)
		}
		Rectangle {
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(1)
			Layout.preferredHeight: parent.height
			color: DefaultStyle.main2_200
		}
		ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(2)
			RowLayout {
				spacing: 0
				Text {
					Layout.fillWidth: true
					text: mainItem.title
					color: mainItem.isSuccess ? DefaultStyle.success_500_main : DefaultStyle.danger_500_main
					font {
                        pixelSize: Typography.h4.pixelSize
                        weight: Typography.h4.weight
					}
				}
				Button {
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                    icon.width: Utils.getSizeWithScreenRatio(20)
                    icon.height: Utils.getSizeWithScreenRatio(20)
					Layout.alignment: Qt.AlignTop | Qt.AlignRight
					visible: mainItem.hovered || hovered
					style: ButtonStyle.noBackground
					icon.source: AppIcons.closeX
					onClicked: mainItem.close()
				}
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
                Layout.maximumWidth: Utils.getSizeWithScreenRatio(300)
				text: mainItem.description
				wrapMode: Text.WordWrap
				color: DefaultStyle.main2_500_main
				onLinkActivated: Qt.openUrlExternally(link)
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Utils.getSizeWithScreenRatio(300)
				}
			}
		}
	}
}
