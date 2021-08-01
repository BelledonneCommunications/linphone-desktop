import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import LinphoneEnums 1.0
import Units 1.0

// =============================================================================

RowLayout{
	property string _type: {
		var status = $chatEntry.eventLogType
		
		if (status == LinphoneEnums.EventLogTypeConferenceCreated) {
			return 'You have joined the group';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceTerminated) {
			return 'You have left the group';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceCallStart) {
			return 'EventLogTypeConferenceCallStart';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceCallEnd) {
			return 'EventLogTypeConferenceCallEnd';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceChatMessage) {
			return 'EventLogTypeConferenceChatMessage';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantAdded) {
			return '%1 has joined';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantRemoved) {
			return '%1 has left';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantSetAdmin) {
			return 'EventLogTypeConferenceParticipantSetAdmin';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantUnsetAdmin) {
			return 'EventLogTypeConferenceParticipantUnsetAdmin';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantDeviceAdded) {
			return 'EventLogTypeConferenceParticipantDeviceAdded';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantDeviceRemoved) {
			return 'EventLogTypeConferenceParticipantDeviceRemoved';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantDeviceMediaChanged) {
			return 'EventLogTypeConferenceParticipantDeviceMediaChanged';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceAvailableMediaChanged) {
			return 'EventLogTypeConferenceAvailableMediaChanged';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceSecurityEvent) {
			return 'Security level degraded by %1';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageLifetimeChanged) {
			return 'EventLogTypeConferenceEphemeralMessageLifetimeChanged';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageEnabled) {
			return 'You enabled ephemeral messages: %1';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageDisabled) {
			return 'You disabled ephemeral messages';
		}
		return 'unknown_notice'
	}
	
	Layout.preferredHeight: ChatStyle.entry.lineHeight
	spacing: ChatStyle.entry.message.extraContent.spacing
	Rectangle{
		height:1
		Layout.fillWidth: true
		color:( $chatEntry.status == ChatNoticeModel.NoticeError ? '#FF0000' : '#979797' )
	}
	
	Text {
		 Component {
		  // Never created.
		  // Private data for `lupdate`.
		  Item {
			property var i18n: [
			  "You have joined the group" //QT_TR_NOOP('declinedIncomingCall'),
			]
		  }
		}
		Layout.preferredWidth: contentWidth
		id:message
		color:( $chatEntry.status == ChatNoticeModel.NoticeError ? '#FF0000' : '#979797' )
		font {
			//bold: true
			pointSize: Units.dp * 7
		}
		height: parent.height
		text: $chatEntry.name?_type.arg($chatEntry.name):_type	//qsTr(Utils.snakeToCamel(_type))
		verticalAlignment: Text.AlignVCenter
		TooltipArea {
		  text: $chatEntry.timestamp.toLocaleString(Qt.locale(App.locale))
		}
	}
	Rectangle{
		height:1
		Layout.fillWidth: true
		color:( $chatEntry.status == ChatNoticeModel.NoticeError ? '#FF0000' : '#979797' )
	}
}
