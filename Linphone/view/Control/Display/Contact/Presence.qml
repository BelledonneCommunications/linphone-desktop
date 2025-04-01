import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	
	property var accountCore
	signal setCustomStatusClicked
	signal isSet
	
	spacing: 8 * DefaultStyle.dp
	PresenceStatusItem { presence: LinphoneEnums.Presence.Online; accountCore: mainItem.accountCore; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Away; accountCore: mainItem.accountCore; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Busy; accountCore: mainItem.accountCore; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.DoNotDisturb; accountCore: mainItem.accountCore; onClick: mainItem.isSet()}
	PresenceStatusItem { presence: LinphoneEnums.Presence.Offline; accountCore: mainItem.accountCore; onClick: mainItem.isSet()}

	RowLayout {
		spacing: 0
		visible: accountCore.explicitPresence != LinphoneEnums.Presence.Undefined
		Layout.alignment: Qt.AlignLeft
		Layout.topMargin: Math.round(3 * DefaultStyle.dp)
		Layout.bottomMargin: Math.round(3 * DefaultStyle.dp)
		Label {
			font: Typography.p1
			text: qsTr("contact_presence_reset_status")
			color: DefaultStyle.main2_600
		}
		Item {
			   Layout.fillWidth: true
		}
		Item {
			width: Math.round(17 * DefaultStyle.dp)
			height: Math.round(17 * DefaultStyle.dp)

			MouseArea {
				id: hoverArea
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					accountCore.resetToAutomaticPresence()
				}
			}

			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.reloadArrow
				colorizationColor: hoverArea.containsMouse ? DefaultStyle.main2_800 : DefaultStyle.main2_600
				anchors.fill: parent
			}
		}
	}
	Rectangle {
		height: 1
		width: parent.width
		color: DefaultStyle.main2_500main
		Layout.topMargin: 8 * DefaultStyle.dp
	}
	ColumnLayout {
		spacing: 19 * DefaultStyle.dp
		RowLayout {
			spacing: 10 * DefaultStyle.dp
			Layout.topMargin: Math.round(3 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignLeft
			Text {
				font: Typography.p1
				text: accountCore.presenceNote.length > 0 ? accountCore.presenceNote : qsTr("contact_presence_custom_status")
				color: DefaultStyle.main2_600
				wrapMode: Text.WordWrap
				Layout.preferredWidth: (accountCore.presenceNote.length == 0 ? 175 : 230) * DefaultStyle.dp
			}
			Item {
				   Layout.fillWidth: true
			}
			SmallButton {
				visible: accountCore.presenceNote.length == 0
				style: ButtonStyle.secondary
				text: qsTr("contact_presence_button_set_custom_status")
				onClicked: {
					mainItem.setCustomStatusClicked()
				}
			}
		}
		RowLayout {
			visible: accountCore.presenceNote.length > 0
			spacing: 10 * DefaultStyle.dp
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
				visible: accountCore.presenceNote.length > 0
				text: qsTr("contact_presence_button_delete_custom_status")
				onClicked: {
					mainItem.accountCore.presenceNote = ""
				}
			}
		}
	}
	Item {
		Layout.fillHeight: true
	}
}
