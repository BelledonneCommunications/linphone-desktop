import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import UtilsCpp 1.0
// =============================================================================

Item {
	id: accountStatus
	Layout.fillWidth: true
	Layout.fillHeight: true
	// ---------------------------------------------------------------------------
	
	signal clicked
	property alias cursorShape:mouseArea.cursorShape
	property alias betterIcon : presenceLevel.betterIcon
	property bool noAccountConfigured: AccountSettingsModel.accounts.length <= ((SettingsModel.showLocalSipAccount ? 1 : 0))
	
	// ---------------------------------------------------------------------------
	MouseArea {
		id:mouseArea
		anchors.fill:parent
		
		onClicked: accountStatus.clicked()
	}
	
	ColumnLayout {
		anchors.fill:parent
		spacing: 0
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		RowLayout {
			Layout.fillHeight: false
			Layout.maximumHeight: parent.height / 2
			Layout.maximumWidth: parent.width
			Layout.alignment: Qt.AlignLeft
			spacing: AccountStatusStyle.horizontalSpacing
			
			Item {
				Layout.preferredHeight: visible ? AccountStatusStyle.presenceLevel.size : 0
				Layout.preferredWidth: visible ? AccountStatusStyle.presenceLevel.size : 0
				visible: !accountStatus.noAccountConfigured && (isRegistrated || isProgressing || haveErrors)
				property bool isRegistrated: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateRegistered
				property bool isProgressing: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateInProgress
				property bool haveErrors: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNotRegistered || AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNoProxy
				PresenceLevel {
					id:presenceLevel
					anchors.fill:parent
					level: OwnPresenceModel.presenceStatus===Presence.Offline?Presence.White:( SettingsModel.rlsUriEnabled ? OwnPresenceModel.presenceLevel : Presence.Green)
					visible: parent.isRegistrated
				}
				
				BusyIndicator {
					id: registrationProcessing
					anchors.fill:parent
					running: parent.isProgressing
					color: AccountStatusStyle.busyColor.color
				}
				
				Icon {
					id: registrationError
					iconSize: parent.width
					icon: 'generic_error'
					visible: parent.haveErrors
					TooltipArea{
						text : 'Not Registered'
					}
				}
			}
			
			Text {
				id:username
				Layout.fillWidth: true
				color: AccountStatusStyle.username.colorModel.color
				elide: Text.ElideRight
				font.bold: true
				font.pointSize: AccountStatusStyle.username.pointSize
				//: 'No account configured' : Status text when there is no configured account.
				text: accountStatus.noAccountConfigured  ? qsTr('noAccount'): AccountSettingsModel.username
				wrapMode: Text.WordWrap
				maximumLineCount: 3
			}
			Item {
				Layout.preferredHeight: username.height
				Layout.preferredWidth: messageCounter.width
				visible: !accountStatus.noAccountConfigured
				MessageCounter {
					id: messageCounter
					anchors.centerIn: parent
					count: CoreManager.eventCount
					iconSize: AccountStatusStyle.messageCounter.iconSize
					pointSize: AccountStatusStyle.messageCounter.pointSize
					MouseArea{
						anchors.fill: parent
						onClicked: window.setView('HistoryView')
					}
				}
			}
		}//RowLayout
		
		Text {
			id: subtitle
			Layout.fillHeight: true
			Layout.maximumHeight:parent.height / 2
			Layout.preferredWidth:parent.width
			visible: !accountStatus.noAccountConfigured && text != username.text
			color: AccountStatusStyle.sipAddress.colorModel.color
			elide: Text.ElideRight
			font.pointSize: AccountStatusStyle.sipAddress.pointSize
			text: UtilsCpp.toDisplayString(AccountSettingsModel.sipAddress, SettingsModel.sipDisplayMode)
		}
		Item{
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}//ColumnLayout
	
	
}
