import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
//import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Linphone.Styles 1.0
import Units 1.0
import UtilsCpp 1.0


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
	onIsAdminChanged: console.log("participantsListView is admin : "+isAdmin)
	onCanHandleParticipantsChanged: console.log("CanHandleParticipants:"+canHandleParticipants)
	spacing: ParticipantsListViewStyle.mainLayout.spacing
	Component.onCompleted: console.log("participantsListView : " +isAdmin +", "+canHandleParticipants +", " +chatRoomModel+", "+conferenceModel + ", "+conferenceModel.localParticipant +", " +conferenceModel.localParticipant.adminStatus)

	SmartSearchBar {
		id: smartSearchBar

		Layout.fillWidth: true
		Layout.topMargin: ParticipantsListViewStyle.searchBar.topMargin

		showHeader:false

		visible: mainLayout.isAdmin && mainLayout.canHandleParticipants

		maxMenuHeight: MainWindowStyle.searchBox.maxHeight
		//: 'Add Participants' : Placeholder in a search bar for adding participant to the chat room
		placeholderText: 'addParticipantPlaceholder'
		//: 'Search participants in your contact list in order to invite them into the chat room.'
		//~ Tooltip Explanation for inviting the selected participants into chat room
		tooltipText: 'addParticipantTooltip'
		actions:[{
				colorSet: ParticipantsListViewStyle.addParticipant,
				secure: mainLayout.haveEncryption,
				visible: true,
				secureIconVisibleHandler : function(entry) {
					return entry.sipAddress && mainLayout.haveEncryption && UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh);
				},
				handler: function (entry) {
					selectedParticipants.addAddress(entry.sipAddress)
				},
			}]

		onEntryClicked: {
			selectedParticipants.addAddress(entry.sipAddress)
		}
	}


	ScrollableListViewField {
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.bottomMargin: 5

		//readOnly: toAddView.count >= conferenceManager.maxParticipants
		textFieldStyle: TextFieldStyle.unbordered

		ColumnLayout{
			anchors.fill:parent
			spacing:0
			Text{
				Layout.topMargin: ParticipantsListViewStyle.results.title.topMargin
				Layout.leftMargin: ParticipantsListViewStyle.results.title.leftMargin
				//: 'Participant list'
				text:qsTr('participantList')
				color: ParticipantsListViewStyle.results.title.color
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

				color: ParticipantsListViewStyle.results.header.color
				font.pointSize: ParticipantsListViewStyle.results.header.pointSize
				font.weight: ParticipantsListViewStyle.results.header.weight
				visible: mainLayout.isAdmin && participantView.count > 0

			}

			ParticipantsView {
				id: participantView
				Layout.fillHeight: true
				Layout.fillWidth: true
				//anchors.fill: parent

				showContactAddress:false
				showSwitch : mainLayout.isAdmin
				showSeparator: false
				showAdminStatus:!mainLayout.isAdmin
				isSelectable: false
				hoveredCursor:Qt.WhatsThisCursor


				actions:  mainLayout.isAdmin ? [{
												  colorSet: ParticipantsListViewStyle.removeParticipant,
												  secure:0,
												  visible:true,
												  tooltipText: 'Remove this participant from the selection',
												  handler: function (entry) {
													  selectedParticipants.removeModel(entry)
													  //							++lastContacts.reloadCount
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
					contactItem.showContactAddress = !contactItem.showContactAddress
				}
			}
		}
	}
}
