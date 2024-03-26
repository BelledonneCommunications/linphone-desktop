import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone
import UtilsCpp 1.0
import SettingsCpp 1.0

ApplicationWindow {
	id: mainWindow
	width: 1512 * DefaultStyle.dp
	height: 982 * DefaultStyle.dp
	visible: true
	title: qsTr("Linphone")
	// TODO : handle this bool when security mode is implemented
	property bool firstConnection: true

	color: "transparent"

	// TODO : use this to make the border transparent
	// flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowTitleHint
	// menuBar: Rectangle {
	// 	width: parent.width
	// 	height: 40 * DefaultStyle.dp
	// 	color: DefaultStyle.grey_100
	// }

	function goToNewCall() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.goToNewCall()
	}
	function transferCallSucceed() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.transferCallSucceed()
	}

	function showInformationPopup(title, description, isSuccess) {
		var infoPopup = popupComp.createObject(popupLayout, {"title": title, "description": description, "isSuccess": isSuccess})
		// informationPopup.title = title
		// informationPopup.description = description
		// informationPopup.isSuccess = isSuccess
		// infoPopup.y = popupLayout.nextY - infoPopup.height
		infoPopup.index = popupLayout.popupList.length
		popupLayout.popupList.push(infoPopup)
		infoPopup.open()
	}

	Component {
		id: popupComp
		Popup {
			id: informationPopup
			property bool isSuccess: true
			property string title
			property string description
			property int index
			onAboutToShow: {
				autoClosePopup.restart()
			}
			onAboutToHide: {
				popupLayout.popupList.splice(informationPopup.index, 1)
			}
			closePolicy: Popup.NoAutoClose
			x : parent.x + parent.width - width
			// y : parent.y + parent.height - height
			rightMargin: 20 * DefaultStyle.dp
			bottomMargin: 20 * DefaultStyle.dp
			padding: 20 * DefaultStyle.dp
			underlineColor: informationPopup.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
			radius: 0
			onHoveredChanged: {
				if (hovered) autoClosePopup.stop()
				else autoClosePopup.restart()
			}
			Timer {
				id: autoClosePopup
				interval: 5000
				onTriggered: {
					informationPopup.close()
				} 
			}
			contentItem: RowLayout {
				spacing: 15 * DefaultStyle.dp
				EffectImage {
					imageSource: informationPopup.isSuccess ? AppIcons.smiley : AppIcons.smileySad
					colorizationColor: informationPopup.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
					Layout.preferredWidth: 32 * DefaultStyle.dp
					Layout.preferredHeight: 32 * DefaultStyle.dp
					width: 32 * DefaultStyle.dp
					height: 32 * DefaultStyle.dp
				}
				Rectangle {
					Layout.preferredWidth: 1 * DefaultStyle.dp
					Layout.preferredHeight: parent.height
					color: DefaultStyle.main2_200
				}
				ColumnLayout {
					RowLayout {
						Layout.fillWidth: true
						Text {
							Layout.fillWidth: true
							text: informationPopup.title
							color: informationPopup.isSuccess ? DefaultStyle.success_500main : DefaultStyle.danger_500main
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						Button {
							Layout.preferredWidth: 20 * DefaultStyle.dp
							Layout.preferredHeight: 20 * DefaultStyle.dp
							Layout.alignment: Qt.AlignTop | Qt.AlignRight
							visible: informationPopup.hovered || hovered
							background: Item{}
							icon.source: AppIcons.closeX
							onClicked: informationPopup.close()
						}
					}
					Text {
						Layout.alignment: Qt.AlignHCenter
						Layout.fillWidth: true
						Layout.maximumWidth: 300 * DefaultStyle.dp
						text: informationPopup.description
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_500main
						font {
							pixelSize: 12 * DefaultStyle.dp
							weight: 300 * DefaultStyle.dp
						}
					}
				}
			}
		}
	}

	ColumnLayout {
		id: popupLayout
		anchors.fill: parent
		Layout.alignment: Qt.AlignBottom
		property int nextY: mainWindow.height
		property list<Popup> popupList
		property int popupCount: popupList.length
		spacing: 15
		onPopupCountChanged: {
			nextY = mainWindow.height
			for(var i = 0; i < popupCount; ++i) {
				popupList[i].y = nextY - popupList[i].height
				nextY = nextY - popupList[i].height - 15
			}
		}
	}

	AccountProxy {
		// TODO : change this so it does not display the main page for one second
		// when we fail trying to connect the first account (account is added and
		// removed shortly after)
		id: accountProxy
	}
	StackView {
		id: mainWindowStackView
		anchors.fill: parent
		initialItem: accountProxy.haveAccount ? mainPage : SettingsCpp.getFirstLaunch() ? welcomePage : loginPage
	}
	Component {
		id: welcomePage
		WelcomePage {
			onStartButtonPressed: {
				mainWindowStackView.replace(loginPage)// Replacing the first item will destroy the old.
				SettingsCpp.setFirstLaunch(false)
			}
		}
	}
	Component {
		id: loginPage
		LoginPage {
			showBackButton: accountProxy.haveAccount
			onGoBack: mainWindowStackView.replace(mainPage)
			onUseSIPButtonClicked: mainWindowStackView.push(sipLoginPage)
			onGoToRegister: mainWindowStackView.replace(registerPage)
			onConnectionSucceed: {
				mainWindowStackView.replace(mainPage)
			}
		}
	}
	Component {
		id: sipLoginPage
		SIPLoginPage {
			onGoBack: mainWindowStackView.pop()
			onGoToRegister: mainWindowStackView.replace(registerPage)
			
			onConnectionSucceed: {
				mainWindowStackView.replace(mainPage)
			}
		}
	}
	Component {
		id: registerPage
		RegisterPage {
			onReturnToLogin: mainWindowStackView.replace(loginPage)
			onRegisterCalled: (countryCode, phoneNumber, email) => {
				mainWindowStackView.push(checkingPage, {"phoneNumber": phoneNumber, "email": email})
			}
		}
	}
	Component {
		id: checkingPage
		RegisterCheckingPage {
			onReturnToRegister: mainWindowStackView.pop()
		}
	}
	Component {
		id: securityModePage
		SecurityModePage {
			id: securePage
			onModeSelected: (index) => {
				// TODO : connect to cpp part when ready
				var selectedMode = index == 0 ? "chiffrement" : "interoperable"
				console.debug("[SelectMode]User: User selected mode " + selectedMode)
				mainWindowStackView.replace(mainPage)
			}
		}
	}
	Component {
		id: mainPage
		MainLayout {
			onAddAccountRequest: mainWindowStackView.replace(loginPage)
			// StackView.onActivated: connectionSecured(0) // TODO : connect to cpp part when ready
		}
	}
}
