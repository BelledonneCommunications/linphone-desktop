import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Linphone

Popup {
	id: mainItem
	property string text
	property bool cancelButtonVisible: false
	modal: true
	closePolicy: Control.Popup.NoAutoClose
	anchors.centerIn: parent
	padding: 20 * DefaultStyle.dp
	underlineColor: DefaultStyle.main1_500_main
	radius: 15 * DefaultStyle.dp
	// onAboutToShow: width = contentText.implicitWidth
	contentItem: ColumnLayout {
		spacing: 15 * DefaultStyle.dp
		// width: childrenRect.width
		// height: childrenRect.height
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
		Button {
			visible: mainItem.cancelButtonVisible
			Layout.alignment: Qt.AlignHCenter
			text: qsTr("Annuler")
			onClicked: mainItem.close()
		}
	}
}
