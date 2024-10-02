import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Basic
import Linphone
import UtilsCpp 1.0
import SettingsCpp 1.0
import LinphoneAccountsCpp

AbstractWindow {
	id: mainWindow
    // height: 982 * DefaultStyle.dp
	title: qsTr("Linphone")
	// TODO : handle this bool when security mode is implemented
	property bool firstConnection: true

	color: "transparent"

	signal callCreated()

	// TODO : use this to make the border transparent
	// flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowTitleHint
	// menuBar: Rectangle {
	// 	width: parent.width
	// 	height: 40 * DefaultStyle.dp
	// 	color: DefaultStyle.grey_100
	// }

	function goToCallHistory() {
		console.log("go to call history")
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.goToCallHistory()
	}
	function goToNewCall() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.goToNewCall()
	}
	function displayContactPage(contactAddress) {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		mainWindowStackView.currentItem.displayContactPage(contactAddress)
	}
	function transferCallSucceed() {
		mainWindowStackView.replace(mainPage, StackView.Immediate)
		UtilsCpp.showInformationPopup(qsTr("Appel transféré"), qsTr("Votre correspondant a été transféré au contact sélectionné"))
	}
	function initStackViewItem() {
		if (accountProxy.haveAccount) mainWindowStackView.replace(mainPage, StackView.Immediate)
		else if (SettingsCpp.getFirstLaunch()) mainWindowStackView.replace(welcomePage, StackView.Immediate)
		else if (SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin) mainWindowStackView.replace(sipLoginPage, StackView.Immediate)
		else mainWindowStackView.replace(loginPage, StackView.Immediate)
	}
	
	function goToLogin() {
		if (SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin)
			mainWindowStackView.replace(sipLoginPage)
		else
			mainWindowStackView.replace(loginPage)
	}

	property bool authenticationPopupOpened: false
	Component {
		id: authenticationPopupComp
		AuthenticationDialog{
			property var authenticationDialog
			property var callback: authenticationDialog.result
			identity: authenticationDialog.username
			domain: authenticationDialog.domain
			onAccepted: {
				authenticationDialog ? authenticationDialog.result(password) : callback(password)
				close()
			}
			onOpened: mainWindow.authenticationPopupOpened = true
			onClosed: mainWindow.authenticationPopupOpened = false
		}
	}

	function reauthenticateAccount(authenticationDialog){
		if (mainWindowStackView.currentItem.objectName !== "mainPage") return
		if (authenticationPopupOpened) return
		console.log("Showing authentication dialog")
		var popup = authenticationPopupComp.createObject(mainWindow, {"authenticationDialog": authenticationDialog})
		popup.open()
	}

	Connections {
		target: SettingsCpp
		function onAssistantGoDirectlyToThirdPartySipAccountLoginChanged() {
			initStackViewItem()
		}
	}

	AccountProxy  {
		id: accountProxy
		onInitialized: initStackViewItem()
	}

	StackView {
		id: mainWindowStackView
		anchors.fill: parent
		initialItem: splashScreen
	}
	Component {
		id: splashScreen
		Rectangle {
			color: DefaultStyle.grey_0
			Image {
				anchors.centerIn: parent
				source: AppIcons.splashscreenLogo
			}
		}
	}
	Component {
		id: welcomePage
		WelcomePage {
			onStartButtonPressed: {
				goToLogin() // Replacing the first item will destroy the old.
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
			onGoBack: {
				if(SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin)
					mainWindowStackView.replace(mainPage)
				else
					mainWindowStackView.pop()
			}
			onGoToRegister: mainWindowStackView.replace(registerPage)
			
			onConnectionSucceed: {
				mainWindowStackView.replace(mainPage)
			}
		}
	}
	Component {
		id: registerPage
		RegisterPage {
			onReturnToLogin: goToLogin()
			onBrowserValidationRequested: mainWindow.showLoadingPopup(qsTr("Veuillez valider le captcha sur la page web"), true)
			Connections {
				target: RegisterPageCpp
				function onNewAccountCreationSucceed(withEmail, address, sipIdentityAddress) {
					mainWindowStackView.push(checkingPage, {"registerWithEmail": withEmail, "address": address, "sipIdentityAddress": sipIdentityAddress})
				}
				function onRegisterNewAccountFailed(errorMessage) {
					mainWindow.showInformationPopup(qsTr("Erreur lors de la création"), errorMessage, false)
					mainWindow.closeLoadingPopup()
				}
				function onTokenConversionSucceed(){ mainWindow.closeLoadingPopup()}
			}
		}
	}
	Component {
		id: checkingPage
		RegisterCheckingPage {
			onReturnToRegister: mainWindowStackView.pop()
			onSendCode: (code) => {
				RegisterPageCpp.linkNewAccountUsingCode(code, registerWithEmail, sipIdentityAddress)
			}
			Connections {
				target: RegisterPageCpp
				function onLinkingNewAccountWithCodeSucceed() {
					goToLogin()
					mainWindow.showInformationPopup(qsTr("Compte créé"), qsTr("Le compte a été créé avec succès. Vous pouvez maintenant vous connecter"), true)
				}
				function onLinkingNewAccountWithCodeFailed(errorMessage) {
					if (errorMessage.length === 0) errorMessage = qsTr("Erreur dans le code de validation")
					mainWindow.showInformationPopup(qsTr("Erreur"), errorMessage, false)
				}
			}
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
			id: mainLayout
			objectName: "mainPage"
			onAddAccountRequest: goToLogin()
			onAccountRemoved: {
				initStackViewItem()
			}
			Connections {
				target: mainWindow
				function onCallCreated(){ mainLayout.callCreated() }
			}
			// StackView.onActivated: connectionSecured(0) // TODO : connect to cpp part when ready
		}
	}
}
