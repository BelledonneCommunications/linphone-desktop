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
	property var callState: call && call.state
	onCallStateChanged: console.log("State:" +callState)
	visible: true
	onCallChanged: console.log('New Call:' +call)
	ColumnLayout{
		anchors.fill: parent
		RowLayout {
			Layout.fillWidth: true
			LoginForm{
			}
			Rectangle{
				Layout.preferredWidth: 50
				Layout.preferredHeight: 50
				
				color: LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok
								? 'green'
								: LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Failed  || LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.None
									? 'red'
									: 'orange'
			}
			TextInput {
				id: usernameToCall
				label: "Username to call"
				textInputWidth: 250
			}
			Button{
				text: 'Call'
				onClicked: {
						mainItem.callVarObject = UtilsCpp.startAudioCall(usernameToCall.inputText + "@sip.linphone.org")
				}
			}
		}
		
		Rectangle{
			Layout.fillWidth: true
			Layout.preferredHeight: 50
			color: call 
					? call.state === LinphoneEnums.CallState.StreamsRunning 
						? 'green'
						: call.state === LinphoneEnums.CallState.Released
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
			text: mainItem.call ? mainItem.call.lastErrorMessage : ''
			color: 'red'
		}
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}
}

