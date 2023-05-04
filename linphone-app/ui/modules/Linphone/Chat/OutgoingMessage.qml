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
	
	Layout.fillWidth: true
	
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
	
	implicitHeight: message.height
	RowLayout{
		anchors.fill: parent
		spacing: 0
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
			
			backgroundColorModel: ChatStyle.entry.message.outgoing.backgroundColor
			Layout.fillWidth: true
			Layout.leftMargin: 10
			//onImplicitHeightChanged: Layout.preferredHeight= implicitHeight
			//Layout.minimumHeight: implicitHeight	// Avoid bug where UI is not computed by Qt
			//Layout.preferredHeight: implicitHeight
			
			// Not a style. Workaround to avoid a 0 width.
			// Arbitrary value.
			Layout.minimumWidth: 1
			
		}
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
			Layout.preferredWidth: ChatStyle.entry.message.outgoing.areaSize
			Layout.fillHeight: true
			
			sourceComponent: $chatEntry.state == LinphoneEnums.ChatMessageStateInProgress || $chatEntry.state == LinphoneEnums.ChatMessageStateFileTransferInProgress
							 ? indicator
							 : iconComponent
		}
	}
	/*
	Rectangle{
						anchors.fill: parent
						color: 'yellow'
					}
					*/
}
