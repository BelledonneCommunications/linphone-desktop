import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone
import UtilsCpp 1.0
import SettingsCpp 1.0

ApplicationWindow {
	id: mainWindow

	Component {
		id: popupComp
		InformationPopup{}
	}

	Component{
		id: confirmPopupComp
		Dialog {
			property var requestDialog
			property int index
			signal closePopup(int index)
			onClosed: closePopup(index)
			text: requestDialog.message
			details: requestDialog.details
			onAccepted: requestDialog.result(1)
			onRejected: requestDialog.result(0)
			width: 278 * DefaultStyle.dp
		}
	}

	function removeFromPopupLayout(index) {
		popupLayout.popupList.splice(index, 1)
	}
	function showInformationPopup(title, description, isSuccess) {
		var infoPopup = popupComp.createObject(popupLayout, {"title": title, "description": description, "isSuccess": isSuccess})
		infoPopup.index = popupLayout.popupList.length
		popupLayout.popupList.push(infoPopup)
		infoPopup.open()
		infoPopup.closePopup.connect(removeFromPopupLayout)
	}
	function showLoadingPopup(text) {
		loadingPopup.text = text
		loadingPopup.open()
	}
	function closeLoadingPopup() {
		loadingPopup.close()
	}

	function showConfirmationPopup(requestDialog){
		console.log("Showing confirmation popup")
		var popup = confirmPopupComp.createObject(popupLayout, {"requestDialog": requestDialog})
		popup.index = popupLayout.popupList.length
		popupLayout.popupList.push(popup)
		popup.open()
		popup.closePopup.connect(removeFromPopupLayout)
	}

	ColumnLayout {
		id: popupLayout
		anchors.fill: parent
		Layout.alignment: Qt.AlignBottom
		property int nextY: mainWindow.height
		property list<InformationPopup> popupList
		property int popupCount: popupList.length
		spacing: 15 * DefaultStyle.dp
		onPopupCountChanged: {
			nextY = mainWindow.height
			for(var i = 0; i < popupCount; ++i) {
				popupList[i].y = nextY - popupList[i].height
				popupList[i].index = i
				nextY = nextY - popupList[i].height - 15
			}
		}
	}

	LoadingPopup {
		id: loadingPopup
		modal: true
		closePolicy: Popup.NoAutoClose
		anchors.centerIn: parent
		padding: 20 * DefaultStyle.dp
		underlineColor: DefaultStyle.main1_500_main
		radius: 15 * DefaultStyle.dp
	}
}
