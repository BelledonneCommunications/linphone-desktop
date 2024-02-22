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

	property string errorMessage: ""
	property bool enableErrorText: false
	property bool errorTextVisible: errorText.opacity > 0

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: contentItem.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		maximumLineCount: 1

		font {
			pixelSize: 13 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
		}
	}

	Item {
		id: contentItem
		Layout.preferredHeight: childrenRect.height
		Layout.preferredWidth: childrenRect.width
	}

	ErrorText {
		id: errorText
		visible: mainItem.enableErrorText
		text: mainItem.errorMessage
		Layout.preferredWidth: implicitWidth
	}
}
