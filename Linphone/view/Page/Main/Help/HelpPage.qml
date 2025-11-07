import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import ConstantsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils


AbstractMainPage {

	id: mainItem
	showDefaultItem: false
	
	signal goBack()
	
	leftPanelContent: ColumnLayout {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true
        property real leftMargin: Utils.getSizeWithScreenRatio(45)
        property real rightMargin: Utils.getSizeWithScreenRatio(29)
        spacing: Utils.getSizeWithScreenRatio(5)
		RowLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
            spacing: Utils.getSizeWithScreenRatio(8)
			RoundButton {
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
                icon.width: Utils.getSizeWithScreenRatio(24)
                icon.height: Utils.getSizeWithScreenRatio(24)
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
		Image {
			id: aboutImage
			Layout.fillWidth: true
			Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
			Layout.topMargin: Utils.getSizeWithScreenRatio(41)
			fillMode: Image.PreserveAspectFit
			source: SettingsCpp.themeAboutPictureUrl
			visible: source !== "" && status === Image.Ready
			onStatusChanged: {
				if (status === Image.Error) {
					visible = false
				}
			}
		}
		Text {
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
            Layout.topMargin: Utils.getSizeWithScreenRatio(aboutImage.visible ? 41 : 24)
			Layout.fillWidth: true
            //: "À propos de %1"
            text: qsTr("help_about_title").arg(applicationName)
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
            Layout.topMargin: Utils.getSizeWithScreenRatio(24)
            spacing: Utils.getSizeWithScreenRatio(32)
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
			RowLayout {
				HelpIconLabelButton {
					Layout.preferredWidth: width
					Layout.minimumWidth: width
					iconSource: AppIcons.info
					//: "Version"
					title: qsTr("help_about_version_title")
					subTitle: AppCpp.shortApplicationVersion
					onClicked: {}
				}
				Item{Layout.fillWidth: true}
				MediumButton {
					style: ButtonStyle.tertiary
					Layout.fillWidth: true
					//: Check update
					text: qsTr("help_check_for_update_button_label")
					onClicked: AppCpp.checkForUpdate(true)
				}
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
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
            Layout.topMargin: Utils.getSizeWithScreenRatio(32)
			Layout.fillWidth: true
            //: "À propos de %1"
            text: qsTr("help_about_title").arg(applicationName)
			color: DefaultStyle.main2_600
			font: Typography.h4
		}
		HelpIconLabelButton {
			id: troubleShooting
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.leftMargin
			Layout.rightMargin: leftPanel.rightMargin
            Layout.topMargin: Utils.getSizeWithScreenRatio(24)
			iconSource: AppIcons.debug
			arrowImageVisible: true
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
