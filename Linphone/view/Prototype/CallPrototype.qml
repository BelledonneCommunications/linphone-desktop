import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

// Snippet
Window{
	id: mainItem
	height: 400
	width: 800
	onWidthChanged: console.log(width)
	property var callVarObject
	property var call: callVarObject ? callVarObject.value : null
	property var callState: call && call.core.state
	onCallStateChanged: {
		console.log("State:" +callState)
		if(callState == LinphoneEnums.CallState.Released)
			callVarObject = undefined
		}
	visible: true
	onCallChanged: console.log('New Call:' +call)
	onClosing: {
		accountStatus.defaultAccount = accountStatus
		accountLayout.accounts = null
		gc()
	}
	Component.onDestruction: gc()
	Connections{
		target: call && call.core || null
		onLastErrorMessageChanged: if(mainItem.call) errorMessageText.text=mainItem.call.core.lastErrorMessage
	}
	ColumnLayout{
		anchors.fill: parent
		RowLayout {
			id: accountLayout
			Layout.fillWidth: true
			property AccountProxy accounts: AccountProxy{id: accountProxy}
			property var haveAccountVar: UtilsCpp.haveAccount()
			property var haveAccount: haveAccountVar ? haveAccountVar.value : false
			onHaveAccountChanged: {
				console.log("HaveAccount: " +haveAccount)
				logStack.replace(haveAccount ? accountListComponent : loginComponent)
			}
			Control.StackView{
				id: logStack
				Layout.preferredHeight: 250
				Layout.preferredWidth: 250
				//initialItem: loginComponent
			}
			Component{
					id: accountListComponent
					ListView{
						id: accountList
						Layout.fillHeight: true
						model: AccountProxy{}
						delegate:Rectangle{
							color: "#11111111"
							height: 20
							width: accountList.width
							Text{
								
								text: modelData.core.identityAddress
							}
						}
					}
				}
				Component{
					id: loginComponent
					LoginForm{}
				}
			Rectangle{
				id: accountStatus
				Layout.preferredWidth: 50
				Layout.preferredHeight: 50
				property int accountCount: accountProxy.count
				onAccountCountChanged: console.log("AccountCount:"+accountCount)
				property var defaultAccount: accountProxy.defaultAccount
				onDefaultAccountChanged: console.log("DefaultAccount:"+defaultAccount)
				property var state: accountProxy.count > 0 && defaultAccount? defaultAccount.core.registrationState : LoginPageCpp.registrationState
				onStateChanged: console.log("State:"+state)
				
				color: state === LinphoneEnums.RegistrationState.Ok
								? 'green'
								: state === LinphoneEnums.RegistrationState.Failed  || state === LinphoneEnums.RegistrationState.None
									? 'red'
									: 'orange'
				MouseArea{
					anchors.fill: parent
					onClicked:{
						logStack.replace(loginComponent)
						gc()
					}
				}
			}
			TextInput {
				id: usernameToCall
				label: "Username to call"
				textInputWidth: 250
			}
			Button{
				text: 'Call'
				onClicked: {
						var address = usernameToCall.text + "@sip.linphone.org"
						console.log("Calling "+address)
						mainItem.callVarObject = UtilsCpp.createCall(address)
						proto.component1 = comp
				}
			}
		}
		
		Rectangle{
			Layout.fillWidth: true
			Layout.preferredHeight: 50
			color: call
					? call.core.state === LinphoneEnums.CallState.StreamsRunning 
						? 'green'
						: call.core.state === LinphoneEnums.CallState.Released
							? 'pink'
							: 'orange'
					: 'red'
			Rectangle{
				anchors.centerIn: parent
				color: 'white'
				width: stateText.contentWidth
				height: stateText.contentHeight
				Text{
					id: stateText
					text: "State:"+(mainItem.callState ? mainItem.callState : 'None')
				}
			}
		}
		Text{
			id: errorMessageText
			color: 'red'
		}
		ItemPrototype{
			id: proto
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}
	Component{
		id: comp
		Rectangle{
			width: 100
			height: width
			color: 'pink'
		}
	}
}

