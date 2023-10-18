
list(APPEND _LINPHONEAPP_QML_FILES
	view/App/Main.qml
	view/App/Layout/LoginLayout.qml
	
	view/Item/Button.qml
	view/Item/Carousel.qml
	view/Item/CheckBox.qml
	view/Item/ComboBox.qml
	view/Item/DigitInput.qml
	view/Item/PhoneNumberComboBox.qml
	view/Item/PhoneNumberInput.qml
	view/Item/RectangleTest.qml
	view/Item/TabBar.qml
	view/Item/Text.qml
	view/Item/TextInput.qml
	
	view/Item/Form/LoginForm.qml

	view/Page/Login/LoginPage.qml
	view/Page/Login/RegisterPage.qml
	view/Page/Login/SIPLoginPage.qml
	view/Page/Login/RegisterCheckingPage.qml
	view/Page/Login/WelcomePage.qml
	
# Prototypes
	view/Prototype/PhoneNumberPrototype.qml
	view/Prototype/AccountsPrototype.qml
)

list(APPEND _LINPHONEAPP_QML_SINGLETONS
	view/Style/AppIcons.qml
	view/Style/DefaultStyle.qml
)

set(_LINPHONEAPP_QML_FILES ${_LINPHONEAPP_QML_FILES} PARENT_SCOPE)
set(_LINPHONEAPP_QML_SINGLETONS ${_LINPHONEAPP_QML_SINGLETONS} PARENT_SCOPE)
