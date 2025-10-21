import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Popup {
	id: mainItem
	property string text
	property bool cancelButtonVisible: false
	property var callback
	modal: true
	closePolicy: Control.Popup.NoAutoClose
	anchors.centerIn: parent
    padding: Utils.getSizeWithScreenRatio(20)
	underlineColor: DefaultStyle.main1_500_main
    radius: Utils.getSizeWithScreenRatio(15)
	// onAboutToShow: width = contentText.implicitWidth
	contentItem: ColumnLayout {
        spacing: Utils.getSizeWithScreenRatio(15)
		// width: childrenRect.width
		// height: childrenRect.height
		BusyIndicator{
			Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(33)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(33)
		}
		Text {
			id: contentText
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			Layout.fillHeight: true
			text: mainItem.text
            font.pixelSize: Utils.getSizeWithScreenRatio(14)
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
