import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
	id: mainItem
	implicitHeight: message.height
	//width: parent.width
	Layout.fillWidth: true
	//onWidthChanged: console.log(width)
	
	property alias isHovering: message.isHovering
	property alias isTopGrouped: message.isTopGrouped
	property alias isBottomGrouped: message.isBottomGrouped
	
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	signal goToMessage(ChatMessageModel message)
	signal conferenceIcsCopied()
	signal addContactClicked(string contactAddress)
	signal viewContactClicked(string contactAddress)
	RowLayout{
	/*
		anchors {
				left: parent.left
				//leftMargin: ChatStyle.entry.metaWidth
				right: parent.right
			}
			*/
		//width: parent.width
		anchors.fill: parent
		//onWidthChanged: console.log(width)
		spacing: 0
		//spacing: ChatStyle.entry.message.extraContent.spacing
		Message {
			id: message
			
			onCopyAllDone: mainItem.copyAllDone()
			onCopySelectionDone: mainItem.copySelectionDone()
			onReplyClicked: mainItem.replyClicked()
			onForwardClicked: mainItem.forwardClicked()
			onGoToMessage: mainItem.goToMessage(message)
			onConferenceIcsCopied: mainItem.conferenceIcsCopied()
			onAddContactClicked: mainItem.addContactClicked(contactAddress)
			onViewContactClicked: mainItem.viewContactClicked(contactAddress)
			/*
			anchors {
				left: parent.left
				leftMargin: ChatStyle.entry.metaWidth
				right: parent.right
			}*/
			backgroundColorModel: ChatStyle.entry.message.outgoing.backgroundColor
			Layout.fillWidth: true
			//Layout.fillHeight: true
			Layout.leftMargin: 10
			//onImplicitHeightChanged: Layout.preferredHeight= implicitHeight
			Layout.minimumHeight: implicitHeight	// Avoid bug where UI is not computed by Qt
			Layout.preferredHeight: implicitHeight
			//Layout.preferredWidth: parent.width
			//width: parent.width
			// Not a style. Workaround to avoid a 0 width.
			// Arbitrary value.
			Layout.minimumWidth: 1
			//onWidthChanged: console.log(width)
			
		}
		/*
		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: ChatStyle.entry.message.extraContent.leftMargin
			spacing: ChatStyle.entry.message.extraContent.spacing
			*/
			Component {
				id: iconComponent
				Item{
					Icon {
						id: iconId
						readonly property var isError: Utils.includes([
																		  LinphoneEnums.ChatMessageStateFileTransferError,
																		  LinphoneEnums.ChatMessageStateNotDelivered,
																	  ], $chatEntry.state)
						readonly property bool isUploaded: $chatEntry.state == LinphoneEnums.ChatMessageStateDelivered
						readonly property bool isDelivered: $chatEntry.state == LinphoneEnums.ChatMessageStateDeliveredToUser
						readonly property bool isRead: $chatEntry.state == LinphoneEnums.ChatMessageStateDisplayed
						
						icon: iconId.isError
							  ? 'chat_error'
							  : (iconId.isRead ? 'chat_read' : (iconId.isDelivered  ? 'chat_delivered' : '' ) )
						iconSize: ChatStyle.entry.message.outgoing.sendIconSize
						anchors.bottom: parent.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						MouseArea {
							id:retryAction
							anchors.fill: parent
							visible: iconId.isError || $chatEntry.state == LinphoneEnums.ChatMessageStateIdle
							onClicked: $chatEntry.resendMessage()
						}
						
						TooltipArea {
							id:tooltip
							visible: text != ''
							text: iconId.isError
								  ? qsTr('messageError')
								  : (iconId.isRead ? qsTr('messageRead') : (iconId.isDelivered ? qsTr('messageDelivered') : ''))
							hoveringCursor : retryAction.visible?Qt.PointingHandCursor:Qt.ArrowCursor
						}
					}
				}
			}
			
			Component {
				id: indicator
				
				Item {
					BusyIndicator {
						anchors.centerIn: parent
						
						height: ChatStyle.entry.message.outgoing.busyIndicatorSize
						width: ChatStyle.entry.message.outgoing.busyIndicatorSize
					}
				}
			}
			
			Loader {
				//height: ChatStyle.entry.lineHeight
				//anchors.bottom: parent.bottom
				//Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
				Layout.preferredWidth: ChatStyle.entry.message.outgoing.areaSize
				Layout.fillHeight: true
				//Layout.rightMargin: 10
				
				sourceComponent: $chatEntry.state == LinphoneEnums.ChatMessageStateInProgress || $chatEntry.state == LinphoneEnums.ChatMessageStateFileTransferInProgress
								 ? indicator
								 : iconComponent
			}
		//}
	}
	/*
	Rectangle{
						anchors.fill: parent
						color: 'yellow'
					}
					*/
}
