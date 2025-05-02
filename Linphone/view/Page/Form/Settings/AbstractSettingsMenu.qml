import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractMainPage {

	id: mainItem
	showDefaultItem: false
	
	property var layoutsPath
	property var titleText

	signal goBack()
	signal goBackRequested()
	
	function layoutUrl(name) {
		return layoutsPath+"/"+name+".qml"
	}
	
	property var families
	property var defaultIndex: -1
	
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
				id: backButton
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
				focus: true
				onClicked: {
					mainItem.goBackRequested()
				}
			}
			Text {
				text: titleText
				color: DefaultStyle.main2_700
				font: Typography.h3
			}
			Item {
				Layout.fillWidth: true
			}
		}
		
		ListView {
			id: familiesList
			Layout.fillWidth: true
			Layout.fillHeight: true
			model: mainItem.families
            Layout.topMargin: Math.round(41 * DefaultStyle.dp)
			Layout.leftMargin: leftPanel.sideMargin
			property int selectedIndex: mainItem.defaultIndex != -1 ? mainItem.defaultIndex : 0
			activeFocusOnTab: true
			
			delegate: SettingsMenuItem {
				titleText: modelData.title
				visible: modelData.visible != undefined ? modelData.visible : true
				isSelected: familiesList.selectedIndex == index
				focus: index == 0
				onSelected: {
					familiesList.selectedIndex = index
					rightPanelStackView.clear()
					rightPanelStackView.push(layoutUrl(modelData.layout), { titleText: modelData.title, model: modelData.model, container: rightPanelStackView})
				}
			}
		}
		Component.onCompleted: {
			let initialEntry = mainItem.families[familiesList.selectedIndex]
			rightPanelStackView.push(layoutUrl(initialEntry.layout), { titleText: initialEntry.title, model: initialEntry.model, container: rightPanelStackView})
			familiesList.currentIndex = familiesList.selectedIndex
			backButton.forceActiveFocus()
		}
	}
}
