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
		
	property alias placeholderText: sendingTextArea.placeholderText
	property alias text: sendingTextArea.text
	property alias textArea: sendingTextArea
	property alias cursorPosition: sendingTextArea.cursorPosition
	property alias emojiPickerButtonChecked: emojiPickerButton.checked
	
	property bool dropEnabled: true
	property string dropDisabledReason
	property bool isEphemeral : false
	property bool emojiVisible: false
	
	// ---------------------------------------------------------------------------
	
	signal dropped (var files)
	signal validText (string text)
	signal sendText()
	signal audioRecordRequest()
	signal emojiClicked()
	signal composing()
	
	// ---------------------------------------------------------------------------
	
	function _emitFiles (files) {
		// Filtering files, other urls are forbidden.
		files = files.reduce(function (files, file) {
			console.log("dropping", file.toString())
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
	leftPadding: Math.round(15 * DefaultStyle.dp)
	rightPadding: Math.round(15 * DefaultStyle.dp)
	topPadding: Math.round(24 * DefaultStyle.dp)
	bottomPadding: Math.round(16 * DefaultStyle.dp)
	background: Rectangle {
		anchors.fill: parent
		color: DefaultStyle.grey_100
		MediumButton {
			id: expandButton
			anchors.top: parent.top
			anchors.topMargin: Math.round(4 * DefaultStyle.dp)
			anchors.horizontalCenter: parent.horizontalCenter
			style: ButtonStyle.noBackgroundOrange
			icon.source: checked ? AppIcons.downArrow : AppIcons.upArrow
			checkable: true
		}
	}
	contentItem: RowLayout {
		spacing: Math.round(20 * DefaultStyle.dp)
		RowLayout {
			spacing: Math.round(16 * DefaultStyle.dp)
			BigButton {
				id: emojiPickerButton
				style: ButtonStyle.noBackground
				checkable: true
				icon.source: checked ? AppIcons.closeX : AppIcons.smiley
			}
			BigButton {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.paperclip
				onClicked: {
					fileDialog.open()
				}
			}
			Control.Control {
				Layout.fillWidth: true
				leftPadding: Math.round(15 * DefaultStyle.dp)
				rightPadding: Math.round(15 * DefaultStyle.dp)
				topPadding: Math.round(15 * DefaultStyle.dp)
				bottomPadding: Math.round(15 * DefaultStyle.dp)
				background: Rectangle {
					id: inputBackground
					anchors.fill: parent
					radius: Math.round(35 * DefaultStyle.dp)
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
						Layout.fillWidth: true
						Layout.preferredHeight: Math.min(Math.round(60 * DefaultStyle.dp), contentHeight)
						Binding {
							target: sendingAreaFlickable
							when: expandButton.checked
							property: "Layout.preferredHeight"
							value: Math.round(250 * DefaultStyle.dp)
							restoreMode: Binding.RestoreBindingOrValue
						}
						Layout.fillHeight: true
						contentHeight: sendingTextArea.contentHeight
						contentWidth: width

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
							height: sendingAreaFlickable.height
							textFormat: TextEdit.AutoText
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
							Keys.onPressed: (event) => {
								if ((event.key == Qt.Key_Enter || event.key == Qt.Key_Return))
									if(!(event.modifiers & Qt.ShiftModifier)) {
									mainItem.sendText()
									event.accepted = true
								}
							}
						}
					}
					RowLayout {
						id: stackButton
						spacing: 0
						BigButton {
							visible: sendingTextArea.text.length === 0
							style: ButtonStyle.noBackground
							icon.source: AppIcons.microphone
							onClicked: {
								console.log("TODO : go to record message")
							}
						}
						BigButton {
							visible: sendingTextArea.text.length !== 0
							style: ButtonStyle.noBackgroundOrange
							icon.source: AppIcons.paperPlaneRight
							onClicked: {
								mainItem.sendText()
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
		radius: Math.round(20 * DefaultStyle.dp)

		EffectImage {
			anchors.centerIn: parent
			imageSource: AppIcons.filePlus
			width: Math.round(37 * DefaultStyle.dp)
			height: Math.round(37 * DefaultStyle.dp)
			colorizationColor: DefaultStyle.main2_500main
		}

		DashRectangle {
			x: parent.x
			y: parent.y
			radius: hoverContent.radius
			color: DefaultStyle.main2_500main
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