import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Utils 1.0
import UtilsCpp 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		Form{
			width: view.width
			FormLine {
				FormGroup {
					//: 'Tunnel Status' : Field title to introduce the status of the tunnel (activated or not)
					label: qsTr('tunnelStatus')
					RowLayout{
						Icon{
							Layout.preferredWidth: 20
							icon: 'led_orange'
							iconSize: 20
							function update(){
								if( view.tunnelModel.getActivated())
									icon = 'led_green'
								else
									icon = 'led_red'
							}
							onVisibleChanged: if(visible){
												icon = 'led_orange'
												tunnelStatusTimer.start()
											}else{
												tunnelStatusTimer.stop()
												icon = 'led_orange'
												}
							Timer{
								id: tunnelStatusTimer
								interval: 1000
								onTriggered: parent.update()
								repeat: true
							}
						}
						Item{
							Layout.fillWidth: true
						}
					}
				}
			}
			//----------------		DEVELOPER SETTINGS FOR TUNNEL		
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					//: 'Domain' : Field title of a textfield to set domain.
					label: qsTr('tunnelDomain')
					TextField {
						text: view.tunnelModel.domain
						onEditingFinished: view.tunnelModel.domain = text
					}
				}
			}
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					//: 'Username' : Field title of a textfield to set username.
					label: qsTr('tunnelUsername')
					TextField {
						text: view.tunnelModel.username
						onEditingFinished: view.tunnelModel.username = text
					}
				}
			}
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				FormGroup {
					//: 'SIP' : Field title of a switch to set SIP mode.
					label: qsTr('tunnelSIP')
					Switch {
						checked: view.tunnelModel.sipEnabled
						onClicked: view.tunnelModel.sipEnabled = !checked
					}
				}
				
				TextButtonA{
						//: 'Cancel' : Button to cancel the action.
						text: (proxyHttpOptions.showProxyOptions? qsTr('cancel'):
						//: 'Set HTTP proxy' : Button to set the new proxy.
																	qsTr('setHTTPProxy'))
						onClicked:{
							proxyHttpOptions.showProxyOptions = !proxyHttpOptions.showProxyOptions 
						}
						Layout.preferredWidth: 100
					}
			}
			FormLine{
				visible: SettingsModel.developerSettingsEnabled
				RowLayout{
					id: proxyHttpOptions
					property bool showProxyOptions : false
					
					TextField {
						id: proxyHttpHost
						visible: parent.showProxyOptions
						//: 'Host' : Placeholder to set hostname.
						placeholderText: qsTr('proxyHttpHost')
					}
					NumericField{
						id: proxyHttpPort
						visible: parent.showProxyOptions
						//: 'Port' : Placehoilder to set port.
						placeholderText: qsTr('proxyHttpPort')
						Layout.preferredWidth: 100
						maxValue: 65535
					}
					TextField {
						id: proxyHttpUsername
						visible: parent.showProxyOptions
						//: 'Username' : Placeholder to set username.
						placeholderText: qsTr('proxyHttpUsername')
					}
					PasswordField {
						id: proxyHttpPassword
						visible: parent.showProxyOptions
						//: 'Password' : Placeholder to set password.
						placeholderText: qsTr('proxyHttpPassword')
						onVisibleChanged: if(!visible) text=''
					}
					TextButtonB{
						visible: parent.showProxyOptions
						//: 'Apply' : Button to set proxy from changes.
						text: qsTr('proxyHttpApply')
						onClicked: {
							view.tunnelModel.setHttpProxy(proxyHttpHost.text, proxyHttpPort.text, proxyHttpUsername.text, proxyHttpPassword.text)
							parent.showProxyOptions = false
						}
					}
				}
			}
			//----------------		USER SETTINGS FOR TUNNEL	
			FormLine {
				FormGroup {
					//: 'Mode' : Field title on form to set tunnel mode.
					label: qsTr('serverMode')
					ExclusiveButtons {
						id: mode
						property var modes: [ [LinphoneEnums.TunnelModeDisable],
							[LinphoneEnums.TunnelModeEnable],
							[LinphoneEnums.TunnelModeAuto]
						]
						texts: modes.map(value => UtilsCpp.toString(value[0]) )
						onClicked: view.tunnelModel.mode = modes[button][0]
						Binding {
							property: 'selectedButton'
							target: mode
							value: {
								var toFound = view.tunnelModel.mode
								return Number(Utils.findIndex(mode.modes, function (value) {
									return toFound == value[0]
								}))
							}
						}
					}
				}
			}
			FormLine {
				FormGroup {
					//: 'Dual mode' : Field title on form to set dual mode of the tunnel.
					label: qsTr('serverDualMode')
					Switch {
						checked: view.tunnelModel.dualModeEnabled
						onClicked: view.tunnelModel.dualModeEnabled = !checked
					}
				}
			}
		}
		//----------------------------------------------------------------------------------------------------		
		Repeater {
			id: view
			property TunnelModel tunnelModel : SettingsModel.getTunnel()
			property TunnelConfigProxyModel tunnelConfigProxyModel: tunnelModel.getTunnelProxyConfigs()
			Component.onDestruction: {tunnelConfigProxyModel=null}// Need to set it to null because of not calling destructor if not.
			width: parent.width	
			model: tunnelConfigProxyModel
			delegate: 
				Form {
				//: 'Server' : Title form to set a server
				title: qsTr('serverTitle')+' : '+$modelData.host+(view.tunnelModel.dualModeEnabled?' / '+$modelData.host2:'')
				width: view.width
				removeButton: SettingsModel.developerSettingsEnabled
				onRemoveButtonClicked: {view.tunnelModel.removeTunnelConfig($modelData)}
				
				FormLine {
					FormGroup {
						//: 'Hostname' : Field title on form to set hostname.
						label: qsTr('serverHostname')
						TextField {
							text: $modelData.host
							onEditingFinished: $modelData.host = text
						}
					}
				}
				FormLine {
					FormGroup {
						//: 'Port' : Field title on form to set port.
						label: qsTr('serverPort')
						NumericField {
							text: $modelData.port
							onEditingFinished: $modelData.port = text
							maxValue: 65535
						}
					}
				}
				FormLine {
					visible: view.tunnelModel.dualModeEnabled
					FormGroup {
						//: 'Dual hostname URL' : Field title on form to set the second hostname for dual configuration.
						label: qsTr('serverDualHostname')
						TextField {
							text: $modelData.host2
							onEditingFinished: $modelData.host2 = text
						}
					}
				}
				FormLine {
					visible: view.tunnelModel.dualModeEnabled
					FormGroup {
						//: 'Dual port' : Field title on form to set the second port for the dual configuration.
						label: qsTr('serverDualPort')
						NumericField {
							text: $modelData.port2
							onEditingFinished: $modelData.port2 = text
							maxValue: 65535
						}
					}
				}
				//-------------------------		DEVELOPER SETTINGS FOR SERVER				
				FormLine {
					visible: SettingsModel.developerSettingsEnabled
					FormGroup {
						//: 'Remote UDP mirror port' : Field title on form to set the remote UDP mirror port.
						label: qsTr('serverRemoteUDPMirrorPort')
						NumericField {
							text: $modelData.remoteUdpMirrorPort
							onEditingFinished: $modelData.remoteUdpMirrorPort = text
							maxValue: 65535
						}
					}
				}
				FormLine {
					visible: SettingsModel.developerSettingsEnabled
					FormGroup {
						//: 'Delay' : Field title on form to set the delay of the tunnel.
						label: qsTr('serverDelay')
						NumericField {
							text: $modelData.delay
							onEditingFinished: $modelData.delay = text
						}
					}
				}
			}
		}
		
		RowLayout{
			width: parent.width
			TextButtonB {
				visible: SettingsModel.developerSettingsEnabled
				//: 'Add server' : Button for adding a server
				text: qsTr('tunnelAddServer')
				onClicked: {view.tunnelModel.addTunnelConfig()}
			}
			Item{
				Layout.fillWidth: true
			}
			TextButtonB {
				//: 'Apply' : Button to apply changes.
				text: qsTr('tunnelApply')
				onClicked: view.tunnelModel.apply()
			}
		}
	}
}
