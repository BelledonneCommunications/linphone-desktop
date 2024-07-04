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
			property var callback: requestDialog?.result
			signal closePopup(int index)
			onClosed: closePopup(index)
			text: requestDialog.message
			details: requestDialog.details
			// For C++, requestDialog need to be call directly
			onAccepted: requestDialog ? requestDialog.result(1) : callback(1)
			onRejected: requestDialog ? requestDialog.result(0) : callback(0)
			width: 278 * DefaultStyle.dp
		}
	}

	Popup {
		id: startCallPopup
		property FriendGui contact
		property bool videoEnabled
		onContactChanged: {
			console.log("contact changed", contact)
		}
		underlineColor: DefaultStyle.main1_500_main
		anchors.centerIn: parent
		width: 370 * DefaultStyle.dp
		modal: true
		leftPadding: 15 * DefaultStyle.dp
		rightPadding: 15 * DefaultStyle.dp
		topPadding: 20 * DefaultStyle.dp
		bottomPadding: 25 * DefaultStyle.dp
		contentItem: ColumnLayout {
			spacing: 16 * DefaultStyle.dp
			RowLayout {
				spacing: 0
				Text {
					text: qsTr("Which channel do you choose?")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Item{Layout.fillWidth: true}
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					Layout.alignment: Qt.AlignVCenter
					background: Item{}
					icon.source:AppIcons.closeX
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					contentItem: Image {
						anchors.fill: parent
						source: AppIcons.closeX
					}
					onClicked: startCallPopup.close()
				}
			}
			ListView {
				id: popuplist
				model: VariantList {
					model: startCallPopup.contact && startCallPopup.contact.core.allAddresses || []
				}
				Layout.fillWidth: true
				Layout.preferredHeight: contentHeight
				spacing: 10 * DefaultStyle.dp
				delegate: Item {
					width: popuplist.width
					height: 56 * DefaultStyle.dp
					ColumnLayout {
						width: popuplist.width
						anchors.verticalCenter: parent.verticalCenter
						spacing: 10 * DefaultStyle.dp
						ColumnLayout {
							spacing: 7 * DefaultStyle.dp
							Text {
								Layout.leftMargin: 5 * DefaultStyle.dp
								text: modelData.label + " :"
								font {
									pixelSize: 13 * DefaultStyle.dp
									weight: 700 * DefaultStyle.dp
								}
							}
							Text {
								Layout.leftMargin: 5 * DefaultStyle.dp
								text: modelData.address
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
						}
						Rectangle {
							visible: index != popuplist.model.count - 1
							Layout.fillWidth: true
							Layout.preferredHeight: 1 * DefaultStyle.dp
							color: DefaultStyle.main2_200
						}
					}
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
						onClicked: UtilsCpp.createCall(modelData.address, {'localVideoEnabled': startCallPopup.videoEnabled})
					}
				}
			}
		}
	}

	function startCallWithContact(contact, videoEnabled, parentItem) {
		if (parentItem == undefined) parentItem = mainWindow
		startCallPopup.parent = parentItem
		if (contact) {
			console.log("START CALL WITH", contact.core.displayName, "addresses count", contact.core.allAddresses.length)
			if (contact.core.allAddresses.length > 1) {
				startCallPopup.contact = contact
				startCallPopup.videoEnabled = videoEnabled
				startCallPopup.open()

			} else {
				var addressToCall = contact.core.defaultAddress.length === 0 
					? contact.core.phoneNumbers.length === 0
						? ""
						: contact.core.phoneNumbers[0].address
					: contact.core.defaultAddress
				if (addressToCall.length != 0) UtilsCpp.createCall(addressToCall, {'localVideoEnabled':videoEnabled})
			}
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
	function showLoadingPopup(text, cancelButtonVisible) {
		if (cancelButtonVisible == undefined) cancelButtonVisible = false
		loadingPopup.text = text
		loadingPopup.cancelButtonVisible = cancelButtonVisible
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
	
	function showConfirmationLambdaPopup(title,details,callback){
		console.log("Showing confirmation popup")
		var popup = confirmPopupComp.createObject(popupLayout, {"text": title, "details":details,"callback":callback})
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
