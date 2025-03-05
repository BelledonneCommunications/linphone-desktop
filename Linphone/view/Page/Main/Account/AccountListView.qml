import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs

import Linphone
import UtilsCpp
import SettingsCpp

Item {
	id: mainItem
    width: Math.round(517 * DefaultStyle.dp)

    readonly property real spacing: Math.round(16 * DefaultStyle.dp)
	property AccountProxy  accountProxy
	
	signal addAccountRequest()
    signal editAccount(AccountGui account)

    implicitHeight: list.contentHeight + Math.round(32 * DefaultStyle.dp) + 1 + addAccountButton.height
	ColumnLayout{
		id: childLayout
		anchors.top: parent.top
        anchors.topMargin: mainItem.topPadding
		anchors.left: parent.left
        anchors.leftMargin: mainItem.leftPadding
		anchors.right: parent.right
        anchors.rightMargin: mainItem.rightPadding
		anchors.bottom: parent.bottom
        anchors.bottomMargin: mainItem.bottomPadding
		ListView{
			id: list
			Layout.preferredHeight: contentHeight
			Layout.fillWidth: true
			spacing: mainItem.spacing
			model: AccountProxy {
				id: accountProxy
				sourceModel: AppCpp.accounts
			}
			delegate: Contact{
				id: contactItem
				width: list.width
				account: modelData
				property bool isSelected: modelData && accountProxy.defaultAccount && modelData.core === accountProxy.defaultAccount.core
				onAvatarClicked: fileDialog.open()
				onBackgroundClicked: {
					modelData.core.lSetDefaultAccount()
				}
				onEdit: editAccount(modelData)
				hoverEnabled: true
				backgroundColor: contactItem.isSelected 
					? DefaultStyle.grey_200
					: hovered
						? DefaultStyle.main2_100
						: DefaultStyle.grey_0
				FileDialog {
					id: fileDialog
					currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
					onAccepted: {
						var avatarPath = UtilsCpp.createAvatar( selectedFile )
						if(avatarPath){
							modelData.core.pictureUri = avatarPath
						}
					}
				}
			}
		}
		Rectangle{
			id: separator
			Layout.fillWidth: true
			Layout.topMargin: mainItem.spacing
			Layout.bottomMargin: mainItem.spacing
			visible: addAccountButton.visible
            height: Math.max(Math.round(1 * DefaultStyle.dp), 1)
			color: DefaultStyle.main2_300
		}
		IconLabelButton{
			id: addAccountButton
			Layout.fillWidth: true
			visible: SettingsCpp.maxAccount == 0 || SettingsCpp.maxAccount > accountProxy.count
			onClicked: mainItem.addAccountRequest()
			icon.source: AppIcons.plusCircle
            icon.width: Math.round(32 * DefaultStyle.dp)
            icon.height: Math.round(32 * DefaultStyle.dp)
			text: 'Ajouter un compte'
		}
	}
}
 
