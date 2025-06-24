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

ColumnLayout {

	id: mainItem
	property ChatGui chatGui
	property var chatCore: chatGui.core
	property int selectedLifetime: chatCore.ephemeralLifetime
	spacing: Math.round(5 * DefaultStyle.dp)
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
		spacing: Math.round(5 * DefaultStyle.dp)

		BigButton {
			id: manageParticipantsBackButton
			style: ButtonStyle.noBackground
			icon.source: AppIcons.leftArrow
			onClicked: {
				if (chatCore.ephemeralLifetime != selectedLifetime)
					chatCore.ephemeralLifetime = selectedLifetime
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
		Layout.preferredWidth: 130 * DefaultStyle.dp
		Layout.preferredHeight: 112 * DefaultStyle.dp
		Layout.topMargin: Math.round(31 * DefaultStyle.dp)
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
		Layout.topMargin: Math.round(31 * DefaultStyle.dp)
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
	}

	RoundedPane {
		id: pane
		Layout.fillWidth: true
		backgroundColor: DefaultStyle.grey_100
		Layout.leftMargin: Math.round(15 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
		Layout.topMargin: Math.round(31 * DefaultStyle.dp)
		contentItem: ColumnLayout {
			spacing: 0
			Repeater {
				model: mainItem.model
				delegate: ColumnLayout {
					Layout.fillWidth: true
					Layout.leftMargin: Math.round(8 * DefaultStyle.dp)
					Control.RadioButton {
						enabled: modelData.disabled !== true
						opacity: modelData.disabled !== true ? 1.0 : 0.5
						checked: modelData.lifetime === mainItem.selectedLifetime
						onClicked: mainItem.selectedLifetime = modelData.lifetime
						spacing: Math.round(8 * DefaultStyle.dp)
						contentItem: Text {
							id: label
							text: modelData.title
							color: DefaultStyle.main2_600
							font: Typography.p1
							leftPadding: Math.round(8 * DefaultStyle.dp)
							wrapMode: Text.NoWrap
							elide: Text.ElideRight
							anchors.left: ico.right
						}
						indicator: Image {
							id: ico
							source: parent.checked ? AppIcons.radioOn : AppIcons.radioOff
							width: Math.round(24 * DefaultStyle.dp)
							height: Math.round(24 * DefaultStyle.dp)
							fillMode: Image.PreserveAspectFit
							anchors.verticalCenter: parent.verticalCenter
						}
					}
					Rectangle {
						//visible: index < (model.count - 1)
						color: DefaultStyle.main2_200
						height: Math.round(1 * DefaultStyle.dp)
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
