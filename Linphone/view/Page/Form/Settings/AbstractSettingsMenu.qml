import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp

AbstractMainPage {

	id: mainItem
	showDefaultItem: false
	
	property var layoutsPath
	property var titleText

	signal goBack()
	
	function layoutUrl(name) {
		return layoutsPath+"/"+name+".qml"
	}
	
	property var families
	
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
				id: backButton
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				width: 24 * DefaultStyle.dp
				height: 24 * DefaultStyle.dp
				focus: true
				onClicked: {
					mainItem.goBack()
				}
				background: Item {
					anchors.fill: parent
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
			Layout.topMargin: 41 * DefaultStyle.dp
			Layout.leftMargin: leftPanel.sideMargin
			property int selectedIndex: 0
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
