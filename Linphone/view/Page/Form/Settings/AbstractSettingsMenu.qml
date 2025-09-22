import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
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
        property real sideMargin: Utils.getSizeWithScreenRatio(45)
        spacing: Utils.getSizeWithScreenRatio(5)
		RowLayout {
			Layout.fillWidth: true
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
            spacing: Utils.getSizeWithScreenRatio(5)
			Button {
				id: backButton
				icon.width: Utils.getSizeWithScreenRatio(24)
				icon.height: Utils.getSizeWithScreenRatio(24)
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
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
            Layout.topMargin: Utils.getSizeWithScreenRatio(41)
			Layout.leftMargin: leftPanel.sideMargin
			property int selectedIndex: mainItem.defaultIndex != -1 ? mainItem.defaultIndex : 0
			activeFocusOnTab: true
			spacing: Utils.getSizeWithScreenRatio(5)
			
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
