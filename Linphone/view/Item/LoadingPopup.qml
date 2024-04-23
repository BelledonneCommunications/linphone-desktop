import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone

Popup {
	id: mainItem
	property string text
	modal: true
	closePolicy: Control.Popup.NoAutoClose
	anchors.centerIn: parent
	padding: 20 * DefaultStyle.dp
	underlineColor: DefaultStyle.main1_500_main
	radius: 15 * DefaultStyle.dp
	// onAboutToShow: width = contentText.implicitWidth
	contentItem: ColumnLayout {
		spacing: 15 * DefaultStyle.dp
		BusyIndicator{
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 33 * DefaultStyle.dp
			Layout.preferredHeight: 33 * DefaultStyle.dp
		}
		Text {
			id: contentText
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			Layout.fillHeight: true
			text: mainItem.text
			font.pixelSize: 14 * DefaultStyle.dp
		}
	}
}