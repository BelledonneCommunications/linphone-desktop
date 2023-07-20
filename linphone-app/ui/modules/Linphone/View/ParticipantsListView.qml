import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Linphone.Styles 1.0
import Units 1.0
import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils
// =============================================================================

ColumnLayout {
	id:mainLayout
	property ChatRoomModel chatRoomModel
	property ConferenceModel conferenceModel

	property ParticipantModel me: conferenceModel && conferenceModel.localParticipant

	property int count: selectedParticipants.count
	property bool isAdmin : (chatRoomModel && chatRoomModel.isMeAdmin && !chatRoomModel.isReadOnly) || (me && me.adminStatus)
	property bool canHandleParticipants : isAdmin && ( (chatRoomModel && chatRoomModel.canHandleParticipants) || conferenceModel)
	property bool haveEncryption: chatRoomModel && chatRoomModel.haveEncryption
	spacing: ParticipantsListViewStyle.mainLayout.spacing

	SmartSearchBar {
		id: smartSearchBar

		Layout.fillWidth: true
		Layout.topMargin: ParticipantsListViewStyle.searchBar.topMargin

		showHeader:false

		visible: mainLayout.canHandleParticipants

		maxMenuHeight: MainWindowStyle.searchBox.maxHeight
		//: 'Add Participants' : Placeholder in a search bar for adding participant to the chat room
		placeholderText: qsTr('addParticipantPlaceholder')
		//: 'Search participants in your contact list in order to invite them into the chat room.'
		//~ Tooltip Explanation for inviting the selected participants into chat room
		tooltipText: qsTr('addParticipantTooltip')
		actions:[{
				colorSet: ParticipantsListViewStyle.addParticipant,
				secure: mainLayout.haveEncryption,
				visible: true,
				secureIconVisibleHandler : function(entry) {
					return entry.sipAddress && mainLayout.haveEncryption && UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh, true);
				},
				handler: function (entry) {
					selectedParticipants.addAddress(entry.sipAddress)
				},
			}]
		participantListModel: selectedParticipants.participantListModel

		onEntryClicked: {
			selectedParticipants.addAddress(entry.sipAddress)
		}
	}


	ScrollableListViewField {
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.bottomMargin: 5

		textFieldStyle: TextFieldStyle.unbordered

		ColumnLayout{
			anchors.fill:parent
			spacing:0
			Text{
				Layout.topMargin: ParticipantsListViewStyle.results.title.topMargin
				Layout.leftMargin: ParticipantsListViewStyle.results.title.leftMargin
				//: 'Participant list'
				text:qsTr('participantList')
				color: ParticipantsListViewStyle.results.title.colorModel.color
				font.pointSize:ParticipantsListViewStyle.results.title.pointSize
				font.weight: ParticipantsListViewStyle.results.title.weight
			}
			Text{
				Layout.preferredHeight: implicitHeight
				Layout.rightMargin: ParticipantsListViewStyle.results.header.rightMargin
				Layout.alignment: Qt.AlignRight | Qt.AlignBottom
				//Layout.topMargin: ParticipantsListViewStyle.results.topMargin
				//: 'Admin' : Admin(istrator)
				//~ one word for admin status
				text : qsTr('adminStatus')

				color: ParticipantsListViewStyle.results.header.colorModel.color
				font.pointSize: ParticipantsListViewStyle.results.header.pointSize
				font.weight: ParticipantsListViewStyle.results.header.weight
				visible: mainLayout.isAdmin && participantView.count > 0

			}

			ParticipantsView {
				id: participantView
				Layout.fillHeight: true
				Layout.fillWidth: true

				showSubtitle:false
				showSwitch : mainLayout.isAdmin
				showSeparator: false
				showAdminStatus:!mainLayout.isAdmin
				isSelectable: false
				hoveredCursor:Qt.WhatsThisCursor


				actions:  mainLayout.isAdmin ? [{
												  colorSet: ParticipantsListViewStyle.removeParticipant,
												  secure:0,
												  visible:true,
												  visibleHandler: function(entry){
													return !UtilsCpp.isMe(entry.sipAddress)
												  },
												  //: 'Remove this participant from the list' : Tootltip to explain that the action will lead to remove the participant.
												  tooltipText: qsTr('participantsListRemoveTooltip'),
												  handler: function (entry) {
													  selectedParticipants.removeModel(entry)
												  }
											  }]
										   : []

				genSipAddress: ''

				model: ParticipantProxyModel {
					id:selectedParticipants
					chatRoomModel: mainLayout.chatRoomModel
					conferenceModel: mainLayout.conferenceModel
					onAddressAdded: smartSearchBar.addAddressToIgnore(sipAddress)
					onAddressRemoved: smartSearchBar.removeAddressToIgnore(sipAddress)
					showMe: true
				}

				onEntryClicked: {
					contactItem.showSubtitle = !contactItem.showSubtitle
				}
			}
		}
	}
}
