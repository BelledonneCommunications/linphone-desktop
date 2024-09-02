
list(APPEND _LINPHONEAPP_QML_FILES
	view/App/Main.qml
	view/App/CallsWindow.qml
	view/App/AppWindow.qml
	view/App/Layout/LoginLayout.qml
	view/App/Layout/MainLayout.qml
	
	view/Layout/Call/ActiveSpeakerLayout.qml
	view/Layout/Call/CallLayout.qml
	view/Layout/Call/GridLayout.qml
	
	view/Layout/Contact/ContactLayout.qml
	view/Layout/Meeting/AddParticipantsLayout.qml

	view/Layout/FormItemLayout.qml
	view/Layout/ValidatedTextField.qml
	view/Layout/Mosaic.qml
	view/Layout/RightPanelLayout.qml
	view/Layout/Section.qml
	
	view/App/Layout/AbstractDetailsLayout.qml
	view/App/Layout/Settings/SecuritySettingsLayout.qml
	view/App/Layout/Settings/CallSettingsLayout.qml
	view/App/Layout/Settings/DebugSettingsLayout.qml
	
	view/App/Layout/Account/AccountSettingsGeneralLayout.qml
	view/App/Layout/Account/AccountSettingsParametersLayout.qml

	view/Item/Account/Accounts.qml
	view/Item/Account/AuthenticationDialog.qml
	
	view/Item/Call/CallContactsLists.qml
	view/Item/Call/InCallSettingsPanel.qml
	view/Item/Call/OngoingCallRightPanel.qml
	view/Item/Call/WaitingRoom.qml

	view/Item/Call/Menu/ScreencastPanel.qml
	
	view/Item/Notification/Notification.qml
	view/Item/Notification/NotificationReceivedCall.qml
	view/Item/Notification/TemporaryNotification.qml

	view/Item/Participant/ParticipantDeviceListView.qml
	view/Item/Participant/ParticipantListView.qml

	view/Item/Prototype/CanvasCircle.qml
	
	view/Item/Contact/Avatar.qml
	view/Item/Contact/Contact.qml
	view/Item/Contact/ContactDescription.qml
	view/Item/Contact/ContactEdition.qml
	view/Item/Contact/ContactsList.qml
	view/Item/Contact/Sticker.qml

	view/Item/Meeting/MeetingList.qml
	view/Item/Meeting/MeetingSetUp.qml
	
	view/Item/BusyIndicator.qml
	view/Item/Button.qml
	view/Item/MediumButton.qml
	view/Item/Calendar.qml
	view/Item/CalendarComboBox.qml
	view/Item/Carousel.qml
	view/Item/CheckableButton.qml
	view/Item/CheckBox.qml
	view/Item/ComboBox.qml
	view/Item/DesktopPopup.qml
	view/Item/Dialog.qml
	view/Item/DigitInput.qml
	view/Item/EffectImage.qml
	view/Item/ErrorText.qml
	view/Item/IconLabelButton.qml
	view/Item/InformationPopup.qml
	view/Item/LoadingPopup.qml
	view/Item/MovableMouseArea.qml
	view/Item/NumericPad.qml
	view/Item/PhoneNumberComboBox.qml
	view/Item/PhoneNumberInput.qml
	view/Item/Popup.qml
	view/Item/PopupButton.qml
	view/Item/ProgressBar.qml
	view/Item/SecurityRadioButton.qml
	view/Item/RadioButton.qml
	view/Item/RectangleTest.qml
	view/Item/RoundedBackgroundControl.qml
	view/Item/ScrollBar.qml
	view/Item/SearchBar.qml
	view/Item/Slider.qml
	view/Item/Switch.qml
	view/Item/TabBar.qml
	view/Item/Text.qml
	view/Item/TextArea.qml
	view/Item/TextField.qml
	view/Item/TimeComboBox.qml
	view/Item/ToolTip.qml
	view/Item/VerticalTabBar.qml
	view/Item/ZrtpTokenAuthenticationDialog.qml
	
	view/Item/Form/LoginForm.qml
	
	view/Item/Test/ItemsTest.qml
	
	view/Item/MasterDetailFamily.qml
	view/Item/Settings/SwitchSetting.qml
	view/Item/Settings/ComboSetting.qml
	
	view/Item/Help/HelpIconLabelButton.qml

	view/Page/Login/LoginPage.qml
	view/Page/Login/RegisterPage.qml
	view/Page/Login/RegisterCheckingPage.qml
	view/Page/Login/SIPLoginPage.qml
	view/Page/Login/SecurityModePage.qml
	view/Page/Login/WelcomePage.qml
	
	view/Page/Main/AbstractMainPage.qml
	view/Page/Main/CallPage.qml
	view/Page/Main/ContactPage.qml
	view/Page/Main/MeetingPage.qml
	
	view/Page/Main/AbstractMasterDetailPage.qml
	view/Page/Main/SettingsPage.qml
	view/Page/Main/HelpPage.qml
	view/Page/Main/AccountSettingsPage.qml

	
	view/Tool/utils.js
# Prototypes
	view/Prototype/PhoneNumberPrototype.qml
	view/Prototype/AccountsPrototype.qml
	view/Prototype/CallPrototype.qml
	view/Prototype/CameraPrototype.qml
	view/Prototype/FriendPrototype.qml
	view/Prototype/ItemPrototype.qml
)

list(APPEND _LINPHONEAPP_QML_SINGLETONS
	view/Style/AppIcons.qml
	view/Style/DefaultStyle.qml
	view/Style/Typography.qml
)

set(_LINPHONEAPP_QML_FILES ${_LINPHONEAPP_QML_FILES} PARENT_SCOPE)
set(_LINPHONEAPP_QML_SINGLETONS ${_LINPHONEAPP_QML_SINGLETONS} PARENT_SCOPE)
