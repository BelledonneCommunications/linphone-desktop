
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	
	property bool enableCallForward: SettingsCpp.callForwardToAddress.length > 0
	
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: parametersComponent
		}
	]
	
	onSave: {
		if (mainItem.enableCallForward && SettingsCpp.callForwardToAddress.length == 0) {
			UtilsCpp.getMainWindow().showInformationPopup("", qsTr("settings_call_forward_address_cannot_be_empty"), false)
			return
		}
		SettingsCpp.save()
	}
	onUndo: SettingsCpp.undo()

	// Generic forward parameters
	/////////////////////////////

    Component {
        id: parametersComponent
        ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(20)
            SwitchSetting {
                //: "Forward calls"
                titleText: qsTr("settings_call_forward_activate_title")
                //: "Enable call forwarding to voicemail or sip address"
                subTitleText: qsTr("settings_call_forward_activate_subtitle")
                propertyName: "enableCallForward"
                propertyOwner: mainItem
                onToggled: function () {
                	SettingsCpp.isSaved = false
					if (!mainItem.enableCallForward)
						SettingsCpp.callForwardToAddress = ""
				}
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
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
				model: [
						{text: qsTr("settings_call_forward_to_voicemail")},
						{text: qsTr("settings_call_forward_to_sipaddress")}
					]
				property bool isInitialized: false
				Component.onCompleted: {
					if (mainItem.enableCallForward) {
						forwardDestination.currentIndex =
							(SettingsCpp.callForwardToAddress === "voicemail" || SettingsCpp.callForwardToAddress.length === 0) ? 0 : 1;
					} else {
						forwardDestination.currentIndex = 0;
					}
					forwardDestination.isInitialized = true;
				}
				onCurrentIndexChanged: {
					if (!forwardDestination.isInitialized)
						return;
					if (currentIndex == 0)
						SettingsCpp.callForwardToAddress = "voicemail";
					else {
						SettingsCpp.callForwardToAddress = "";
						sipInputField.empty();
					}
				}
				onVisibleChanged: {
					if (visible) {
						currentIndex = 0
							SettingsCpp.callForwardToAddress = "voicemail";
					}
				}

			}
			DecoratedTextField {
				id: sipInputField
				visible: mainItem.enableCallForward && forwardDestination.currentIndex == 1
				Layout.fillWidth: true
				propertyName: "callForwardToAddress"
				propertyOwner: SettingsCpp
				//: SIP Address
				title: qsTr("settings_call_forward_sipaddress_title")
				placeHolder: qsTr("settings_call_forward_sipaddress_placeholder")
				useTitleAsPlaceHolder: false
				toValidate: true
			}
		}
	}
}
