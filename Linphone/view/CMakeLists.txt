
list(APPEND _LINPHONEAPP_QML_FILES
	view/App/Main.qml
	view/App/Layout/LoginLayout.qml
	view/App/Layout/MainLayout.qml
	
	view/Item/Account/Accounts.qml
	
	view/Item/Button.qml
	view/Item/Carousel.qml
	view/Item/CheckBox.qml
	view/Item/ComboBox.qml
	
	view/Item/Contact/Avatar.qml
	view/Item/Contact/Contact.qml
	view/Item/Contact/ContactDescription.qml
	
	view/Item/DesktopPopup.qml
	view/Item/DigitInput.qml
	
	view/Item/Notification/Notification.qml
	view/Item/Notification/NotificationReceivedCall.qml
	
	view/Item/EffectImage.qml
	view/Item/NumericPad.qml
	view/Item/PhoneNumberComboBox.qml
	view/Item/PhoneNumberInput.qml
	view/Item/Popup.qml
	view/Item/RadioButton.qml
	view/Item/RectangleTest.qml
	view/Item/SearchBar.qml
	view/Item/TabBar.qml
	view/Item/Text.qml
	view/Item/TextInput.qml
	view/Item/ToolTip.qml
	view/Item/VerticalTabBar.qml
	
	view/Item/Form/LoginForm.qml
	
	view/Item/Test/ItemsTest.qml
	
	view/Page/Login/LoginPage.qml
	view/Page/Login/RegisterPage.qml
	view/Page/Login/RegisterCheckingPage.qml
	view/Page/Login/SIPLoginPage.qml
	view/Page/Login/SecurityModePage.qml
	view/Page/Login/WelcomePage.qml
	
	view/Page/Main/AbstractMainPage.qml
	view/Page/Main/CallPage.qml
	# view/Page/Main/OngoingCallPage.qml
	
# Prototypes
	view/Prototype/PhoneNumberPrototype.qml
	view/Prototype/AccountsPrototype.qml
	view/Prototype/CallPrototype.qml
	view/Prototype/FriendPrototype.qml
	view/Prototype/ItemPrototype.qml
)

list(APPEND _LINPHONEAPP_QML_SINGLETONS
	view/Style/AppIcons.qml
	view/Style/DefaultStyle.qml
)

set(_LINPHONEAPP_QML_FILES ${_LINPHONEAPP_QML_FILES} PARENT_SCOPE)
set(_LINPHONEAPP_QML_SINGLETONS ${_LINPHONEAPP_QML_SINGLETONS} PARENT_SCOPE)
