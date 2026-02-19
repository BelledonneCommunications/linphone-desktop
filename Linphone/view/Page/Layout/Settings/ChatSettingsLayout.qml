
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Basic as Control
import SettingsCpp
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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

	onSave: SettingsCpp.save()
	onUndo: SettingsCpp.undo()

	FolderDialog {
		id: folderDialog
		currentFolder: SettingsCpp.downloadFolder
		options: FolderDialog.DontResolveSymlinks
		onAccepted: {
			SettingsCpp.downloadFolder = Utils.getSystemPathFromUri(selectedFolder)
		}
	}

	Component {
		id: attachedFilesParamComp
		ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(20)
			SwitchSetting {
				//: "Automatic download"
				titleText: qsTr("settings_chat_attached_files_auto_download_title")
				//: "Automatically download transferred or received files in conversations"
				subTitleText: qsTr("settings_chat_attached_files_auto_download_subtitle")
				propertyName: "autoDownloadReceivedFiles"
				propertyOwner: SettingsCpp
			}
			DecoratedTextField {
				id: downloadFolderTextField
				//: "Dossier de téléchargement des fichiers"
				title: qsTr("settings_chat_download_folder_title")
				propertyName: "downloadFolder"
				propertyOwner: SettingsCpp
				customButtonIcon: AppIcons.arrowSquareOut
				customCallback: function() {folderDialog.open()}
				toValidate: true
				//: Browse folders
				customButtonAccessibleName: qsTr("settings_chat_download_folder_browse_button")
				Connections {
                    target: SettingsCpp
                    function onDownloadFolderChanged() {
                        if (downloadFolderTextField.text != downloadFolderTextField.propertyOwner[downloadFolderTextField.propertyName]) 
                            downloadFolderTextField.text = downloadFolderTextField.propertyOwner[downloadFolderTextField.propertyName]
                    }
                }
			}

		}
	}
	Component {
		id: displayNotifParamComp
		SwitchSetting {
			//: "Display content"
			titleText: qsTr("settings_chat_display_notification_content_title")
			//: "Display the content of the received message"
			subTitleText: qsTr("settings_chat_display_notification_content_subtitle")
			propertyName: "displayNotificationContent"
			propertyOwner: SettingsCpp
		}
	}
}