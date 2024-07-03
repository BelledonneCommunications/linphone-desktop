import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp
import SettingsCpp

AbstractMainPage {

	id: mainItem
	showDefaultItem: false
	
	signal goBack()
	
	function layoutUrl(name) {
		return "qrc:/Linphone/view/App/Layout/Settings/"+name+".qml"
	}
	
	property var settingsFamilies: [
		{title: qsTr("Appels"), layout: "CallSettingsLayout"},
		//{title: qsTr("Sécurité"), layout: "SecuritySettingsLayout"},
		{title: qsTr("Conversations"), layout: "ChatSettingsLayout", visible: !SettingsCpp.disableChatFeature},
		{title: qsTr("Contacts"), layout: "ContactSettingsLayout"},
		{title: qsTr("Réunions"), layout: "MeetingsSettingsLayout", visible: !SettingsCpp.disableMeetingsFeature},
		{title: qsTr("Affichage"), layout: "DisplaySettingsLayout"},
		{title: qsTr("Réseau"), layout: "NetworkSettingsLayout"},
		{title: qsTr("Paramètres avancés"), layout: "AdvancedSettingsLayout"}
	]
	
	leftPanelContent: ColumnLayout {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true
		property int sideMargin: 45 * DefaultStyle.dp

		RowLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			Button {
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				width: 24 * DefaultStyle.dp
				height: 24 * DefaultStyle.dp
				background: Item {
					anchors.fill: parent
				}
				onClicked: {
					mainItem.goBack()
				}
			}
			Text {
				text: qsTr("Paramètres")
				color: DefaultStyle.main2_700
				font: Typography.h3
			}
			Item {
				Layout.fillWidth: true
			}
		}
		
		ListView {
			id: settingsFamiliesList
			Layout.fillWidth: true
			Layout.fillHeight: true
			model: mainItem.settingsFamilies
			Layout.topMargin: 41 * DefaultStyle.dp
			Layout.leftMargin: leftPanel.sideMargin
			property int selectedIndex: 0
			
			delegate: SettingsFamily {
				titleText: modelData.title
				visible: modelData.visible != undefined ? modelData.visible : true
				isSelected: settingsFamiliesList.selectedIndex == index
				onSelected: {
					settingsFamiliesList.selectedIndex = index
					rightPanelStackView.clear()
					rightPanelStackView.push(layoutUrl(modelData.layout), { titleText: modelData.title })
				}
			}
		}
		Component.onCompleted: {
			let initialEntry = mainItem.settingsFamilies[settingsFamiliesList.selectedIndex]
			rightPanelStackView.push(layoutUrl(initialEntry.layout), { titleText: initialEntry.title })
		}
	}
}
