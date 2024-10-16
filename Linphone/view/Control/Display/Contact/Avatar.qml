import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp

// Fill contact, account or call
// Initials will be displayed if there isn't any avatar.
// TODO : get FriendGui from Call.
Loader{
	id: mainItem
	property AccountGui account: null
	property FriendGui contact: null
	property CallGui call: null
	property string _address: account
		? account.core?.identityAddress || ""
		: call
			? call.core.remoteAddress
			: contact
				? contact.core.defaultAddress
				: ''
	readonly property string address: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_address) : _address
	property var displayNameObj: UtilsCpp.getDisplayName(_address)
	property string displayNameVal: contact
		? contact.core.displayName
		: displayNameObj
			? displayNameObj.value
			: ""
	property bool haveAvatar: (account && account.core?.pictureUri || false)
							  || (contact && contact.core.pictureUri)
							  || computedAvatarUri.length != 0
	property var avatarObj: UtilsCpp.findAvatarByAddress(_address)
	property string computedAvatarUri: avatarObj ? avatarObj.value : ''
	
	property var securityLevelObj: UtilsCpp.getFriendAddressSecurityLevel(_address)
	property var securityLevel: securityLevelObj ? securityLevelObj.value : LinphoneEnums.SecurityLevel.None
	property bool secured: call && call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
						   ? call.core.tokenVerified
						   : contact
							 ? contact.core.devices.length != 0 && contact.core.verifiedDeviceCount === contact.core.devices.length
							 : securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncrypted
	
	property bool securityBreach: securityLevel === LinphoneEnums.SecurityLevel.Unsafe
	
	property bool displayPresence: account 
								   ? account.core?.registrationState != LinphoneEnums.RegistrationState.Progress && account.core?.registrationState != LinphoneEnums.RegistrationState.Refreshing || false
								   : contact
									 ? contact.core?.consolidatedPresence != LinphoneEnums.ConsolidatedPresence.Offline || false
									 : false
	
	
	asynchronous: true
	sourceComponent: Component{
		Item {
			anchors.fill: parent
			
			MultiEffect {
				source: stackView
				anchors.fill: stackView
				shadowEnabled: true
				shadowBlur: 0.1
				shadowColor: DefaultStyle.grey_1000
				shadowOpacity: 0.1
			}
			StackView {
				id: stackView
				
				initialItem: mainItem.haveAvatar ? avatar : initials
				anchors.fill: parent
				
				Connections{
					target: mainItem
					onHaveAvatarChanged: function(haveAvatar) {stackView.replace(haveAvatar ? avatar : initials, StackView.Immediate)}
				}
				
				Rectangle {
					visible: mainItem.secured || mainItem.securityBreach
					anchors.fill: stackView.currentItem
					radius: stackView.width / 2
					z: 1
					color: "transparent"
					border {
						width: 3 * DefaultStyle.dp
						color: mainItem.secured ? DefaultStyle.info_500_main : DefaultStyle.danger_500main
					}
					Image {
						x: stackView.width / 7
						anchors.bottom: parent.bottom
						width: stackView.width / 4.5
						height: width
						asynchronous: true
						source: mainItem.secured ? AppIcons.trusted : AppIcons.notTrusted
						sourceSize.width: width
						sourceSize.height: height
						fillMode: Image.PreserveAspectFit
						
					}
				}
				Rectangle {
					visible: mainItem.displayPresence
					width: stackView.width/4.5
					height: width
					radius: width / 2
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					anchors.rightMargin: stackView.width / 15
					z: 1
					color: account
						   ? account.core?.registrationState == LinphoneEnums.RegistrationState.Ok
							 ? DefaultStyle.success_500main
							 : account.core?.registrationState == LinphoneEnums.RegistrationState.Cleared || account.core?.registrationState == LinphoneEnums.RegistrationState.None
							   ? DefaultStyle.warning_600
							   : account.core?.registrationState == LinphoneEnums.RegistrationState.Progress || account.core?.registrationState == LinphoneEnums.RegistrationState.Refreshing
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
					Item {
						id: avatarItem
						height: stackView.height
						width: height
						Rectangle {
							id: initialItem
							property string initials: UtilsCpp.getInitials(mainItem.displayNameVal)
							radius: width / 2
							color: DefaultStyle.main2_200
							height: stackView.height
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
								id: initialImg
								visible: initialItem.initials == ''
								width: stackView.width/3
								height: width
								source: AppIcons.profile
								sourceSize.width: width
								sourceSize.height: height
								anchors.centerIn: parent
							}
						}
						MultiEffect {
							source: initialItem
							anchors.fill: initialItem
							shadowEnabled: true
							shadowBlur: 0.1
							shadowColor: DefaultStyle.grey_1000
							shadowOpacity: 0.1
						}
					}
				}
				Component{
					id: avatar
					Item {
						id: avatarItem
						height: stackView.height
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
		}
	}
}
