import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
FocusScope{
	id: mainItem
	property alias contentItem: contentItem.data
	property string label: ""
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
				if (parentItem.contentY >= mainItem.y)
					parentItem.contentY = mainItem.y;
				else if (parentItem.contentY+height <= mainItem.y+mainItem.height)
					parentItem.contentY = mainItem.y + mainItem.height - height;
			}
			item = parentItem
		} while(item.parent != undefined && parentItem.contentItem === undefined)
	}

	ColumnLayout {
		id: layout
        spacing: Math.round(5 * DefaultStyle.dp)
		anchors.left: parent.left
		anchors.right: parent.right
	
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
				color: DefaultStyle.danger_500main
			}
		}
	
	}
}
