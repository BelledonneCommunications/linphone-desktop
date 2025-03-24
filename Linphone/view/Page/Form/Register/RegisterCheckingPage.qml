import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
            spacing: Math.round(21 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(119 * DefaultStyle.dp)
			Button {
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
				onClicked: {
					console.debug("[RegisterCheckingPage] User: return to register")
					mainItem.returnToRegister()
				}
			}
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
                Layout.preferredHeight: Math.round(34 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(34 * DefaultStyle.dp)
				colorizationColor: DefaultStyle.main2_600
			}
			Text {
				wrapMode: Text.NoWrap
				text: {
                    //: "email"
                    var completeString =  mainItem.registerWithEmail ? qsTr("email")
                                                                       //: "numéro de téléphone"
                                                                     : qsTr("phone_number")
                    //: "Inscription | Confirmer votre %1"
                    text = qsTr("confirm_register_title").arg(completeString)
				}
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
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
            anchors.leftMargin: Math.round(127 * DefaultStyle.dp)
            spacing: Math.round(104 * DefaultStyle.dp)
			Text {
				font {
					bold: true
                    pixelSize: Typography.h3.pixelSize
                    weight: Typography.h3.weight
				}
				color: DefaultStyle.main2_700
                text: {
                    var completeString = mainItem.registerWithEmail ? ("email") : ("phone_number")
                    //: Nous vous avons envoyé un code de vérification sur votre %1 %2<br> Merci de le saisir ci-dessous
                    text = qsTr("assistant_account_creation_confirmation_explanation").arg(completeString).arg(address)
				}
			}
			RowLayout {
                spacing: Math.round(45 * DefaultStyle.dp)
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
                spacing: Math.round(20 * DefaultStyle.dp)
				Text {
                    //: "Vous n'avez pas reçu le code ?"
                    text: qsTr("assistant_account_creation_confirmation_did_not_receive_code")
					color: DefaultStyle.main2_700
                    font.pixelSize: Typography.p1.pixelSize
                    font.weight: Typography.p1.weight
				}
				BigButton {
					style: ButtonStyle.secondary
                    //: "Renvoyer un code"
                    text: qsTr("assistant_account_creation_confirmation_resend_code")
					onClicked: {
						console.debug("[RegisterCheckingPage] User: Resend code")
					}
				}
			}
		},
		Image {
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Math.round(140 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(97 * DefaultStyle.dp)
            width: Math.round(477 * DefaultStyle.dp)
            height: Math.round(345 * DefaultStyle.dp)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.verif_page_image
		}
	]
}
 
