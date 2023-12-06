import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone
//import UI 1.0

Window {
	id: mainWindow
	width: 1512 * DefaultStyle.dp
	height: 982 * DefaultStyle.dp
	visible: true
	title: qsTr("Linphone")
	property bool firstConnection: true
	AccountProxy{
		id: accountProxy
		onHaveAccountChanged: {
			if(haveAccount)
				mainWindowStackView.replace(mainPage)
			else
				mainWindowStackView.replace(loginPage)
		}
	}
	StackView {
		id: mainWindowStackView
		anchors.fill: parent
		initialItem: accountProxy.haveAccount ? mainPage : welcomePage
	}
	Component {
		id: welcomePage
		WelcomePage {
			onStartButtonPressed: {
				mainWindowStackView.replace(loginPage)// Replacing the first item will destroy the old.
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
				if (mainWindow.firstConnection) {
					mainWindowStackView.replace(securityModePage)
				} else {
					mainWindowStackView.replace(mainPage)
				}
			}
		}
	}
	Component {
		id: sipLoginPage
		SIPLoginPage {
			onGoBack: mainWindowStackView.pop()
			onGoToRegister: mainWindowStackView.replace(registerPage)
			
			onConnectionSucceed: {
				if (mainWindow.firstConnection) {
					mainWindowStackView.replace(securityModePage)
				} else {
					mainWindowStackView.replace(mainPage)
				}
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
			onModeSelected: (index) => {
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
		}
	}
} 
 
