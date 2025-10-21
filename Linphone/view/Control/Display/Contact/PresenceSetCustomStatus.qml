import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Column {
	id: mainItem
	spacing: Utils.getSizeWithScreenRatio(20)
	anchors.centerIn: parent
	property var accountCore
	signal isSet

	Text {
		text: qsTr("contact_presence_button_set_custom_status_title")
		horizontalAlignment: Text.AlignHCenter
		color: DefaultStyle.main2_600
		font: Typography.p2
	}

	Rectangle {
		width: parent.width
		height: Utils.getSizeWithScreenRatio(150)
		color: "transparent"
		border.color: DefaultStyle.main1_500_main
		border.width: Utils.getSizeWithScreenRatio(1)
		radius: Utils.getSizeWithScreenRatio(8)

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Utils.getSizeWithScreenRatio(10)
			TextEdit {
				id: statusMessage
				wrapMode: TextEdit.Wrap
				font: Typography.p1
				color: DefaultStyle.main2_500_main
				Layout.fillHeight: true
				Layout.fillWidth: true
				property string previoustext: ""
				text: mainItem.accountCore.presenceNote
				onTextChanged: {
					if (statusMessage.text.length > accountCore.maxPresenceNoteSize) {
						statusMessage.text = previoustext
						statusMessage.cursorPosition = statusMessage.text.length
					} else {
						previoustext = statusMessage.text
					}
				}
			}
			Item {
				   Layout.fillHeight: true
			}
			Text {
				Layout.fillWidth: true
				text: statusMessage.text.length + " / " + accountCore.maxPresenceNoteSize
				font: Typography.p1
				color: DefaultStyle.main2_400
				horizontalAlignment: Text.AlignRight
			}
		}
	}

	Row {
		spacing: Utils.getSizeWithScreenRatio(10)
		anchors.right: parent.right

		SmallButton {
			style: ButtonStyle.secondary
			text: qsTr("contact_presence_button_save_custom_status")
			enabled: statusMessage.text.length > 0
			onClicked: {
				mainItem.accountCore.presenceNote = statusMessage.text
				mainItem.isSet()
			}
		}
	}
}
