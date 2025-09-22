import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
    rightMargin: Math.round(20 * DefaultStyle.dp)
    bottomMargin: Math.round(20 * DefaultStyle.dp)
    padding: Math.round(20 * DefaultStyle.dp)
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
        spacing: Math.round(24 * DefaultStyle.dp)
		Accessible.role: Accessible.AlertMessage
		Accessible.name: "%1, %2".arg(mainItem.title).arg(mainItem.description)
		EffectImage {
			imageSource: mainItem.isSuccess ? AppIcons.smiley : AppIcons.smileySad
			colorizationColor: mainItem.isSuccess ? DefaultStyle.success_500_main : DefaultStyle.danger_500_main
            Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
            width: Math.round(32 * DefaultStyle.dp)
            height: Math.round(32 * DefaultStyle.dp)
		}
		Rectangle {
            Layout.preferredWidth: Math.max(Math.round(1 * DefaultStyle.dp), 1)
			Layout.preferredHeight: parent.height
			color: DefaultStyle.main2_200
		}
		ColumnLayout {
            spacing: Math.round(2 * DefaultStyle.dp)
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
                    Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
                    icon.width: Math.round(20 * DefaultStyle.dp)
                    icon.height: Math.round(20 * DefaultStyle.dp)
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
                Layout.maximumWidth: Math.round(300 * DefaultStyle.dp)
				text: mainItem.description
				wrapMode: Text.WordWrap
				color: DefaultStyle.main2_500_main
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Math.round(300 * DefaultStyle.dp)
				}
			}
		}
	}
}
