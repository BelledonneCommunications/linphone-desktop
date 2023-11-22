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
			Layout.preferredHeight: 40
    		Layout.preferredWidth: 40
			icon.width: 40
			icon.height: 40
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
		spacing: 2
		Text {
			Layout.alignment: Qt.AlignTop
			font.bold: true
			font.pointSize: DefaultStyle.defaultFontPointSize
			color: DefaultStyle.questionTextColor
			text: {
				var completeString = (mainItem.email.length > 0) ? ("email " + mainItem.email) : ("phone number " + mainItem.phoneNumber)
				text = "We have sent a verification code on your " + completeString + " <br>Please enter the verification code below:"
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Layout.margins: 10
			ColumnLayout {
				spacing: 70
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
							Layout.margins: 10
						}
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignBottom
					Text {
						Layout.rightMargin: 15
						text: "Didn't receive the code ?"
						color: DefaultStyle.questionTextColor
						font.pointSize: DefaultStyle.indicatorMessageTextSize
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
		Item {
			Layout.fillHeight: true
		}
	}
}
 
