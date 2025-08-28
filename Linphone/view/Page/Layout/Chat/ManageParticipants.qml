import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
	
Rectangle {
	id: mainItem
	property ChatGui chatGui
	property var chatCore: chatGui.core
	Layout.fillHeight: true
	Layout.fillWidth: true
	Layout.topMargin: Math.round(9 * DefaultStyle.dp)
	Layout.leftMargin: Math.round(17 * DefaultStyle.dp)
	Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
	color: DefaultStyle.grey_0
	height: participantAddColumn.implicitHeight
	signal done()

	ColumnLayout {
		id: participantAddColumn
		anchors.fill: parent
		anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
		anchors.rightMargin: Math.round(10 * DefaultStyle.dp)
		anchors.topMargin: Math.round(17 * DefaultStyle.dp)
		spacing: Math.round(5 * DefaultStyle.dp)
		RowLayout {
			spacing: Math.round(5 * DefaultStyle.dp)
			BigButton {
				id: manageParticipantsBackButton
				style: ButtonStyle.noBackground
				icon.source: AppIcons.leftArrow
				onClicked: {
					mainItem.chatCore.lSetParticipantsAddresses(manageParticipantsLayout.selectedParticipants)
					mainItem.done()
				}
			}
			Text {
				text: qsTr("group_infos_manage_participants")
				color: DefaultStyle.main2_600
				maximumLineCount: 1
				font: Typography.h4
				Layout.fillWidth: true
			}
		}
		AddParticipantsForm {
			id: manageParticipantsLayout
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.topMargin: Math.round(9 * DefaultStyle.dp)
			Layout.bottomMargin: Math.round(17 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignVCenter
			selectedParticipants: mainItem.chatCore.participantsAddresses
			focus: true
			onVisibleChanged: {
				if (visible)
					selectedParticipants = mainItem.chatCore.participantsAddresses
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
