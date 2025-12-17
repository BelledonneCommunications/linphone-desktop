import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	
	property var accountGui
	signal setCustomStatusClicked
	signal isSet
	
	spacing: Utils.getSizeWithScreenRatio(8)
	PresenceStatusItem { presence: LinphoneEnums.Presence.Online; accountGui: mainItem.accountGui; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Away; accountGui: mainItem.accountGui; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Busy; accountGui: mainItem.accountGui; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.DoNotDisturb; accountGui: mainItem.accountGui; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Offline; accountGui: mainItem.accountGui; onClick: mainItem.isSet()}

	RowLayout {
		spacing: 0
		visible: accountGui.core.explicitPresence != LinphoneEnums.Presence.Undefined
		Layout.alignment: Qt.AlignLeft
		Layout.topMargin: Utils.getSizeWithScreenRatio(3)
		Layout.bottomMargin: Utils.getSizeWithScreenRatio(3)
		Label {
			font: Typography.p1
			text: qsTr("contact_presence_reset_status")
			color: DefaultStyle.main2_600
		}
		Item {
			   Layout.fillWidth: true
		}
		Button {
			id: resetStatusItem
			style: ButtonStyle.noBackground
			icon.width: Utils.getSizeWithScreenRatio(17)
			icon.height: Utils.getSizeWithScreenRatio(17)
			icon.source: AppIcons.reloadArrow
			onClicked: accountGui.core.resetToAutomaticPresence()
		}
	}
	HorizontalBar {
		Layout.topMargin: Utils.getSizeWithScreenRatio(8)
	}
	ColumnLayout {
		spacing: Utils.getSizeWithScreenRatio(19)
		RowLayout {
			spacing: Utils.getSizeWithScreenRatio(10)
			Layout.topMargin: Utils.getSizeWithScreenRatio(3)
			Layout.alignment: Qt.AlignLeft
			Text {
				font: Typography.p1
				text: accountGui.core.presenceNote.length > 0 ? accountGui.core.presenceNote : qsTr("contact_presence_custom_status")
				color: DefaultStyle.main2_600
				wrapMode: Text.WordWrap
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(accountGui.core.presenceNote.length == 0 ? 175 : 230)
			}
			Item {
				   Layout.fillWidth: true
			}
			SmallButton {
				visible: accountGui.core.presenceNote.length == 0
				style: ButtonStyle.secondary
				text: qsTr("contact_presence_button_set_custom_status")
				onClicked: {
					mainItem.setCustomStatusClicked()
				}
			}
		}
		RowLayout {
			visible: accountGui.core.presenceNote.length > 0
			spacing: Utils.getSizeWithScreenRatio(10)
			Item {
				   Layout.fillWidth: true
			}
			SmallButton {
				style: ButtonStyle.secondary
				text: qsTr("contact_presence_button_edit_custom_status")
				onClicked: {
					mainItem.setCustomStatusClicked()
				}
			}
			SmallButton {
				style: ButtonStyle.secondary
				visible: accountGui.core.presenceNote.length > 0
				text: qsTr("contact_presence_button_delete_custom_status")
				onClicked: {
					mainItem.accountGui.core.presenceNote = ""
				}
			}
		}
	}
	Item {
		Layout.fillHeight: true
	}
}
