import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Popup {
	id: mainItem
	property string text
	property bool cancelButtonVisible: false
	property var callback
	modal: true
	closePolicy: Control.Popup.NoAutoClose
	anchors.centerIn: parent
    padding: Math.round(20 * DefaultStyle.dp)
	underlineColor: DefaultStyle.main1_500_main
    radius: Math.round(15 * DefaultStyle.dp)
	// onAboutToShow: width = contentText.implicitWidth
	contentItem: ColumnLayout {
        spacing: Math.round(15 * DefaultStyle.dp)
		// width: childrenRect.width
		// height: childrenRect.height
		BusyIndicator{
			Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.round(33 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(33 * DefaultStyle.dp)
		}
		Text {
			id: contentText
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			Layout.fillHeight: true
			text: mainItem.text
            font.pixelSize: Math.round(14 * DefaultStyle.dp)
		}
		MediumButton {
			visible: mainItem.cancelButtonVisible
			Layout.alignment: Qt.AlignHCenter
            text: qsTr("cancel")
			style: ButtonStyle.main
			onClicked: {
				if (callback) mainItem.callback()
				mainItem.close()
			}
		}
	}
}
