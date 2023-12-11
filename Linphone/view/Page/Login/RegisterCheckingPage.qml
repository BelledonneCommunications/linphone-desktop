import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal returnToRegister()
	property string phoneNumber
	property string email

	titleContent: RowLayout {
		Control.Button {
			Layout.preferredHeight: 40 * DefaultStyle.dp
    		Layout.preferredWidth: 40 * DefaultStyle.dp
			icon.width: 40 * DefaultStyle.dp
			icon.height: 40 * DefaultStyle.dp
			icon.source: AppIcons.returnArrow
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
				var completeString =  (mainItem.email.length > 0) ? qsTr("email") : qsTr("numéro")
				text = qsTr("Inscription | Confirmer votre ") + completeString
			}
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
	}

	centerContent: ColumnLayout {
		spacing: 2 * DefaultStyle.dp
		Text {
			Layout.alignment: Qt.AlignTop
			font.bold: true
			font.pixelSize: DefaultStyle.defaultFontPointSize
			color: DefaultStyle.main2_700
			text: {
				var completeString = (mainItem.email.length > 0) ? ("email " + mainItem.email) : ("phone number " + mainItem.phoneNumber)
				text = "We have sent a verification code on your " + completeString + " <br>Please enter the verification code below:"
			}
			font {
				pixelSize: 22 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Layout.margins: 10 * DefaultStyle.dp
			ColumnLayout {
				spacing: 70 * DefaultStyle.dp
				RowLayout {
					Repeater {
						model: 4
						DigitInput {
							required property int index
							onTextEdited: if (text.length > 0 ) {
								if (index < 3)
									nextItemInFocusChain(true).forceActiveFocus()
								else {
									// validate()
								}
							} else {
								if (index > 0)
									nextItemInFocusChain(false).forceActiveFocus()
							} 
							Layout.margins: 10 * DefaultStyle.dp
						}
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignBottom
					Text {
						Layout.rightMargin: 15 * DefaultStyle.dp
						text: "Didn't receive the code ?"
						color: DefaultStyle.main2_700
						font.pixelSize: 14 * DefaultStyle.dp
						font.weight: 400 * DefaultStyle.dp
					}
					Button {
						Layout.alignment: Qt.AlignRight
						inversedColors: true
						text: "Resend a code"
						onClicked: {
							console.debug("[RegisterCheckingPage] User: Resend code")
						}
					}
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Image {
				Layout.rightMargin: 40 * DefaultStyle.dp
				Layout.preferredWidth: 300 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				source: AppIcons.verif_page_image
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
 
