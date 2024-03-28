import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Effects

import Linphone
import UtilsCpp

// Fill contact, account or call
// Initials will be displayed if there isn't any avatar.
// TODO : get FriendGui from Call.

StackView {
	id: mainItem
	property AccountGui account: null
	property FriendGui contact: null
	property CallGui call: null
	property string address: account
								? account.core.identityAddress
								: call
									? call.core.peerAddress
									: contact
										? contact.core.defaultAddress
										: ''
	property var displayNameObj: UtilsCpp.getDisplayName(address)
	property string displayNameVal: displayNameObj ? displayNameObj.value : ""
	property bool haveAvatar: (account && account.core.pictureUri )
								|| (contact && contact.core.pictureUri)
								|| computedAvatarUri.length != 0
	property string computedAvatarUri: UtilsCpp.findAvatarByAddress(address)
								
	onHaveAvatarChanged: replace(haveAvatar ? avatar : initials, StackView.Immediate)

	property bool secured: false
	
	initialItem: haveAvatar ? avatar : initials

	Rectangle {
		visible: mainItem.secured
		anchors.fill: mainItem.currentItem
		radius: mainItem.width / 2
		z: 1
		color: "transparent"
		border {
			width: 3 * DefaultStyle.dp
			color: DefaultStyle.info_500_main
		}
		Image {
			source: AppIcons.trusted
			x: mainItem.width / 7
			width: mainItem.width / 4.5
			height: width
			sourceSize.width: width
			sourceSize.height: height
			fillMode: Image.PreserveAspectFit
			anchors.bottom: parent.bottom
		}
	}
	Rectangle {
		visible: (account || contact) && (account 
			? account.core.registrationState != LinphoneEnums.RegistrationState.Progress && account.core.registrationState != LinphoneEnums.RegistrationState.Refreshing
			: contact.core.consolidatedPresence != LinphoneEnums.ConsolidatedPresence.Offline)
		width: mainItem.width/4.5
		height: width
		radius: width / 2
		x: 2 * mainItem.width / 3
		y: 6 * mainItem.height / 7
		z: 1
		color: account
			? account.core.registrationState == LinphoneEnums.RegistrationState.Ok
				? DefaultStyle.success_500main
				: account.core.registrationState == LinphoneEnums.RegistrationState.Cleared || account.core.registrationState == LinphoneEnums.RegistrationState.None
					? DefaultStyle.warning_600
					: account.core.registrationState == LinphoneEnums.RegistrationState.Progress || account.core.registrationState == LinphoneEnums.RegistrationState.Refreshing
						? DefaultStyle.main2_500main
						: DefaultStyle.danger_500main
			: contact
				? contact.core.consolidatedPresence === LinphoneEnums.ConsolidatedPresence.Online
					? DefaultStyle.success_500main
					: contact.core.consolidatedPresence === LinphoneEnums.ConsolidatedPresence.Busy
						? DefaultStyle.warning_600
						: contact.core.consolidatedPresence === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
							? DefaultStyle.danger_500main
							: DefaultStyle.main2_500main
			: "transparent"
		border {
			width: 2 * DefaultStyle.dp
			color: DefaultStyle.grey_0
		}
	}
	Component{
		id: initials
		Rectangle {
			id: initialItem
			property string initials: UtilsCpp.getInitials(mainItem.displayNameVal)
			radius: width / 2
			color: DefaultStyle.main2_200
			height: mainItem.height
			width: height
			Text {
				anchors.fill: parent
				anchors.centerIn: parent
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				text: initialItem.initials
				font {
					pixelSize: initialItem.height * 36 / 120
					weight: 800 * DefaultStyle.dp
					capitalization: Font.AllUppercase
				}
			}
			Image {
				visible: initialItem.initials.length === 0
				width: mainItem.width/3
				height: width
				source: AppIcons.profile
				anchors.centerIn: parent
			}
		}
	}
	Component{
		id: avatar
		Item {
			id: avatarItem
			height: mainItem.height
			width: height
			Image {
				id: image
				visible: false
				width: parent.width
				height: parent.height
				sourceSize.width: avatarItem.width
				sourceSize.height: avatarItem.height
				fillMode: Image.PreserveAspectCrop
				anchors.centerIn: parent
				source: mainItem.account && mainItem.account.core.pictureUri 
					|| mainItem.contact && mainItem.contact.core.pictureUri
					|| computedAvatarUri
				mipmap: true
				layer.enabled: true
			}
			ShaderEffect {
				id: roundEffect
				property variant src: image
				property real edge: 0.9
				property real edgeSoftness: 0.9
				property real radius: width / 2.0
				property real shadowSoftness: 0.5
				property real shadowOffset: 0.01
				anchors.fill: parent
				fragmentShader: 'qrc:/data/shaders/roundEffect.frag.qsb'
			}
		}
	}
}
