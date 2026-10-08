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
	property Item focusBeforeOpen: null
	function announceText() {
		if (mainItem.text.length > 0)
			contentLayout.Accessible.announce(mainItem.text, Accessible.Assertive)
	}
	function focusCancelButton() {
		if (cancelButton.activeFocus)
			return
		if (!mainItem.focusBeforeOpen)
			mainItem.focusBeforeOpen = contentLayout.Window.activeFocusItem
		cancelButton.forceActiveFocus(Qt.PopupFocusReason)
	}
	onOpened: {
		if (mainItem.cancelButtonVisible)
			mainItem.focusCancelButton()
		else
			mainItem.announceText()
	}
	onCancelButtonVisibleChanged: if (mainItem.opened && mainItem.cancelButtonVisible) mainItem.focusCancelButton()
	onTextChanged: if (mainItem.opened) mainItem.announceText()
	onClosed: {
		var previous = mainItem.focusBeforeOpen
		mainItem.focusBeforeOpen = null
		if (previous && previous.visible && previous.enabled)
			previous.forceActiveFocus(Qt.OtherFocusReason)
	}
	modal: true
	closePolicy: Control.Popup.NoAutoClose
	anchors.centerIn: parent
    padding: Utils.getSizeWithScreenRatio(20)
	underlineColor: DefaultStyle.main1_500_main
    radius: Utils.getSizeWithScreenRatio(15)
	// onAboutToShow: width = contentText.implicitWidth
	contentItem: ColumnLayout {
		id: contentLayout
		Accessible.role: Accessible.Dialog
		Accessible.name: mainItem.text
        spacing: Utils.getSizeWithScreenRatio(15)
		// width: childrenRect.width
		// height: childrenRect.height
		BusyIndicator{
			Layout.alignment: Qt.AlignHCenter
			width: Utils.getSizeWithScreenRatio(33)
			height: width
            Layout.preferredWidth: width
            Layout.preferredHeight: width
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
			id: cancelButton
			visible: mainItem.cancelButtonVisible
			Accessible.name: mainItem.text.length > 0 ? mainItem.text + ", " + cancelButton.text : cancelButton.text
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
