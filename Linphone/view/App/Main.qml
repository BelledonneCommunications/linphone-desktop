import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone
import UtilsCpp 1.0
import SettingsCpp 1.0

Window {
	id: mainWindow
	width: 1512 * DefaultStyle.dp
	height: 982 * DefaultStyle.dp
	visible: true
	title: qsTr("Linphone")
	// TODO : handle this bool when security mode is implemented
	property bool firstConnection: true

	// access window properties from all its children
	// (used in popupbutton to see if the popup exceed window height)
	property Window mainApplicationWindow: mainWindow

	function goToNewCall() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.goToNewCall()
	}
	function transferCallSucceed() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.transferCallSucceed()
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
