import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Effects

import Linphone
import UtilsCpp

// Fill contact, account or call
// Initials will be displayed if there isn't any avatar.
// TODO : get FriendGui from Call.

StackView{
	id: mainItem
	property AccountGui account: null
	property FriendGui contact: null
	property CallGui call: null
	property string address: account
								? account.core.identityAddress
								: call
									? call.core.peerAddress
									: ''
	property var displayNameObj: UtilsCpp.getDisplayName(address)
	property bool haveAvatar: (account && account.core.pictureUri )
								|| (contact && contact.core.pictureUri)
								
	onHaveAvatarChanged: replace(haveAvatar ? avatar : initials, StackView.Immediate)
	
	initialItem: haveAvatar ? avatar : initials
	Component{
		id: initials
		Rectangle {
			id: initialItem
			property string initials: UtilsCpp.getInitials(mainItem.displayNameObj.value)
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
				source: mainItem.account ? mainItem.account.core.pictureUri : mainItem.contact.core.pictureUri
				mipmap: true
			}
			ShaderEffect {
				id: roundEffect
				property variant src: image
				property double edge: 0.9
				anchors.fill: parent
				vertexShader: 'qrc:/data/shaders/roundEffect.vert.qsb'
				fragmentShader: 'qrc:/data/shaders/roundEffect.frag.qsb'
			}
		}
	}
}
