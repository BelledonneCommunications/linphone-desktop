import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Layouts
import Linphone
import UtilsCpp

import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

Control.Control {
	id: mainItem
		
	// property alias placeholderText: sendingTextArea.placeholderText
	property string text
	property var textArea
	property int selectedFilesCount: 0
	// property alias cursorPosition: sendingTextArea.cursorPosition
	
	property bool dropEnabled: true
	property bool isEphemeral : false
	property bool emojiVisible: false

	// disable record button if call ongoing
	property bool callOngoing: false
	property bool isEditing: false

    property ChatGui chat

	signal focusTextArea()
	
	// ---------------------------------------------------------------------------
	
	signal dropped (var files)
	signal validText (string text)
	signal sendMessage()
	signal emojiClicked()
	signal composing()

	// ---------------------------------------------------------------------------
	
	function _emitFiles (files) {
		// Filtering files, other urls are forbidden.
		files = files.reduce(function (files, file) {
			if (file.toString().startsWith("file:")) {
				files.push(Utils.getSystemPathFromUri(file))
			}
			
			return files
		}, [])
		if (files.length > 0) {
			dropped(files)
		}
	}

	FileDialog {
		id: fileDialog
		fileMode: FileDialog.OpenFiles
		onAccepted: _emitFiles(fileDialog.selectedFiles)
	}

	// width: mainItem.implicitWidth
	// height: mainItem.height
	leftPadding: Utils.getSizeWithScreenRatio(15)
	rightPadding: Utils.getSizeWithScreenRatio(15)
	topPadding: Utils.getSizeWithScreenRatio(16)
	bottomPadding: Utils.getSizeWithScreenRatio(16)
	
	background: Rectangle {
		anchors.fill: parent
		color: DefaultStyle.grey_100
	}
	contentItem: Control.StackView {
		id: sendingAreaStackView
		initialItem: textAreaComp
		onHeightChanged: {
			mainItem.height = height + mainItem.topPadding + mainItem.bottomPadding
		}
		Component {
			id: textAreaComp
			RowLayout {
				spacing: Utils.getSizeWithScreenRatio(16)
				PopupButton {
					id: emojiPickerButton
					visible: !mainItem.isEditing
					style: ButtonStyle.noBackground
					icon.source: checked ? AppIcons.closeX : AppIcons.smiley
					popup.width: Utils.getSizeWithScreenRatio(393)
					popup.height: Utils.getSizeWithScreenRatio(291)
					popup.contentItem: EmojiPicker {
						editor: sendingTextArea
					}
				}
				BigButton {
					style: ButtonStyle.noBackground
					icon.source: AppIcons.paperclip
					onClicked: {
						fileDialog.open()
					}
				}
				Control.Control {
					id: sendingControl
					Layout.preferredHeight: mainItem.height - mainItem.topPadding - mainItem.rightPadding
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignCenter
					leftPadding: Utils.getSizeWithScreenRatio(24)
					rightPadding: Utils.getSizeWithScreenRatio(20)
					topPadding: Utils.getSizeWithScreenRatio(12)
					bottomPadding: Utils.getSizeWithScreenRatio(12)
					background: Rectangle {
						id: inputBackground
						anchors.fill: parent
						radius: Utils.getSizeWithScreenRatio(35)
						color: DefaultStyle.grey_0
						MouseArea {
							anchors.fill: parent
							onPressed: sendingTextArea.forceActiveFocus()
							cursorShape: Qt.IBeamCursor
						}
					}
					contentItem: RowLayout {
						Flickable {
							id: sendingAreaFlickable
							Layout.fillHeight: true
							width: sendingControl.width - sendingControl.leftPadding - sendingControl.rightPadding
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignCenter
							contentHeight: sendingTextArea.contentHeight
							contentWidth: width

							onContentHeightChanged: {
								if (sendingTextArea.contentHeight > mainItem.height - (mainItem.topPadding + mainItem.bottomPadding + sendingControl.topPadding + sendingControl.bottomPadding)
								&& sendingTextArea.contentHeight < Utils.getSizeWithScreenRatio(100)) {
									mainItem.height = sendingTextArea.contentHeight + mainItem.topPadding + mainItem.bottomPadding + sendingControl.topPadding + sendingControl.bottomPadding
								}
							}

							function ensureVisible(r) {
								if (contentX >= r.x)
									contentX = r.x;
								else if (contentX+width <= r.x+r.width)
									contentX = r.x+r.width-width;
								if (contentY >= r.y)
									contentY = r.y;
								else if (contentY+height <= r.y+r.height)
									contentY = r.y+r.height-height;
							}

							TextArea {
								id: sendingTextArea
								width: sendingAreaFlickable.width
								height: implicitHeight// sendingAreaFlickable.height
								textFormat: TextEdit.PlainText
								onTextChanged: {
									mainItem.text = text
								}
								
								Component.onCompleted: {
									mainItem.textArea = sendingTextArea
									sendingTextArea.text = mainItem.text
								}
								//: Say something… : placeholder text for sending message text area
								placeholderText: qsTr("chat_view_send_area_placeholder_text")
								placeholderTextColor: DefaultStyle.main2_400
								color: DefaultStyle.main2_700
								font {
									pixelSize: Typography.p1.pixelSize
									weight: Typography.p1.weight
								}
								onCursorRectangleChanged: sendingAreaFlickable.ensureVisible(cursorRectangle)
								wrapMode: TextEdit.WordWrap
								KeyNavigation.tab: recordButton.visible ? recordButton : sendMessageButton
								Keys.onPressed: (event) => {
									if ((event.key == Qt.Key_Enter || event.key == Qt.Key_Return))
										if(!(event.modifiers & Qt.ShiftModifier)) {
										mainItem.sendMessage()
										event.accepted = true
									}
								}
								Connections {
									target: mainItem
									function onTextChanged() {
										sendingTextArea.text = mainItem.text
									}
									function onSendMessage() {
										sendingTextArea.clear()
									}
									function onFocusTextArea() {
										sendingTextArea.forceActiveFocus()
									}
								}
							}
						}
						RowLayout {
							id: stackButton
							spacing: 0
							Layout.preferredHeight: Math.max(recordButton.height, sendMessageButton.height)
							BigButton {
								id: recordButton
								ToolTip.visible: !enabled && hovered
								//: Cannot record a message while a call is ongoing
								ToolTip.text: qsTr("cannot_record_while_in_call_tooltip")
								enabled: !mainItem.callOngoing
								visible: !mainItem.callOngoing && sendingTextArea.text.length === 0 && mainItem.selectedFilesCount === 0 && !mainItem.isEditing
								style: ButtonStyle.noBackground
								hoverEnabled: true
								icon.source: AppIcons.microphone
								onClicked: {
									sendingAreaStackView.push(voiceMessageRecordComp)
								}
							}
							BigButton {
								id: sendMessageButton
								Layout.preferredHeight: height
								visible: sendingTextArea.text.length !== 0 || mainItem.selectedFilesCount > 0
								style: ButtonStyle.noBackgroundOrange
								icon.source: mainItem.isEditing ? AppIcons.pencil : AppIcons.paperPlaneRight
								onClicked: {
									mainItem.sendMessage()
								}
							}
						}
					}
				}
			}
		}
		Component {
			id: voiceMessageRecordComp
			RowLayout {
				spacing: Utils.getSizeWithScreenRatio(16)
				RoundButton {
					style: ButtonStyle.player
					shadowEnabled: true
					padding: Utils.getSizeWithScreenRatio(4)
					icon.width: Utils.getSizeWithScreenRatio(22)
					icon.height: Utils.getSizeWithScreenRatio(22)
					icon.source: AppIcons.closeX
					width: Utils.getSizeWithScreenRatio(30)
					Layout.preferredWidth: width
					Layout.preferredHeight: height
					onClicked: {
						if (voiceMessage.chatMessage) mainItem.chat.core.lDeleteMessage(voiceMessage.chatMessage)
						sendingAreaStackView.pop()
					}
				}
				ChatAudioContent {
					id: voiceMessage
					onHeightChanged: {
						sendingAreaStackView.height = height
					}
					recording: true
					Layout.fillWidth: true
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
					chatMessageContentGui: chatMessage ? chatMessage.core.getVoiceRecordingContent() : null
					onVoiceRecordingMessageCreationRequested: (recorderGui) => {
						chatMessageObj = UtilsCpp.createVoiceRecordingMessage(recorderGui, mainItem.chat)
					}
				}
				BigButton {
					id: sendButton
					style: ButtonStyle.noBackgroundOrange
					icon.source: AppIcons.paperPlaneRight
					icon.width: Utils.getSizeWithScreenRatio(22)
					icon.height: Utils.getSizeWithScreenRatio(22)
					// Layout.preferredWidth: icon.width
					// Layout.preferredHeight: icon.height
					property bool sendVoiceRecordingOnCreated: false
					onClicked: {
						if (voiceMessage.chatMessage) {
							voiceMessage.chatMessage.core.lSend()
							sendingAreaStackView.pop()
						}
						else {
							sendVoiceRecordingOnCreated = true
							voiceMessage.stopRecording()
						}
					}
					Connections {
						target: voiceMessage
						function onChatMessageChanged() {
							if (sendButton.sendVoiceRecordingOnCreated) {
								voiceMessage.chatMessage.core.lSend()
								sendButton.sendVoiceRecordingOnCreated = false
								sendingAreaStackView.pop()
							}
						}
					}
				}
			}
		}
	}

	Rectangle {
		id: hoverContent
		anchors.fill: parent
		color: DefaultStyle.main2_0
		visible: false
		radius: Utils.getSizeWithScreenRatio(20)

		EffectImage {
			anchors.centerIn: parent
			imageSource: AppIcons.filePlus
			width: Utils.getSizeWithScreenRatio(37)
			height: Utils.getSizeWithScreenRatio(37)
			colorizationColor: DefaultStyle.main2_500_main
		}

		DashRectangle {
			x: parent.x
			y: parent.y
			radius: hoverContent.radius
			color: DefaultStyle.main2_500_main
			width: parent.width
			height: parent.height
		}
	}
	DropArea {
		anchors.fill: parent
		keys: [ 'text/uri-list' ]
		visible: mainItem.dropEnabled
		
		onDropped: (drop) => {
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
