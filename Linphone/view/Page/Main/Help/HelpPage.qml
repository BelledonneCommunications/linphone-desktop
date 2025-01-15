import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractMainPage {

	id: mainItem
	showDefaultItem: false
	
	signal goBack()
	
	leftPanelContent: ColumnLayout {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true
		property int sideMargin: 45 * DefaultStyle.dp
		spacing: 5 * DefaultStyle.dp
		RowLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			spacing: 5 * DefaultStyle.dp
			Button {
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				onClicked: {
					mainItem.goBack()
				}
			}
			Text {
				text: qsTr("Aide")
				color: DefaultStyle.main2_700
				font: Typography.h2
			}
			Item {
				Layout.fillWidth: true
			}
		}
		Text {
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			Layout.topMargin: 41 * DefaultStyle.dp
			Layout.fillWidth: true
			text: qsTr("À propos de Linphone")
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			Layout.topMargin: 24 * DefaultStyle.dp
			spacing: 32 * DefaultStyle.dp
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.detective
				title: qsTr("Règles de confidentialité")
				subTitle: qsTr("Comment Linphone récolte et utilise les informations")
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(ConstantsCpp.PrivatePolicyUrl)
				}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.info
				title: qsTr("Version")
				subTitle: AppCpp.shortApplicationVersion
				onClicked: {}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.license
				title: qsTr("Licences GPLv3")
				subTitle: (copyrightRangeDate || applicationVendor ? '\u00A9 ': '') + (copyrightRangeDate ? copyrightRangeDate : '')+ (applicationVendor ? ' ' + applicationVendor : '')
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(applicationLicenceUrl)
				}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.world
				title: qsTr("Contribuer à la traduction de Linphone")
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(ConstantsCpp.TranslationUrl)
				}
			}
		}
		Text {
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			Layout.topMargin: 32 * DefaultStyle.dp
			Layout.fillWidth: true
			text: qsTr("À propos de Linphone")
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		HelpIconLabelButton {
			id: troubleShooting
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			Layout.topMargin: 24 * DefaultStyle.dp
			iconSource: AppIcons.debug
			title: qsTr("Dépannage")
			onClicked: {
				rightPanelStackView.clear()
				rightPanelStackView.push("qrc:/qt/qml/Linphone/view/Page/Layout/Settings/DebugSettingsLayout.qml", { titleText: troubleShooting.title, container: rightPanelStackView })
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
