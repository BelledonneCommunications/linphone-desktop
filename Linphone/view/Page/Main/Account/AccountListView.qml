import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout{
	id: mainItem
	anchors.top: parent.top
	anchors.topMargin: Utils.getSizeWithScreenRatio(23)
	anchors.left: parent.left
	anchors.leftMargin: Utils.getSizeWithScreenRatio(24)
	anchors.right: parent.right
	anchors.rightMargin: Utils.getSizeWithScreenRatio(24)
	anchors.bottom: parent.bottom
	anchors.bottomMargin: Utils.getSizeWithScreenRatio(23)
	
	signal addAccountRequest()
    signal editAccount(AccountGui account)
    readonly property var childrenWidth: Utils.getSizeWithScreenRatio(517)

    readonly property real spacing: Utils.getSizeWithScreenRatio(16)
	required property var getPreviousItem
	required property var getNextItem
	property AccountProxy  accountProxy
	property var popupId
	Component{
		id: contactDelegate
		Contact {
			id: contactItem
			Layout.preferredWidth: mainItem.childrenWidth
			account: modelData
			isSelected: modelData && accountProxy.defaultAccount && modelData.core === accountProxy.defaultAccount.core
			onAvatarClicked: fileDialog.open()
			onBackgroundClicked: {
				modelData.core.lSetDefaultAccount()
			}
			onEdit: editAccount(modelData)
			hoverEnabled: true
			spacing: mainItem.spacing
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
			style: ButtonStyle.whiteSelected
			KeyNavigation.up: visibleChildren.length
								!= 0 ? getPreviousItem(
											index) : null
			KeyNavigation.down: visibleChildren.length
								!= 0 ? getNextItem(
											index) : null
		}
	}

	Repeater{
		model: AccountProxy {
			id: accountProxy
			sourceModel: AppCpp.accounts
		}
		delegate: contactDelegate
	}
	HorizontalBar{
		Layout.topMargin: mainItem.spacing
		Layout.bottomMargin: mainItem.spacing
		visible: addAccountButton.visible
		color: DefaultStyle.main2_300
	}
	IconLabelButton{
		id: addAccountButton
		Layout.fillWidth: true
		visible: SettingsCpp.maxAccount == 0 || SettingsCpp.maxAccount > accountProxy.count
		onClicked: mainItem.addAccountRequest()
		icon.source: AppIcons.plusCircle
		icon.width: Utils.getSizeWithScreenRatio(32)
		icon.height: Utils.getSizeWithScreenRatio(32)
		//: Add an account
		text: qsTr("add_an_account")
		KeyNavigation.up: visibleChildren.length
							!= 0 ? getPreviousItem(
										AppCpp.accounts.getCount()) : null
		KeyNavigation.down: visibleChildren.length
							!= 0 ? getNextItem(
										AppCpp.accounts.getCount()) : null
	}
	}

 
