
list(APPEND _LINPHONEAPP_QML_FILES
	view/Control/Button/Button.qml
	view/Control/Button/CalendarComboBox.qml
	view/Control/Button/CheckableButton.qml
	view/Control/Button/CheckBox.qml
	view/Control/Button/ComboBox.qml
	view/Control/Button/HelpIconLabelButton.qml
    view/Control/Button/IconButton.qml
    view/Control/Button/IconLabelButton.qml
    view/Control/Button/BigButton.qml
	view/Control/Button/RoundButton.qml
	view/Control/Button/MediumButton.qml
	view/Control/Button/SmallButton.qml
	view/Control/Button/CountryIndicatorCombobox.qml
	view/Control/Button/PopupButton.qml
	view/Control/Button/RadioButton.qml
	view/Control/Button/SecurityRadioButton.qml
	view/Control/Button/Slider.qml
	view/Control/Button/Switch.qml
	view/Control/Button/Settings/ComboSetting.qml
	view/Control/Button/Settings/SwitchSetting.qml

	view/Control/Container/Carousel.qml
	view/Control/Container/FormItemLayout.qml
	view/Control/Container/ScrollBar.qml
	view/Control/Container/Section.qml
	view/Control/Container/TabBar.qml
	view/Control/Container/VerticalTabBar.qml
	view/Control/Container/Call/ActiveSpeakerLayout.qml
	view/Control/Container/Call/CallHistoryLayout.qml
	view/Control/Container/Call/CallLayout.qml
	view/Control/Container/Call/CallGridLayout.qml
	view/Control/Container/Call/Mosaic.qml
	view/Control/Container/Contact/ContactLayout.qml
	view/Control/Container/Main/MainRightPanel.qml

	view/Control/Display/BusyIndicator.qml
	view/Control/Display/EffectImage.qml
	view/Control/Display/Flickable.qml
	view/Control/Display/GradientRectangle.qml
	view/Control/Display/TemporaryText.qml
	view/Control/Display/ProgressBar.qml
	view/Control/Display/RoundedPane.qml
	view/Control/Display/Sticker.qml
	view/Control/Display/Text.qml
	view/Control/Display/ToolTip.qml
	view/Control/Display/Call/CallListView.qml
	view/Control/Display/Call/CallHistoryListView.qml
	view/Control/Display/Call/CallStatistics.qml
	view/Control/Display/Chat/ChatListView.qml
	view/Control/Display/Chat/ChatMessage.qml
	view/Control/Display/Chat/ChatMessagesListView.qml
	view/Control/Display/Contact/Avatar.qml
	view/Control/Display/Contact/Contact.qml
	view/Control/Display/Contact/ContactListItem.qml
	view/Control/Display/Contact/ContactListView.qml
	view/Control/Display/Contact/AllContactListView.qml
	view/Control/Display/Contact/Voicemail.qml
	view/Control/Display/Meeting/MeetingListView.qml
	view/Control/Display/Participant/ParticipantDeviceListView.qml
	view/Control/Display/Participant/ParticipantListView.qml
	view/Control/Display/Settings/SettingsMenuItem.qml

	view/Control/Form/Login/LoginForm.qml
	view/Control/Form/Call/ChangeLayoutForm.qml
	view/Control/Form/Settings/EncryptionSettings.qml
	view/Control/Form/Settings/MultimediaSettings.qml
	view/Control/Form/Settings/ScreencastSettings.qml

	view/Control/Input/Calendar.qml
	view/Control/Input/DecoratedTextField.qml
	view/Control/Input/DigitInput.qml
	view/Control/Input/NumericPad.qml
	view/Control/Input/PhoneNumberInput.qml
	view/Control/Input/SearchBar.qml
	view/Control/Input/TextArea.qml
	view/Control/Input/TextField.qml
	view/Control/Input/TimeComboBox.qml

	view/Control/Popup/DesktopPopup.qml
	view/Control/Popup/InformationPopup.qml
	view/Control/Popup/NumericPadPopup.qml
	view/Control/Popup/Popup.qml
	view/Control/Popup/Dialog/AuthenticationDialog.qml
	view/Control/Popup/Dialog/Dialog.qml
	view/Control/Popup/Dialog/ZrtpAuthenticationDialog.qml
	view/Control/Popup/Loading/LoadingPopup.qml
	view/Control/Popup/Notification/Notification.qml
	view/Control/Popup/Notification/NotificationReceivedCall.qml
	view/Control/Popup/Notification/NotificationReceivedMessage.qml

	view/Control/Tool/MovableMouseArea.qml
	view/Control/Tool/Helper/utils.js
# Prototypes
	view/Control/Tool/Prototype/AccountsPrototype.qml
	view/Control/Tool/Prototype/CallPrototype.qml
	view/Control/Tool/Prototype/CameraPrototype.qml
	view/Control/Tool/Prototype/CanvasCircle.qml
	view/Control/Tool/Prototype/FriendPrototype.qml
	view/Control/Tool/Prototype/ItemPrototype.qml
	view/Control/Tool/Prototype/PhoneNumberPrototype.qml

	view/Page/Form/Call/NewCallForm.qml
	view/Page/Form/Chat/SelectedChatView.qml
	view/Page/Form/Contact/ContactDescription.qml
	view/Page/Form/Contact/ContactEdition.qml
	view/Page/Form/Login/LoginPage.qml
	view/Page/Form/Login/SIPLoginPage.qml
	view/Page/Form/Meeting/AddParticipantsForm.qml
	view/Page/Form/Meeting/MeetingForm.qml
	view/Page/Form/Register/RegisterCheckingPage.qml
	view/Page/Form/Register/RegisterPage.qml
	view/Page/Form/Security/SecurityModePage.qml
	view/Page/Form/Settings/AbstractSettingsMenu.qml
	view/Page/Form/Settings/AccountSettingsPage.qml
	view/Page/Form/Settings/SettingsPage.qml

	view/Page/Layout/Login/LoginLayout.qml
	view/Page/Layout/Main/MainLayout.qml
	view/Page/Layout/Settings/AbstractSettingsLayout.qml
	view/Page/Layout/Settings/AccountSettingsGeneralLayout.qml
	view/Page/Layout/Settings/AccountSettingsParametersLayout.qml
	view/Page/Layout/Settings/CallSettingsLayout.qml
	view/Page/Layout/Settings/CallForwardSettingsLayout.qml
	view/Page/Layout/Settings/ContactsSettingsLayout.qml
	view/Page/Layout/Settings/MeetingsSettingsLayout.qml
	view/Page/Layout/Settings/ContactsSettingsProviderLayout.qml
	view/Page/Layout/Settings/DebugSettingsLayout.qml
	view/Page/Layout/Settings/LdapSettingsLayout.qml
	view/Page/Layout/Settings/CarddavSettingsLayout.qml
	view/Page/Layout/Settings/SecuritySettingsLayout.qml
	view/Page/Layout/Settings/NetworkSettingsLayout.qml
	view/Page/Layout/Settings/AdvancedSettingsLayout.qml

	view/Page/Main/AbstractMainPage.qml
	view/Page/Main/Account/AccountListView.qml
	view/Page/Main/Call/CallPage.qml
	view/Page/Main/Call/CallSettingsPanel.qml
	view/Page/Main/Call/WaitingRoom.qml
	view/Page/Main/Chat/ChatPage.qml
	view/Page/Main/Contact/ContactPage.qml
	view/Page/Main/Help/HelpPage.qml
	view/Page/Main/Meeting/MeetingPage.qml
	view/Page/Main/Start/WelcomePage.qml

	view/Page/Window/AbstractWindow.qml
	view/Page/Window/Call/CallsWindow.qml
	view/Page/Window/Main/MainWindow.qml

	view/Test/ItemsTest.qml
	view/Test/RectangleTest.qml
)

list(APPEND _LINPHONEAPP_QML_SINGLETONS
	view/Style/AppIcons.qml
	view/Style/buttonStyle.js
	view/Style/DefaultStyle.qml
	view/Style/Typography.qml
)

set(_LINPHONEAPP_QML_FILES ${_LINPHONEAPP_QML_FILES} PARENT_SCOPE)
set(_LINPHONEAPP_QML_SINGLETONS ${_LINPHONEAPP_QML_SINGLETONS} PARENT_SCOPE)
