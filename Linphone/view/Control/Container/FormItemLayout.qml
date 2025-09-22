import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

FocusScope{
	id: mainItem
	property alias contentItem: contentItem.data
	property string label: ""
	property string tooltip: ""
	property bool mandatory: false

	property alias errorTextItem: errorText
	property alias errorMessage: errorText.text
	property bool enableErrorText: false
	property bool errorTextVisible: errorText.isVisible
	implicitHeight: layout.implicitHeight

	function clearErrorText() {
		errorText.clear()
	}

	onErrorMessageChanged: if (errorMessage.length > 0) {
		var item = mainItem
		do {
			var parentItem = item.parent 
			if (parentItem.contentItem) {
                var itemPosInParent = mainItem.mapToItem(parentItem.contentItem, mainItem.x, mainItem.y)
                if (parentItem.contentY > itemPosInParent.y) {
                    parentItem.contentY = itemPosInParent.y;
                }
                else if (parentItem.contentY+parentItem.height < itemPosInParent.y+mainItem.height) {
                    parentItem.contentY = itemPosInParent.y + mainItem.height - height;
                }
			}
			item = parentItem
		} while(item.parent != undefined && parentItem.contentItem === undefined)
	}

	ColumnLayout {
		id: layout
        spacing: Math.round(5 * DefaultStyle.dp)
		anchors.left: parent.left
		anchors.right: parent.right
		RowLayout {
        	spacing: Math.round(8 * DefaultStyle.dp)
			Text {
				visible: label.length > 0
				verticalAlignment: Text.AlignVCenter
				text: mainItem.label + (mainItem.mandatory ? "*" : "")
				color: contentItem.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
				elide: Text.ElideRight
				wrapMode: Text.Wrap
				maximumLineCount: 1
				textFormat: Text.RichText
		
				font {
					pixelSize: Typography.p2.pixelSize
					weight: Typography.p2.weight
				}
			}
			Item{Layout.fillWidth: true}
			PopupButton {
				visible: mainItem.tooltip !== ""
				Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
				Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
				style: ButtonStyle.noBackground
				icon.source: AppIcons.info
				popUpTitle: mainItem.label
				popup.contentItem: Text {
					text: mainItem.tooltip
				}
			}
		}
	
		Item {
			Layout.preferredHeight: childrenRect.height
			Layout.fillWidth: true
			StackLayout {
				id: contentItem
				height: childrenRect.height
				anchors.left: parent.left
				anchors.right: parent.right
			}
			TemporaryText {
				id: errorText
				anchors.top: contentItem.bottom
				color: DefaultStyle.danger_500_main
			}
		}
	
	}
}
