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

ColumnLayout {

	id: mainItem
	property ChatGui chatGui
	property int selectedLifetime: chatGui.core.ephemeralLifetime
	spacing: Utils.getSizeWithScreenRatio(5)
	signal done()

	property var model: [
		{title: qsTr("one_minute"), lifetime: 60},
		{title: qsTr("one_hour"), lifetime: 3600},
		{title: qsTr("one_day"), lifetime: 86400},
		{title: qsTr("one_week"), lifetime: 7*86400},
		{title: qsTr("disabled"), lifetime: 0}
	]
	
	Component.onCompleted: {
		var isLifetimeInRange = model.some(function(item) {
			return item.lifetime === selectedLifetime;
		});
		 if (!isLifetimeInRange) { // Display life time set elsewhere, not in settable range.
			model = model.concat({
				title: qsTr("custom")+UtilsCpp.getEphemeralFormatedTime(selectedLifetime),
				lifetime: selectedLifetime,
				disabled: true
			});
		}
    }

	RowLayout {
		id: manageParticipantsButtons
		spacing: Utils.getSizeWithScreenRatio(5)

		BigButton {
			id: manageParticipantsBackButton
			style: ButtonStyle.noBackground
			icon.source: AppIcons.leftArrow
			onClicked: {
				if (chatGui.core.ephemeralLifetime != selectedLifetime)
					chatGui.core.ephemeralLifetime = selectedLifetime
				mainItem.done()
			}
		}

		Text {
			text: qsTr("title")
			color: DefaultStyle.main2_600
			maximumLineCount: 1
			font: Typography.h4
			Layout.fillWidth: true
		}
	}

	Image {
		Layout.preferredWidth: Utils.getSizeWithScreenRatio(130)
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(112)
		Layout.topMargin: Utils.getSizeWithScreenRatio(31)
		Layout.alignment: Qt.AlignHCenter
		source: AppIcons.ephemeralSettings
		fillMode: Image.PreserveAspectFit
		Layout.fillWidth: true
	}

	Text {
		text: qsTr("explanations")
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		font: Typography.p1
		color: DefaultStyle.main2_600
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Utils.getSizeWithScreenRatio(31)
		Layout.leftMargin: Utils.getSizeWithScreenRatio(15)
		Layout.rightMargin: Utils.getSizeWithScreenRatio(15)
	}

	RoundedPane {
		id: pane
		Layout.fillWidth: true
		backgroundColor: DefaultStyle.grey_100
		Layout.leftMargin: Utils.getSizeWithScreenRatio(15)
		Layout.rightMargin: Utils.getSizeWithScreenRatio(15)
		Layout.topMargin: Utils.getSizeWithScreenRatio(31)
		contentItem: ColumnLayout {
			spacing: 0
			Repeater {
				model: mainItem.model
				delegate: ColumnLayout {
					Layout.fillWidth: true
					Layout.leftMargin: Utils.getSizeWithScreenRatio(8)
					RadioButton {
						color: DefaultStyle.main1_500_main
						enabled: modelData.disabled !== true
						opacity: modelData.disabled !== true ? 1.0 : 0.5
						checked: modelData.lifetime === mainItem.selectedLifetime
						onClicked: mainItem.selectedLifetime = modelData.lifetime
						spacing: Utils.getSizeWithScreenRatio(8)
						contentItem: Text {
							id: label
							text: modelData.title
							color: DefaultStyle.main2_600
							font: Typography.p1
							leftPadding: Utils.getSizeWithScreenRatio(20)
							wrapMode: Text.NoWrap
							elide: Text.ElideRight
						}

					}
					Rectangle {
						//visible: index < (model.count - 1)
						color: DefaultStyle.main2_200
						height: Utils.getSizeWithScreenRatio(1)
						Layout.fillWidth: true
					}
				}
			}
		}
	}

	Item {
		Layout.fillHeight: true
	}
}
