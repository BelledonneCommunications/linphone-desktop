
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
}