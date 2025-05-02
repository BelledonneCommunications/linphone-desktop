
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import SettingsCpp 1.0
import UtilsCpp

AbstractSettingsLayout {
	id: mainItem
	
	property bool enableCallForward: SettingsCpp.callForwardToAddress.length > 0
	property string localCallForwardToAddress: SettingsCpp.callForwardToAddress
	
	width: parent?.width
	
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: parametersComponent
		}
	]
	
	Connections {
		target: SettingsCpp
		function onCallForwardToAddressChanged() {
			requestTimeOut.stop()
			UtilsCpp.getMainWindow().closeLoadingPopup()
			UtilsCpp.showInformationPopup("",
				SettingsCpp.callForwardToAddress
					? qsTr("settings_call_forward_activation_success") + (SettingsCpp.callForwardToAddress == "voicemail" ? qsTr("settings_call_forward_to_voicemail") : SettingsCpp.callForwardToAddress)
					: qsTr("settings_call_forward_deactivation_success")
				, true)
		}
	}
	
	Timer {
        id: requestTimeOut
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
			UtilsCpp.getMainWindow().closeLoadingPopup()
			UtilsCpp.showInformationPopup("", qsTr("settings_call_forward_address_timeout"), false)
        }
    }

	onSave: {
		if (mainItem.enableCallForward && mainItem.localCallForwardToAddress.length == 0) {
			UtilsCpp.getMainWindow().showInformationPopup("", qsTr("settings_call_forward_address_cannot_be_empty"), false)
			return
		}
		requestTimeOut.start()
		if (!mainItem.enableCallForward && SettingsCpp.callForwardToAddress.length > 0) {
			UtilsCpp.getMainWindow().showLoadingPopup(qsTr("settings_call_forward_address_progress_disabling") + " ...")
			SettingsCpp.callForwardToAddress = ""
		} else if (SettingsCpp.callForwardToAddress != mainItem.localCallForwardToAddress) {
			UtilsCpp.getMainWindow().showLoadingPopup(qsTr("settings_call_forward_address_progress_enabling")+(mainItem.localCallForwardToAddress === 'voicemail' ?  qsTr("settings_call_forward_to_voicemail") : mainItem.localCallForwardToAddress) + " ...")
			SettingsCpp.callForwardToAddress = mainItem.localCallForwardToAddress
		}
	}

	// Generic forward parameters
	/////////////////////////////

    Component {
        id: parametersComponent
        ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
            SwitchSetting {
                //: "Forward calls"
                titleText: qsTr("settings_call_forward_activate_title")
                //: "Enable call forwarding to voicemail or sip address"
                subTitleText: qsTr("settings_call_forward_activate_subtitle")
                propertyName: "enableCallForward"
                propertyOwner: mainItem
            }
			Text {
				visible: mainItem.enableCallForward
				//: Forward to destination
				text: qsTr("settings_call_forward_destination_choose")
				font {
					pixelSize: Typography.p2l.pixelSize
					weight: Typography.p2l.weight
				}
			}
			ComboBox {
				id: forwardDestination
				visible: mainItem.enableCallForward
				Layout.fillWidth: true
				Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
				model: [
						{text: qsTr("settings_call_forward_to_voicemail")},
						{text: qsTr("settings_call_forward_to_sipaddress")}
					]
				property bool isInitialized: false
				Component.onCompleted: {
					if (mainItem.enableCallForward) {
						forwardDestination.currentIndex =
							(mainItem.localCallForwardToAddress === "voicemail" || mainItem.localCallForwardToAddress.length === 0) ? 0 : 1;
					} else {
						forwardDestination.currentIndex = 0;
					}
					forwardDestination.isInitialized = true;
				}
				onCurrentIndexChanged: {
					if (!forwardDestination.isInitialized)
						return;
					if (currentIndex == 0)
						mainItem.localCallForwardToAddress = "voicemail";
					else {
						mainItem.localCallForwardToAddress = "";
						sipInputField.empty();
					}
				}
				onVisibleChanged: {
					if (visible) {
						currentIndex = 0
						mainItem.localCallForwardToAddress = "voicemail";
					}
				}

			}
			DecoratedTextField {
				id: sipInputField
				visible: mainItem.enableCallForward && forwardDestination.currentIndex == 1
				Layout.fillWidth: true
				propertyName: "localCallForwardToAddress"
				propertyOwner: mainItem
				//: SIP Address
				title: qsTr("settings_call_forward_sipaddress_title")
				placeHolder: qsTr("settings_call_forward_sipaddress_placeholder")
				useTitleAsPlaceHolder: false
				toValidate: true
			}
		}
	}
}
