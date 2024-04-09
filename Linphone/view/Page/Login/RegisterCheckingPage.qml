import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal returnToRegister()
	property string phoneNumber
	property string email

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
					var completeString =  (mainItem.email.length > 0) ? qsTr("email") : qsTr("numéro")
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
					var completeString = (mainItem.email.length > 0) ? ("email \"" + mainItem.email + "\"") : ("phone number \"" + mainItem.phoneNumber + "\"")
					text = "We have sent a verification code on your " + completeString + " <br>Please enter the verification code below:"
				}
			}
			RowLayout {
				spacing: 45 * DefaultStyle.dp
				Repeater {
					model: 4
					DigitInput {
						required property int index
						Layout.preferredWidth: width
						Layout.preferredHeight: height
						onTextEdited: {
							if (text.length > 0 ) {
								if (index < 3)
									nextItemInFocusChain(true).forceActiveFocus()
								else {
									// TODO : validate()
								}
							} else {
								if (index > 0)
									nextItemInFocusChain(false).forceActiveFocus()
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
			anchors.rightMargin: 97.03 * DefaultStyle.dp
			width: 476.78 * DefaultStyle.dp
			height: 345.13 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			source: AppIcons.verif_page_image
		}
	]
}
 
