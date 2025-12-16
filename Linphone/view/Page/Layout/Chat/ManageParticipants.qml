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
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Rectangle {
	id: mainItem
	property ChatGui chatGui
	Layout.fillHeight: true
	Layout.fillWidth: true
	Layout.topMargin: Utils.getSizeWithScreenRatio(9)
	Layout.leftMargin: Utils.getSizeWithScreenRatio(17)
	Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
	color: DefaultStyle.grey_0
	height: participantAddColumn.implicitHeight
	signal done()

	ColumnLayout {
		id: participantAddColumn
		anchors.fill: parent
		anchors.leftMargin: Utils.getSizeWithScreenRatio(17)
		anchors.rightMargin: Utils.getSizeWithScreenRatio(10)
		anchors.topMargin: Utils.getSizeWithScreenRatio(17)
		spacing: Utils.getSizeWithScreenRatio(5)
		RowLayout {
			spacing: Utils.getSizeWithScreenRatio(5)
			BigButton {
				id: manageParticipantsBackButton
				style: ButtonStyle.noBackground
				icon.source: AppIcons.leftArrow
				onClicked: {
					mainItem.chatGui.core.lSetParticipantsAddresses(manageParticipantsLayout.selectedParticipants)
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
			Layout.topMargin: Utils.getSizeWithScreenRatio(9)
			Layout.bottomMargin: Utils.getSizeWithScreenRatio(17)
			Layout.alignment: Qt.AlignVCenter
			selectedParticipants: mainItem.chatGui.core.participantsAddresses
			focus: true
			onVisibleChanged: {
				if (visible)
					selectedParticipants = mainItem.chatGui.core.participantsAddresses
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
