import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp

// Snippet
Window {
	id: mainItem
	height: 400
	width: 800
	onWidthChanged: console.log(width)
	property var call
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
		gc()
	}
	Component.onDestruction: gc()
	Connections{
		target: call && call.core || null
		function onLastErrorMessageChanged() { if(mainItem.call) errorMessageText.text=mainItem.call.core.lastErrorMessage}
	}
	RowLayout{
		anchors.fill: parent
		Rectangle{
			Layout.fillHeight: true
			Layout.preferredWidth: 200
			color: 'gray'
			opacity: 0.2
			ListView{
				id: callList
				anchors.fill: parent
				model: CallProxy {
					id: callProxy
					onCountChanged: console.log("count:"+count)
				}
				delegate: RectangleTest{
					height: 40
					width: callList.width
					Text{
						id: addressText
						anchors.fill: parent
						text: modelData.core.remoteAddress
						onTextChanged: console.log(addressText.text)
						Component.onCompleted: console.log(addressText.text)
					}
					MouseArea{
						anchors.fill: parent
						onClicked: {
							//modelData.core.lSetPaused(false)
							callProxy.currentCall = modelData
						}
					}
				}
			}
		}
		ColumnLayout{
			Layout.fillWidth: true
			Layout.fillHeight: true
			RowLayout {
				id: accountLayout
				Layout.fillWidth: true
				property AccountProxy  accounts: AccountProxy {id: accountProxy}
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
							model: AccountProxy {}
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
				TextField {
					id: usernameToCall
					label: "Username to call"
                    Layout.preferredWidth: Math.round(250 * DefaultStyle.dp)
				}
				Button{
					text: 'Call'
					onClicked: {
						var address = usernameToCall.text + "@sip.linphone.org"
						console.log("Calling "+address)
						UtilsCpp.createCall(address)
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
}

