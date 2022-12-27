import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
	id: accountStatus
	Layout.fillWidth: true
	Layout.fillHeight: true
	// ---------------------------------------------------------------------------
	
	signal clicked
	property alias cursorShape:mouseArea.cursorShape
	property alias betterIcon : presenceLevel.betterIcon
	
	// ---------------------------------------------------------------------------
	MouseArea {
		id:mouseArea
		anchors.fill:parent
		
		onClicked: accountStatus.clicked()
	}
	
	ColumnLayout {
		anchors.fill:parent
		spacing: AccountStatusStyle.verticalSpacing
		
		RowLayout {
			Layout.preferredHeight: parent.height / 2
			Layout.maximumWidth: parent.width
			Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
			spacing: AccountStatusStyle.horizontalSpacing
			
			Item {
				Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
				Layout.bottomMargin: AccountStatusStyle.presenceLevel.bottomMargin
				Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
				Layout.preferredWidth: AccountStatusStyle.presenceLevel.size
				
				PresenceLevel {
					id:presenceLevel
					anchors.fill:parent
					level: OwnPresenceModel.presenceStatus===Presence.Offline?Presence.White:( SettingsModel.rlsUriEnabled ? OwnPresenceModel.presenceLevel : Presence.Green)
					visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateRegistered
				}
				
				BusyIndicator {
					anchors.fill:parent
					running: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateInProgress
					color: AccountStatusStyle.busyColor.color
				}
				
				Icon {
					iconSize: parent.width
					icon: 'generic_error'
					visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNotRegistered || AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNoProxy
					TooltipArea{
						text : 'Not Registered'
					}
				}
			}
			
			Text {
				id:username
				Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
				color: AccountStatusStyle.username.colorModel.color
				elide: Text.ElideRight
				font.bold: true
				font.pointSize: AccountStatusStyle.username.pointSize
				text: AccountSettingsModel.username
				verticalAlignment: Text.AlignBottom
			}
			Item {
				Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
				Layout.bottomMargin: 5
				Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
				Layout.preferredWidth: AccountStatusStyle.presenceLevel.size
				MessageCounter {
					id: messageCounter
					anchors.fill: parent
					count: CoreManager.eventCount
					MouseArea{
						anchors.fill: parent
						onClicked: window.setView('HistoryView')
					}
				}
			}
			Item{//Spacer
				Layout.fillHeight: true
				Layout.fillWidth: true
			}
		}//RowLayout
		
		Text {
			Layout.preferredHeight:parent.height / 2
			Layout.preferredWidth:parent.width
			color: AccountStatusStyle.sipAddress.colorModel.color
			elide: Text.ElideRight
			font.pointSize: AccountStatusStyle.sipAddress.pointSize
			text: AccountSettingsModel.sipAddress
			verticalAlignment: Text.AlignTop
		}
	}//ColumnLayout
	
	
}
