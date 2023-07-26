import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import Units 1.0
import ColorsList 1.0
import UtilsCpp 1.0

// =============================================================================
// TODO : into Loader
Item {
	id:mainRow
	
	property ChatMessageModel chatMessageModel: contentModel && contentModel.chatMessageModel
	property ContentModel contentModel
	property int fitHeight: fileView.fitHeight
	property int fitWidth: fileView.fitWidth
	property alias borderWidth: fileView.borderWidth
	property alias backgroundColor: fileView.backgroundColor
	property alias backgroundRadius: fileView.backgroundRadius
	property alias isHovering: fileView.isHovering
	
	// ---------------------------------------------------------------------------
	// File message.
	// ---------------------------------------------------------------------------
	Rectangle {
		id: rectangle
		color: 'transparent'
		anchors.fill: parent
		radius: ChatStyle.entry.message.radius
		
		FileView{
			id: fileView
			anchors.fill: parent
			contentModel: mainRow.contentModel
			thumbnail: mainRow.contentModel ? mainRow.contentModel.thumbnail : ''
			name: mainRow.contentModel && mainRow.contentModel.name
			filePath: mainRow.contentModel && mainRow.contentModel.filePath
			isTransferring: mainRow.chatMessageModel && (mainRow.chatMessageModel.state == LinphoneEnums.ChatMessageStateFileTransferInProgress || mainRow.chatMessageModel.state == LinphoneEnums.ChatMessageStateInProgress )
			isOutgoing: mainRow.chatMessageModel && mainRow.chatMessageModel.isOutgoing
		}
	}
}