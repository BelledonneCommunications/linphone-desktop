import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Basic
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

AbstractWindow {
	id: mainWindow
    // height: Math.round(982 * DefaultStyle.dp)
    title: applicationName
	// TODO : handle this bool when security mode is implemented
	property bool firstConnection: true
    property int initialWidth
    property int initialHeight
    Component.onCompleted: {
        initialWidth = width
        initialHeight = height
    }

	color: DefaultStyle.grey_0
    minimumWidth: Math.round(1020 * DefaultStyle.dp)
    minimumHeight: Math.round(700 * DefaultStyle.dp)

	signal callCreated()
	property var accountProxy

	// TODO : use this to make the border transparent
	// flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowTitleHint
	// menuBar: Rectangle {
	// 	width: parent.width
    // 	height: Math.round(40 * DefaultStyle.dp)
	// 	color: DefaultStyle.grey_100
	// }

	function openMainPage(connectionSucceed){
		if (mainWindowStackView.currentItem.objectName !== "mainPage") mainWindowStackView.replace(mainPage, StackView.Immediate)
        //: "Connexion réussie"
        if (connectionSucceed) mainWindow.showInformationPopup(qsTr("information_popup_connexion_succeed_title"),
                                                               //: "Vous êtes connecté en mode %1"
                                                               qsTr("information_popup_connexion_succeed_message").arg(
                                                               //: interopérable
                                                               qsTr("interoperable")))
	}
	function goToCallHistory() {
		openMainPage()
		mainWindowStackView.currentItem.goToCallHistory()
	}
	function goToNewCall() {
		openMainPage()
		mainWindowStackView.currentItem.goToNewCall()
	}
	function displayContactPage(contactAddress) {
		openMainPage()
		mainWindowStackView.currentItem.displayContactPage(contactAddress)
	}
	function displayChatPage(contactAddress) {
		openMainPage()
		mainWindowStackView.currentItem.displayChatPage(contactAddress)
	}
	function transferCallSucceed() {
		openMainPage()
        //: "Appel transféré"
        mainWindow.showInformationPopup(qsTr("call_transfer_successful_toast_title"),
                                        //: "Votre correspondant a été transféré au contact sélectionné"
                                        qsTr("call_transfer_successful_toast_message"))
	}
	function initStackViewItem() {
        if(accountProxy && accountProxy.isInitialized) {
            if (accountProxy.haveAccount) openMainPage()
            else if (SettingsCpp.getFirstLaunch()) mainWindowStackView.replace(welcomePage, StackView.Immediate)
            else if (SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin) mainWindowStackView.replace(sipLoginPage, StackView.Immediate)
            else mainWindowStackView.replace(loginPage, StackView.Immediate)
        }
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
			onOpened: mainWindow.authenticationPopupOpened = true
			onClosed: {
				mainWindow.authenticationPopupOpened = false
				destroy()
			}
		}
	}

	function reauthenticateAccount(identity, domain, callback){
		if (authenticationPopupOpened) return
		if (mainWindowStackView.currentItem.objectName === "loginPage" 
		|| mainWindowStackView.currentItem.objectName === "sipLoginPage")
			return
		console.log("Showing authentication dialog")
		var popup = authenticationPopupComp.createObject(mainWindow, {"identity": identity, "domain": domain, "callback":callback})	// Callback ownership is not passed
		popup.open()
	}

	Connections {
		target: SettingsCpp
		function onAssistantGoDirectlyToThirdPartySipAccountLoginChanged() {
            initStackViewItem()
		}
		function onIsSavedChanged() {
            if (SettingsCpp.isSaved) UtilsCpp.showInformationPopup(qsTr("information_popup_success_title"),
                                                                   //: "Les changements ont été sauvegardés"
                                                                   qsTr("information_popup_changes_saved"), true, mainWindow)
        }
	}

	Connections {
		target: LoginPageCpp
		function onRegistrationStateChanged() {
			if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
				openMainPage(true)
				proposeH264CodecsDownload()
			}
		}
	}

	Loader {
		id: accountProxyLoader
		active: AppCpp.coreStarted
		sourceComponent: AccountProxy {
			sourceModel: AppCpp.accounts
            onInitializedChanged: if (isInitialized) {
				mainWindow.accountProxy = this
				mainWindow.initStackViewItem()
            }
		}
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
                sourceSize.width: Math.round(395 * DefaultStyle.dp)
                sourceSize.height: Math.round(395 * DefaultStyle.dp)
                width: Math.round(395 * DefaultStyle.dp)
                height: Math.round(395 * DefaultStyle.dp)
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
			objectName: "loginPage"
			onGoBack: openMainPage()
			onUseSIPButtonClicked: mainWindowStackView.push(sipLoginPage)
			onGoToRegister: mainWindowStackView.replace(registerPage)
            showBackButton: false
            StackView.onActivated: if (mainWindow.accountProxy?.haveAccount) showBackButton = true
		}
	}
	Component {
		id: sipLoginPage
		SIPLoginPage {
			objectName: "sipLoginPage"
			onGoBack: {
				if(SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin){
					openMainPage()
				}else
					mainWindowStackView.pop()
			}
			onGoToRegister: mainWindowStackView.replace(registerPage)
            showBackButton: false
            StackView.onActivated: if (!SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin || mainWindow.accountProxy?.haveAccount) showBackButton = true
		}
	}
	Component {
		id: registerPage
		RegisterPage {
			onReturnToLogin: goToLogin()
            //: "Veuillez valider le captcha sur la page web"
            onBrowserValidationRequested: mainWindow.showLoadingPopup(qsTr("captcha_validation_loading_message"), true)
			Connections {
				target: RegisterPageCpp
				function onNewAccountCreationSucceed(withEmail, address, sipIdentityAddress) {
					mainWindowStackView.push(checkingPage, {"registerWithEmail": withEmail, "address": address, "sipIdentityAddress": sipIdentityAddress})
				}
				function onRegisterNewAccountFailed(errorMessage) {
                    //: "Erreur lors de la création"
                    mainWindow.showInformationPopup(qsTr("assistant_register_error_title"), errorMessage, false)
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
                    //: "Compte créé"
                    mainWindow.showInformationPopup(qsTr("assistant_register_success_title"),
                                                    //: "Le compte a été créé. Vous pouvez maintenant vous connecter"
                                                    qsTr("assistant_register_success_message"), true)
				}
				function onLinkingNewAccountWithCodeFailed(errorMessage) {
                    //: "Erreur dans le code de validation"
                    if (errorMessage.length === 0) errorMessage = qsTr("assistant_register_error_code")
                    mainWindow.showInformationPopup(qsTr("information_popup_error_title"), errorMessage, false)
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
				openMainPage()
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

	// H264 Cisco codec download
	PayloadTypeProxy {
		id: downloadableVideoPayloadTypeProxy
		filterType: PayloadTypeProxy.Video | PayloadTypeProxy.Downloadable
	}
	Repeater {
		id: codecDownloader
		model: null
		Item {
			Component.onCompleted: {
				if (modelData.core.mimeType == "H264")
					Utils.openCodecOnlineInstallerDialog(mainWindow, modelData.core)
			}
		}
	}
	function proposeH264CodecsDownload() {
		codecDownloader.model = downloadableVideoPayloadTypeProxy
	}

}
