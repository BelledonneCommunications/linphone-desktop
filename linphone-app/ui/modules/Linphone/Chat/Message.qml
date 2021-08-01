import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import 'Message.js' as Logic

// =============================================================================

Item {
	id: container
	
	// ---------------------------------------------------------------------------
	
	property alias backgroundColor: rectangle.color
	property alias color: message.color
	property alias pointSize: message.font.pointSize
	
	default property alias _content: content.data
	
	// ---------------------------------------------------------------------------
	
	implicitHeight: message.contentHeight 
						+ (ephemeralTimerRow.visible? message.padding * 4 : message.padding * 2) 
						+ (deliveryLayout.visible? deliveryLayout.height : 0)
	
	Rectangle {
		id: rectangle
		
		height: parent.height - (deliveryLayout.visible? deliveryLayout.height : 0)
		radius: ChatStyle.entry.message.radius
		width: (
				   message.contentWidth < ephemeralTimerRow.width
				   ? ephemeralTimerRow.width
				   : message.contentWidth < parent.width
					 ? message.contentWidth
					 : parent.width
				   ) + message.padding * 2
		Row{
			id:ephemeralTimerRow
			anchors.right:parent.right
			anchors.bottom:parent.bottom	
			anchors.bottomMargin: 5
			anchors.rightMargin : 5
			visible:$chatEntry.isEphemeral
			spacing:5
			Text{
				visible : $chatEntry.ephemeralExpireTime > 0
				text: Utils.formatElapsedTime($chatEntry.ephemeralExpireTime)
				color:"#FF5E00"
				font.pointSize: Units.dp * 8
				Timer{
					running:parent.visible
					interval: 1000
					repeat:true
					onTriggered: parent.text = Utils.formatElapsedTime($chatEntry.getEphemeralExpireTime())// Use the function
				}
			}
			Icon{
				icon:'timer'
				iconSize: 15
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Message.
	// ---------------------------------------------------------------------------
	
	TextEdit {
		id: message
		
		anchors {
			left: container.left
			right: container.right
		}
		
		clip: true
		padding: ChatStyle.entry.message.padding
		readOnly: true
		selectByMouse: true
		text: Utils.encodeTextToQmlRichFormat($chatEntry.content, {
												  imagesHeight: ChatStyle.entry.message.images.height,
												  imagesWidth: ChatStyle.entry.message.images.width
											  })
		
		// See http://doc.qt.io/qt-5/qml-qtquick-text.html#textFormat-prop
		// and http://doc.qt.io/qt-5/richtext-html-subset.html
		textFormat: Text.RichText // To supports links and imgs.
		wrapMode: TextEdit.Wrap
		
		onCursorRectangleChanged: Logic.ensureVisible(cursorRectangle)
		onLinkActivated: Qt.openUrlExternally(link)
		
		onActiveFocusChanged: deselect()
		
		Menu {
			id: messageMenu
			menuStyle : MenuStyle.aux
			MenuItem {
				text: qsTr('menuCopy')
				iconMenu: 'menu_copy_text'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				onTriggered: Clipboard.text = $chatEntry.content
			}
			
			MenuItem {
				enabled: TextToSpeech.available
				text: qsTr('menuPlayMe')
				iconMenu: 'speaker'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				onTriggered: TextToSpeech.say($chatEntry.content)
			}
			MenuItem {
				text: 'Delivery Status'
				iconMenu: 'menu_imdn_info'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				visible: deliveryLayout.model.rowCount() > 0
				onTriggered: deliveryLayout.visible = !deliveryLayout.visible
			}
			MenuItem {
				text: 'Delete'
				iconMenu: 'menu_delete'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.auxRed
				onTriggered: deliveryLayout.visible = !deliveryLayout.visible
			}
		}

		
		
		// Handle hovered link.
		MouseArea {
			height: parent.height
			width: rectangle.width
			
			acceptedButtons: Qt.RightButton
			cursorShape: parent.hoveredLink
						 ? Qt.PointingHandCursor
						 : Qt.IBeamCursor
			
			onClicked: mouse.button === Qt.RightButton && messageMenu.open()
		}
	}
	
	// ---------------------------------------------------------------------------
	// Extra content.
	// ---------------------------------------------------------------------------
	
	Item {
		id: content
		
		anchors {
			left: rectangle.right
			leftMargin: ChatStyle.entry.message.extraContent.leftMargin
		}
	}
	GridView{
		id: deliveryLayout
		anchors.top:rectangle.bottom
		anchors.left:parent.left
		anchors.right:parent.right
		anchors.rightMargin: 50
		//height: visible ? ChatStyle.composingText.height*container.proxyModel.composers.length : 0
		height: visible ? (ChatStyle.composingText.height-5)*deliveryLayout.model.rowCount() : 0
		cellWidth: parent.width; cellHeight: ChatStyle.composingText.height-5
		visible:false
		/*
		property var composersLength : container.proxyModel.composers.length
		onComposersLengthChanged:{
			model.clear()
			console.log(container.proxyModel.composers)
			for(var j  = 0 ; j < container.proxyModel.composers.length ; ++j) {
				console.log(container.proxyModel.composers[j])
				model.append({text:container.proxyModel.composers[j]})
			}
		}*/
		model: $chatEntry.getProxyImdnStates()
			property var i18n: [
				'Envoyé à %1 - %2',	// LinphoneEnums.ChatMessageStateDelivered
				'Reçu par %1 - %2',	// LinphoneEnums.ChatMessageStateDeliveredToUser
				'Lu par %1 - %2' ,	// LinphoneEnums.ChatMessageStateDisplayed
				"%1 n'a encore rien reçu"	// LinphoneEnums.ChatMessageStateNotDelivered
			]
		function getText(state){
			if(state == LinphoneEnums.ChatMessageStateDelivered)
				return i18n[0]
			else if(state == LinphoneEnums.ChatMessageStateDeliveredToUser)
				return i18n[1]
			else if(state == LinphoneEnums.ChatMessageStateDisplayed)
				return i18n[2]
			else if(state == LinphoneEnums.ChatMessageStateNotDelivered)
				return i18n[3]
			else return ''
		}
		delegate:Text{
			height:ChatStyle.composingText.height-5
			width:parent.width
			text:deliveryLayout.getText(modelData.state).arg(modelData.displayName).arg(UtilsCpp.toDateTimeString(modelData.stateChangeTime))
			color:"#B1B1B1"
			font.pointSize: Units.dp * 8
			elide: Text.ElideMiddle
		}
	}
}
