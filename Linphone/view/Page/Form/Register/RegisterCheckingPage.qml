import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp

LoginLayout {
	id: mainItem
	signal returnToRegister()
	signal sendCode(string code)
	property bool registerWithEmail
	property string address
	property string sipIdentityAddress
	property string code
	property bool ctrlIsPressed
	onCtrlIsPressedChanged: console.log("ctrl is pressed", ctrlIsPressed)
	titleContent: [
		RowLayout {
			spacing: 21 * DefaultStyle.dp
			Layout.leftMargin: 119 * DefaultStyle.dp
			Button {
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				background: Rectangle {
					color: "transparent"
				}
				onClicked: {
					console.debug("[RegisterCheckingPage] User: return to register")
					mainItem.returnToRegister()
				}
			}
			Image {
				fillMode: Image.PreserveAspectFit
				source: AppIcons.profile
			}
			Text {
				wrapMode: Text.NoWrap
				text: {
					var completeString =  mainItem.registerWithEmail ? qsTr("email") : qsTr("numéro")
					text = qsTr("Inscription | Confirmer votre ") + completeString
				}
				font {
					pixelSize: 36 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		}
	]

	centerContent: [
		ColumnLayout {
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.topMargin: 51 * DefaultStyle.dp
			anchors.leftMargin: 127 * DefaultStyle.dp
			spacing: 104 * DefaultStyle.dp
			Text {
				font {
					bold: true
					pixelSize: 22 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
				color: DefaultStyle.main2_700
				text: {
					var completeString = mainItem.registerWithEmail ? ("email \"") : ("phone number \"") + address + "\""
					text = "We have sent a verification code on your " + completeString + " <br>Please enter the verification code below:"
				}
			}
			RowLayout {
				spacing: 45 * DefaultStyle.dp
				Repeater {
					model: 4
					id: repeater
					signal pasteRequested(string text)
					DigitInput {
						id: digitInput
						required property int index
						Layout.preferredWidth: width
						Layout.preferredHeight: height
						Connections {
							target: repeater
							function onPasteRequested(text) {
								console.log("paste requested", text[digitInput.index])
								var test= text;
								if (UtilsCpp.isInteger(text))
								{
									digitInput.text = text[digitInput.index]
								}
							}
						}
						onTextChanged: {
							console.log("text edited", text)
							if (text.length > 0 ) {
								mainItem.code = mainItem.code.slice(0, index) + text + mainItem.code.slice(index)
								if (index < 3)
									nextItemInFocusChain(true).forceActiveFocus()
								else {
									mainItem.sendCode(mainItem.code)
									mainItem.code = ""
								}
							} else {
								if (index > 0)
									nextItemInFocusChain(false).forceActiveFocus()
							}
						}
						Keys.onPressed: (event) => {
							if (event.key == Qt.Key_Backspace) {
								if (text.length === 0) {
									nextItemInFocusChain(false).forceActiveFocus()
									event.accepted = true
								} else {
								event.accepted = false
								}
							} else if (event.key == Qt.Key_Control) {
								mainItem.ctrlIsPressed = true
								event.accepted = false
							} else if (mainItem.ctrlIsPressed && event.key == Qt.Key_V) {
								var clipboard = UtilsCpp.getClipboardText()
								console.log("paste", clipboard)
								repeater.pasteRequested(clipboard)
							} else {
								event.accepted = false
							}
						}
						Keys.onReleased: (event) => {
							if (event.key == Qt.Key_Control) {
								mainItem.ctrlIsPressed = false
								event.accepted = true
							}
						}
					}
				}
			}
			RowLayout {
				spacing: 20 * DefaultStyle.dp
				Text {
					text: "Didn't receive the code ?"
					color: DefaultStyle.main2_700
					font.pixelSize: 14 * DefaultStyle.dp
					font.weight: 400 * DefaultStyle.dp
				}
				Button {
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					inversedColors: true
					text: "Resend a code"
					onClicked: {
						console.debug("[RegisterCheckingPage] User: Resend code")
					}
				}
			}
		},
		Image {
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.topMargin: 140 * DefaultStyle.dp
			anchors.rightMargin: 97 * DefaultStyle.dp
			width: 477 * DefaultStyle.dp
			height: 345 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			source: AppIcons.verif_page_image
		}
	]
}
 
