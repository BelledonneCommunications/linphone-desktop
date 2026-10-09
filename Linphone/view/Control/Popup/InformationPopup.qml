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
	property string accessibleMessage: [title, description].map(part => part ? part.replace(/<[^>]*>/g, "").trim() : "").filter(part => part.length > 0).join(", ")
	property bool announcementPending: false
	function announceMessage() {
		if (accessibleMessage.length > 0)
			contentItem.Accessible.announce(accessibleMessage, isSuccess ? Accessible.Polite : Accessible.Assertive)
	}
	onAboutToShow: {
		autoClosePopup.restart()
	}
	function canAnnounce() {
		var window = contentItem.Window.window
		return Qt.application.state === Qt.ApplicationActive && (!window || window.active)
	}
	function announceWhenActive() {
		if (!announcementPending || !canAnnounce())
			return
		announcementPending = false
		if (!hovered)
			autoClosePopup.restart()
		Qt.callLater(announceMessage)
	}
	onOpened: {
		if (canAnnounce()) {
			announceMessage()
		} else {
			announcementPending = true
			autoClosePopup.stop()
		}
	}
	onClosed: {
		announcementPending = false
		closePopup(index)
	}
	Connections {
		target: mainItem.contentItem.Window.window
		enabled: mainItem.announcementPending
		function onActiveChanged() {
			mainItem.announceWhenActive()
		}
	}
	Connections {
		target: Qt.application
		enabled: mainItem.announcementPending
		function onStateChanged() {
			mainItem.announceWhenActive()
		}
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
		else if (!announcementPending) autoClosePopup.restart()
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
		focus: true
		Keys.onEscapePressed: event => {
			mainItem.close()
			event.accepted = true
		}
		Accessible.role: Accessible.AlertMessage
		Accessible.name: mainItem.accessibleMessage
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
					textFormat: Text.RichText
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
					Accessible.name: qsTr("close_accessible_name")
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
				textFormat: Text.RichText
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
