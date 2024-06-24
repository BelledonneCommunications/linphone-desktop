import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import Linphone
  
ColumnLayout {
	id: mainItem
	property alias contentItem: contentItem.data
	property string label: ""
	property bool mandatory: false

	property alias errorMessage: errorText.text
	property bool enableErrorText: false
	property bool errorTextVisible: errorText.opacity > 0
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
		ErrorText {
			id: errorText
			anchors.top: contentItem.bottom
			color: DefaultStyle.danger_500main
			Layout.preferredWidth: implicitWidth
		}
	}

}