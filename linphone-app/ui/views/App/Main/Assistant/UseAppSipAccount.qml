import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0
import ConstantsCpp 1.0

import App.Styles 1.0
import Common.Styles 1.0

// =============================================================================

AssistantAbstractView {
	id: view
	readonly property alias usePhoneNumber: assistantModel.usePhoneNumber
	
	mainAction: requestBlock.execute
	mainActionEnabled: {
		var item = loader.item
		return item && item.mainActionEnabled && !requestBlock.loading
	}
	mainActionLabel: qsTr('confirmAction')
	
	title: qsTr('useAppSipAccountTitle').replace('%1', Qt.application.name.toUpperCase())
	
	// ---------------------------------------------------------------------------
	
	Column {
		anchors.fill: parent
		
		Loader {
			id: loader
			
			source: 'UseAppSipAccountWith' + (view.usePhoneNumber ? 'PhoneNumber' : 'Username') + '.qml'
			width: FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
			anchors.horizontalCenter: parent.horizontalCenter
		}
		
		CheckBoxText {
			id: checkBox
			
			text: qsTr('useUsernameToLogin')
			visible: SettingsModel.assistantSupportsPhoneNumbers
			width: UseAppSipAccountStyle.checkBox.width
			anchors.left: loader.left
			
			onClicked: {
				var displayNameBackup = assistantModel.displayName
				assistantModel.reset()
				assistantModel.displayName = displayNameBackup
				requestBlock.setText('')
				
				if (!checked) {
					assistantModel.setCountryCode(telephoneNumbersModel.defaultIndex)
				}
			}
		}
		Text {
			anchors.right: loader.right
			visible: ConstantsCpp.PasswordRecoveryUrl
			elide: Text.ElideRight
			font.pointSize: AboutStyle.copyrightBlock.url.pointSize
			linkColor: AboutStyle.copyrightBlock.url.colorModel.color
			//: 'Forgotten password?' : text for an url shortcut to change the password
			text: '<a href="'+ConstantsCpp.PasswordRecoveryUrl+'">'+qsTr("passwordRecovery")+'</a>'
			
			horizontalAlignment: Text.AlignHCenter
			
			onLinkActivated: Qt.openUrlExternally(link)
			
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.NoButton
				cursorShape: parent.hoveredLink
							 ? Qt.PointingHandCursor
							 : Qt.IBeamCursor
			}
		}
		
		RequestBlock {
			id: requestBlock
			
			action: assistantModel.login
			width: parent.width
			loading: assistantModel.isProcessing
		}
	}
	
	// ---------------------------------------------------------------------------
	// Assistant.
	// ---------------------------------------------------------------------------
	
	AssistantModel {
		id: assistantModel
		
		function setCountryCode (index) {
			if( index >= 0) {
				var model = telephoneNumbersModel
			//assistantModel.countryCode = index !== -1 ?  model.data(model.index(index, 0),"countryCode") || '' : ''
				assistantModel.countryCode = model.data(model.index(index, 0),"countryCode")
			}
		}
		
		configFilename: 'use-app-sip-account.rc'
		usePhoneNumber: SettingsModel.assistantSupportsPhoneNumbers && !checkBox.checked
		//countryCode: setCountryCode(view.usePhoneNumber ? telephoneNumbersModel.defaultIndex : -1)
		
		onPasswordChanged: {
			if (!usePhoneNumber) {
				loader.item.passwordError = error
			}
		}
		
		onPhoneNumberChanged: {
			if (usePhoneNumber) {
				loader.item.phoneNumberError = error
			}
		}
		onCreateStatusChanged: {
			requestBlock.setText(error)
			if (error.length) {
				return
			}
		}
		onLoginStatusChanged: {
			requestBlock.setText(error)
			if (!error.length) {
				var codecInfo = VideoCodecsModel.getCodecInfo('H264')
				if (codecInfo.downloadUrl) {
					Utils.openCodecOnlineInstallerDialog(window, codecInfo, function cb (window) {
						window.setView('Home')
					})
				} else {
					window.setView('Home')
				}
			}
		}
		
		onRecoverStatusChanged: {
			if (!view.usePhoneNumber) {
				requestBlock.setText('')
				return
			}
			
			requestBlock.setText(error)
			if (!error.length) {
				window.lockView({
									descriptionText: qsTr('quitWarning')
								})
				assistant.pushView('ActivateAppSipAccountWithPhoneNumber', {
									   assistantModel: assistantModel
								   })
			}
		}
		Component.onCompleted: setCountryCode(telephoneNumbersModel.defaultIndex)
	}
	
	TelephoneNumbersModel {
		id: telephoneNumbersModel
	}
}
