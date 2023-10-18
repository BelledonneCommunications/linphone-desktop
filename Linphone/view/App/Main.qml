import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls
import Linphone
//import UI 1.0

Window {
	id: mainWindow
	width: 960
	height: 600
	visible: true
	title: qsTr("Linphone")
	
	StackView {
		id: mainWindowStackView
		anchors.fill: parent
		initialItem: welcomePage
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
			onUseSIPButtonClicked: mainWindowStackView.push(sipLoginPage)
			onGoToRegister: mainWindowStackView.replace(registerPage)
		}
	}
	Component {
		id: sipLoginPage
		SIPLoginPage {
			onReturnToLogin: mainWindowStackView.pop()
			onGoToRegister: mainWindowStackView.replace(registerPage)
		}
	}
	Component {
		id: registerPage
		RegisterPage {
			onReturnToLogin: mainWindowStackView.replace(loginPage)
			onRegisterCalled: mainWindowStackView.push(checkingPage)
		}
	}
	Component {
		id: checkingPage
		RegisterCheckingPage {
			onReturnToRegister: mainWindowStackView.pop()
		}
	}
} 
 
