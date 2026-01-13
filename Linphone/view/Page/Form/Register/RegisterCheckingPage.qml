import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

LoginLayout {
	id: mainItem
	signal returnToRegister()
	signal sendCode(string code)
	property bool registerWithEmail
	property string address
	property string sipIdentityAddress
	property string code
	property alias errorMessage: codeItemLayout.errorMessage
	property bool ctrlIsPressed
	onCtrlIsPressedChanged: console.log("ctrl is pressed", ctrlIsPressed)
	titleContent: [
		RowLayout {
            spacing: Utils.getSizeWithScreenRatio(21)
            Layout.leftMargin: Utils.getSizeWithScreenRatio(119)
			Button {
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
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
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(34)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(34)
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
            anchors.leftMargin: Utils.getSizeWithScreenRatio(127)
            spacing: Utils.getSizeWithScreenRatio(104)
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
			FormItemLayout {
				id: codeItemLayout
				errorTextTopMargin: Utils.getSizeWithScreenRatio(5)
				contentItem: RowLayout {
					spacing: Utils.getSizeWithScreenRatio(45)
					Repeater {
						model: 4
						id: repeater
						signal pasteRequested(string text)
						DigitInput {
							id: digitInput
							required property int index
							Layout.preferredWidth: width
							Layout.preferredHeight: height
							isError: codeItemLayout.errorMessage !== ""
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
			}
			RowLayout {
                spacing: Utils.getSizeWithScreenRatio(20)
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
            anchors.topMargin: Utils.getSizeWithScreenRatio(140)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(97)
            width: Utils.getSizeWithScreenRatio(477)
            height: Utils.getSizeWithScreenRatio(345)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.verif_page_image
		}
	]
}
 
