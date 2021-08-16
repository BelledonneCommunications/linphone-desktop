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
			//: 'You have joined the group' : Little message to show on the event when the user join the chat group.
			return qsTr('conferenceCreatedEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceTerminated) {
			//: 'You have left the group' : Little message to show on the event when the user leave the chat group.
			return qsTr('conferenceCreatedTerminated');
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
			//: '%1 has joined' : Little message to show on the event when someone join the chat group.
			return qsTr('conferenceParticipantAddedEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantRemoved) {
			//: '%1 has left' : Little message to show on the event when someone leave the chat group
			return qsTr('conferenceParticipantRemovedEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantSetAdmin) {
			//: '%1 is now an admin' : Little message to show on the event when someone get the admin status. %1 is somebody
			return qsTr('conferenceParticipantSetAdminEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceParticipantUnsetAdmin) {
			//: '%1 is no more an admin' : Little message to show on the event when somebody lost its admin status. %1 is somebody
			return qsTr('conferencePArticipantUnsetAdminEvent');
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
			//: 'Security level degraded by %1': Little message to show on the event when a security level has been lost.
			return qsTr('conferenceSecurityEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageLifetimeChanged) {
			return 'EventLogTypeConferenceEphemeralMessageLifetimeChanged';
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageEnabled) {
			//: 'Ephemeral messages have been enabled: %1' : Little message to show on the event when ephemeral has been activated. %1 is a date time
			return qsTr('conferenceEphemeralMessageEnabledEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceEphemeralMessageDisabled) {
			//: 'Ephemeral messages have been disabled': Little message to show on the event when ephemeral has been deactivated.
			return qsTr('conferenceEphemeralMessageDisabledEvent');
		}
		if (status == LinphoneEnums.EventLogTypeConferenceSubjectChanged) {
			//: 'New subject : %1' : Little message to show on the event when the subject of the chat romm has been changed. %1 is the new subject.
			return qsTr('conferenceSubjectChangedEvent');
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
