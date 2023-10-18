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
			background: Rectangle {
				color: "transparent"
			}
			contentItem: Image {
				source: AppIcons.returnArrow
				fillMode: Image.PreserveAspectFit
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
			text: {
				var completeString =  (mainItem.email.length > 0) ? "email" : "phone number"
				text = "Register | Register with your " + completeString
			}
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
	}

	centerContent: ColumnLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
		Text {
			Layout.alignment: Qt.AlignTop
			font.bold: true
			text: {
				var completeString = (mainItem.email.length > 0) ? ("email" + mainItem.email) : ("phone number" + mainItem.phoneNumber)
				text = "We have sent a verification code on your " + completeString + " <br>Please enter the verification code below:"
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Layout.margins: 10
			ColumnLayout {
				RowLayout {
					// Layout.fillWidth: true
					DigitInput {
						id: first
						onTextEdited: if (text.length > 0 ) second.forceActiveFocus()
						Layout.margins: 10
					}
					DigitInput {
						id: second
						onTextEdited: if (text.length > 0 ) third.forceActiveFocus()
						Layout.margins: 10
					}
					DigitInput {
						id: third
						onTextEdited: if (text.length > 0 ) fourth.forceActiveFocus()
						Layout.margins: 10
					}
					DigitInput {
						id: fourth
						Layout.margins: 10
						// onTextEdited: validate()
					}
				}
				RowLayout {
					// Layout.topMargin: 10
					Text {
						Layout.rightMargin: 15
						text: "Didn't receive the code ?"
						font.pointSize: DefaultStyle.defaultTextSize
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
				Layout.rightMargin: 40
				Layout.preferredWidth: 300
				fillMode: Image.PreserveAspectFit
				source: AppIcons.verif_page_image
			}
		}
	}
}
 
