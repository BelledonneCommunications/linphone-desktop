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

	function removeFromPopupLayout(index) {
		popupLayout.popupList.splice(index, 1)
	}

	Component {
		id: popupComp
		InformationPopup{}
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
