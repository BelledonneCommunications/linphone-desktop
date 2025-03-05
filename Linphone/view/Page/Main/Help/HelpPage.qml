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
        property real sideMargin: Math.round(45 * DefaultStyle.dp)
        spacing: Math.round(5 * DefaultStyle.dp)
		RowLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
            spacing: Math.round(5 * DefaultStyle.dp)
			Button {
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
                icon.width: Math.round(24 * DefaultStyle.dp)
                icon.height: Math.round(24 * DefaultStyle.dp)
				onClicked: {
					mainItem.goBack()
				}
			}
			Text {
                //: "Aide"
                text: qsTr("help_title")
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
            Layout.topMargin: Math.round(41 * DefaultStyle.dp)
			Layout.fillWidth: true
            //: "À propos de %1"
            text: qsTr("help_about_title").arg(applicationName)
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
            Layout.topMargin: Math.round(24 * DefaultStyle.dp)
            spacing: Math.round(32 * DefaultStyle.dp)
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.detective
                //: "Règles de confidentialité"
                title: qsTr("help_about_privacy_policy_title")
                //: Quelles informations %1 collecte et utilise
                subTitle: qsTr("help_about_privacy_policy_subtitle").arg(applicationName)
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(ConstantsCpp.PrivatePolicyUrl)
				}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.info
                //: "Version"
                title: qsTr("help_about_version_title")
				subTitle: AppCpp.shortApplicationVersion
				onClicked: {}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.license
                //: "Licences GPLv3"
                title: qsTr("help_about_gpl_licence_title")
				subTitle: (copyrightRangeDate || applicationVendor ? '\u00A9 ': '') + (copyrightRangeDate ? copyrightRangeDate : '')+ (applicationVendor ? ' ' + applicationVendor : '')
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(applicationLicenceUrl)
				}
			}
			HelpIconLabelButton {
				Layout.fillWidth: true
				iconSource: AppIcons.world
                //: "Contribuer à la traduction de %1"
                title: qsTr("help_about_contribute_translations_title").arg(applicationName)
				onClicked: {
					rightPanelStackView.clear()
					Qt.openUrlExternally(ConstantsCpp.TranslationUrl)
				}
			}
		}
		Text {
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
            Layout.topMargin: Math.round(32 * DefaultStyle.dp)
			Layout.fillWidth: true
            //: "À propos de %1"
            text: qsTr("help_about_title").arg(applicationName)
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		HelpIconLabelButton {
			id: troubleShooting
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
            Layout.topMargin: Math.round(24 * DefaultStyle.dp)
			iconSource: AppIcons.debug
            //: "Dépannage"
            title: qsTr("help_troubleshooting_title")
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
