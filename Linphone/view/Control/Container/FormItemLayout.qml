import QtQuick
import QtQuick.Controls.Basic as Control
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
	property bool errorTextVisible: errorText.text.length > 0
	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

	function clearErrorText() {
		errorText.clear()
	}
	ColumnLayout {
		id: layout
		spacing: 5 * DefaultStyle.dp
	
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
				pixelSize: 13 * DefaultStyle.dp
				weight: 700 * DefaultStyle.dp
			}
		}
	
		Item {
			Layout.preferredHeight: contentItem.height
			Layout.preferredWidth: contentItem.width
			Item {
				id: contentItem
				height: childrenRect.height
				width: childrenRect.width
			}
			TemporaryText {
				id: errorText
				anchors.top: contentItem.bottom
				color: DefaultStyle.danger_500main
				Layout.preferredWidth: implicitWidth
			}
		}
	
	}
}
