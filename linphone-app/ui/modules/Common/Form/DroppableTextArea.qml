import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12

import Common 1.0
import Linphone 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
	id: droppableTextArea
	
	property int minimumHeight
	property int maximumHeight
	
	property alias placeholderText: textArea.placeholderText
	property alias text: textArea.text
	property alias cursorPosition: textArea.cursorPosition
	property alias recordAudioToggled: recordAudioButton.toggled
	
	property bool dropEnabled: true
	property string dropDisabledReason
	property bool isEphemeral : false
	
	property int textLeftMargin: (fileChooserButton.visible? fileChooserButton.totalWidth + DroppableTextAreaStyle.fileChooserButton.margins: 0)
	property int textRightMargin: sendButton.visible ? sendButton.totalWidth + DroppableTextAreaStyle.fileChooserButton.margins : 0
	
	// ---------------------------------------------------------------------------
	
	signal dropped (var files)
	signal validText (string text)
	signal audioRecordRequest()
	
	// ---------------------------------------------------------------------------
	
	function _emitFiles (files) {
		// Filtering files, other urls are forbidden.
		files = files.reduce(function (files, file) {
			if (file.startsWith('file:')) {
				files.push(Utils.getSystemPathFromUri(file))
			}
			
			return files
		}, [])
		
		if (files.length > 0) {
			dropped(files)
		}
	}
	
	Rectangle{
		anchors.fill: parent
		color: DroppableTextAreaStyle.outsideBackgroundColor
		// ---------------------------------------------------------------------------
		RowLayout{
			anchors.fill: parent
			spacing: 0
			// Handle click to select files.
			ActionButton {
				id: fileChooserButton
				property int totalWidth: width
				
				Layout.leftMargin: DroppableTextAreaStyle.fileChooserButton.margins
				Layout.alignment: Qt.AlignVCenter
				//anchors.verticalCenter: parent.verticalCenter
				enabled: droppableTextArea.dropEnabled
				isCustom: true
				backgroundRadius: 8
				colorSet: DroppableTextAreaStyle.fileChooserButton
					
				visible: droppableTextArea.enabled
				
				onClicked: fileDialog.open()
				
				FileDialog {
					id: fileDialog
					
					folder: shortcuts.home
					title: qsTr('fileChooserTitle')
					
					onAccepted: _emitFiles(fileDialog.fileUrls)
				}
				tooltipText: droppableTextArea.dropEnabled
							 ? qsTr('attachmentTooltip')
							 : droppableTextArea.dropDisabledReason
			}
			// Record audio
			ActionButton {
				id: recordAudioButton
				visible: droppableTextArea.enabled
				
				Layout.alignment: Qt.AlignVCenter
				Layout.leftMargin: 0
				enabled: droppableTextArea.dropEnabled
				isCustom: true
				backgroundRadius: 8
				colorSet: DroppableTextAreaStyle.chatMicro
				
				onClicked: droppableTextArea.audioRecordRequest()
				
			}
			
			// Text area.
			Flickable {
				id:flickableArea
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.maximumHeight: parent.height-20
				Layout.topMargin: 10
				Layout.bottomMargin: 10
				Layout.leftMargin: 2
				//anchors.fill: parent
				boundsBehavior: Flickable.StopAtBounds
				clip:true
				
				ScrollBar.vertical: ForceScrollBar {
					id: scrollBar
					visible:false
				}
				
				TextArea.flickable: TextArea {
					id: textArea
					onLineCountChanged: {
						if(textArea.contentHeight+20<droppableTextArea.minimumHeight) {
							droppableTextArea.height = droppableTextArea.minimumHeight
							scrollBar.visible = false
						}else if(textArea.contentHeight+30<droppableTextArea.maximumHeight) {
							droppableTextArea.height = textArea.contentHeight+30
							scrollBar.visible = false
						}else {
							var lineHeight = textArea.contentHeight/lineCount
							
							droppableTextArea.height = droppableTextArea.maximumHeight - (droppableTextArea.maximumHeight % lineHeight)
							scrollBar.visible = true
						}
					}
					function handleValidation () {
							validText(text)
					}

					background: Rectangle {
						color: DroppableTextAreaStyle.backgroundColor
						radius: 5
						clip:true
					}
					
					color: DroppableTextAreaStyle.text.color
					font.pointSize: DroppableTextAreaStyle.text.pointSize-1
					rightPadding: fileChooserButton.width +
								  fileChooserButton.anchors.rightMargin +
								  DroppableTextAreaStyle.fileChooserButton.margins
					selectByMouse: true
					wrapMode: TextArea.Wrap
					
					// Workaround. Without this line, the scrollbar is not linked correctly
					// to the text area.
					width: parent.width
					height:flickableArea.height
					//onHeightChanged: height=flickableArea.height//TextArea change its height from content text. Force it to parent
					
					Component.onCompleted: forceActiveFocus()
					
					property var isAutoRepeating : false // shutdown repeating key feature to let optional menu appears and do normal stuff (like accents menu)
					Keys.onReleased: {
						if( event.isAutoRepeat){// We begin or are currently repeating a key
							if(!isAutoRepeating){// We start repeat. Check if this is an "ignore" character
								if(event.key > Qt.Key_Any && event.key <= Qt.Key_ydiaeresis)// Remove the previous character if it is a printable character
									textArea.remove(cursorPosition-1, cursorPosition)
							}
						}else
							isAutoRepeating = false// We are no more repeating. Final decision is done on Releasing
					}
					Keys.onPressed: {
						if(event.isAutoRepeat){
							isAutoRepeating = true// Where are repeating the key. Set the state.
							if(event.key > Qt.Key_Any && event.key <= Qt.Key_ydiaeresis){// Ignore character if it is repeating and printable character
								event.accepted = true
							}
						}else if (event.matches(StandardKey.InsertLineSeparator)) {
							insert(cursorPosition, '')
						} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
							handleValidation()
							event.accepted = true
						}
					}
				}
			}
			
			// Handle click to select files.
			ActionButton {
				id: sendButton
				property int totalWidth: Layout.rightMargin + Layout.leftMargin + width
				Layout.rightMargin: droppableTextArea.isEphemeral ? 20 : 15
				Layout.leftMargin: droppableTextArea.isEphemeral ? 5 : 10
				Layout.alignment: Qt.AlignVCenter
				visible: droppableTextArea.enabled
				isCustom: true
				backgroundRadius: 8
				colorSet: DroppableTextAreaStyle.send
				
				onClicked: textArea.handleValidation()
				Icon{
					visible:droppableTextArea.isEphemeral
					icon: DroppableTextAreaStyle.ephemeralTimer.icon
					overwriteColor: DroppableTextAreaStyle.ephemeralTimer.timerColor
					iconSize: DroppableTextAreaStyle.ephemeralTimer.iconSize
					anchors.right:parent.right
					anchors.bottom : parent.bottom
					anchors.rightMargin:-20
				}
			}
		}
		// Hovered style.
		Rectangle {
			id: hoverContent
			
			anchors.fill: parent
			color: DroppableTextAreaStyle.hoverContent.backgroundColor
			visible: false
			
			Text {
				anchors.centerIn: parent
				color: DroppableTextAreaStyle.hoverContent.text.color
				font.pointSize: DroppableTextAreaStyle.hoverContent.text.pointSize
				text: qsTr('dropYourAttachment')
			}
		}
		DropArea {
			anchors.fill: parent
			keys: [ 'text/uri-list' ]
			visible: droppableTextArea.dropEnabled
			
			onDropped: {
				state = ''
				if (drop.hasUrls) {
					_emitFiles(drop.urls)
				}
			}
			onEntered: state = 'hover'
			onExited: state = ''
			
			states: State {
				name: 'hover'
				PropertyChanges { target: hoverContent; visible: true }
			}
		}
	}
}
