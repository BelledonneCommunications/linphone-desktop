
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp
import Linphone

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
            //: Attached files
            title: qsTr("settings_chat_attached_files_title"),
            subTitle: "",
			contentComponent: attachedFilesParamComp,
			// hideTopMargin: true
		},
		{
            //: Notifications
            title: qsTr("settings_chat_notifications_title"),
            subTitle: "",
			contentComponent: displayNotifParamComp,
			// hideTopMargin: true
		}
	]

	Component {
		id: attachedFilesParamComp
		SwitchSetting {
			//: "Automatic download"
			titleText: qsTr("settings_chat_attached_files_auto_download_title")
			//: "Automatically download transferred or received files in conversations"
			subTitleText: qsTr("settings_chat_attached_files_auto_download_subtitle")
			propertyName: "autoDownloadReceivedFiles"
			propertyOwner: SettingsCpp

			Connections {
				target: mainItem
				function onSave() {
					SettingsCpp.save()
				}
			}
		}
	}
	Component {
		id: displayNotifParamComp
		SwitchSetting {
			//: "Display notification content"
			titleText: qsTr("settings_chat_display_notification_content_title")
			//: "Display the content of the received message"
			subTitleText: qsTr("settings_chat_display_notification_content_subtitle")
			propertyName: "displayNotificationContent"
			propertyOwner: SettingsCpp

			Connections {
				target: mainItem
				function onSave() {
					SettingsCpp.save()
				}
			}
		}
	}
}