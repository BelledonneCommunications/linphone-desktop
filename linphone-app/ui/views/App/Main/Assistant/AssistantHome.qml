import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import ConstantsCpp 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
	spacing: 0
	
	// ---------------------------------------------------------------------------
	// Info.
	// ---------------------------------------------------------------------------
	
	Item {
		id: infoItem
		Layout.fillHeight: true
		Layout.fillWidth: true
		
		ColumnLayout {
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0
			
			height: AssistantHomeStyle.info.height
			width: parent.width
			
			Icon {
				//anchors.horizontalCenter: parent.horizontalCenter
				Layout.alignment: Qt.AlignHCenter
				
				icon: 'home_account_assistant'
				iconSize: AssistantHomeStyle.info.iconSize
			}
			
			Text {
				height: AssistantHomeStyle.info.title.height
				Layout.fillWidth: true
				
				color: AssistantHomeStyle.info.title.colorModel.color
				elide: Text.ElideRight
				
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				
				font {
					bold: true
					pointSize: AssistantHomeStyle.info.title.pointSize
				}
				
				text: qsTr('homeTitle')
			}
			
			Text {
				height: AssistantHomeStyle.info.description.height
				Layout.fillWidth: true
				//width: parent.width
				
				color: AssistantHomeStyle.info.description.colorModel.color
				elide: Text.ElideRight
				font.pointSize: AssistantHomeStyle.info.description.pointSize
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				
				text: qsTr('homeDescription')
			}
			
			
		}
	}
	
	// ---------------------------------------------------------------------------
	// Buttons.
	// ---------------------------------------------------------------------------
	CheckBoxText{
		id: cguCheckBox
		Layout.bottomMargin: 10
		Layout.maximumWidth: infoItem.width
		Layout.alignment: Qt.AlignHCenter
		visible: applicationVendor != '' && ConstantsCpp.CguUrl != '' && ConstantsCpp.PrivatePolicyUrl != ''				
		checked: SettingsModel.cguAccepted
		onCheckedChanged: SettingsModel.cguAccepted = checked
		
		//: 'I accept %1's %2terms of use%3 and %4privacy policy%5' : where %1 is the vendor name and other %n are internal keywords that encapsulate links.
		text: qsTr('homeCgu').arg(applicationVendor).arg('< a href="'+ConstantsCpp.CguUrl+'">').arg('</a>').arg('<a href="'+ConstantsCpp.PrivatePolicyUrl+'">').arg('</a>')
	}
	GridView {
		id: buttons
		
		Layout.alignment: Qt.AlignHCenter
		Layout.fillWidth: true
		Layout.maximumWidth: AssistantHomeStyle.buttons.maxWidth
		Layout.preferredHeight: AssistantHomeStyle.buttons.height
		Layout.leftMargin: AssistantStyle.leftMargin
		Layout.rightMargin: AssistantStyle.rightMargin
		Layout.bottomMargin: AssistantStyle.bottomMargin
		
		cellHeight: height / 2
		cellWidth: width / 2
		enabled: cguCheckBox.checked
		
		delegate: Item {
			height: buttons.cellHeight
			width: buttons.cellWidth
			
			TextButtonA {
				anchors {
					fill: parent
					margins: AssistantHomeStyle.buttons.spacing
				}
				
				enabled: cguCheckBox.checked && SettingsModel[$viewType.charAt(0).toLowerCase() + $viewType.slice(1) + "Enabled"]
				text: $text.replace('%1', Qt.application.name.toUpperCase())
				
				onClicked:{ assistant.pushView($view, $props) }
			}
		}
		Connections{
			target: SettingsModel
			onAssistantSupportsPhoneNumbersChanged: {
				if(!SettingsModel.useWebview()){
					buttonsModel.get(0).$view = !SettingsModel.assistantSupportsPhoneNumbers ? 'CreateAppSipAccountWithEmail' : 'CreateAppSipAccount'
				}
			}
		}
		model: ListModel {
			id: buttonsModel
			Component.onCompleted: {
				insert(0, {
						   $text: qsTr('createAppSipAccount'),
						   $view: SettingsModel.useWebview()
									? 'CreateAppSipAccountWithWebView'
									: !SettingsModel.assistantSupportsPhoneNumbers
										? 'CreateAppSipAccountWithEmail'
										: 'CreateAppSipAccount',
						   $viewType: 'CreateAppSipAccount',
						   $props: SettingsModel.useWebview() ? {defaultUrl: SettingsModel.assistantRegistrationUrl, defaultLogoutUrl:SettingsModel.assistantLogoutUrl, configFilename: 'create-app-sip-account.rc'}
																: {}
					   })
				append({
						   $text: qsTr('useAppSipAccount'),
						   $view: SettingsModel.useWebview() ? 'CreateAppSipAccountWithWebView' : 'UseAppSipAccount',
						   $viewType: 'UseAppSipAccount',
						   $props: SettingsModel.useWebview() ? {defaultUrl: SettingsModel.assistantLoginUrl, defaultLogoutUrl:SettingsModel.assistantLogoutUrl, configFilename: 'use-app-sip-account.rc'}
																: {}
					   })
				append({
						   $text: qsTr('useOtherSipAccount'),
						   $view: 'UseOtherSipAccount',
						   $viewType: 'UseOtherSipAccount',
						   $props: {}
					   })
				append( {
						   $text: qsTr('fetchRemoteConfiguration'),
						   $view: 'FetchRemoteConfiguration',
						   $viewType: 'FetchRemoteConfiguration',
						   $props: {}
					   })
			}
		}
		
		interactive: false
	}
}
