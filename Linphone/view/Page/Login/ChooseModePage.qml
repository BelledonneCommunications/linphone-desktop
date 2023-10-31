import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal modeChosen(int index)

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		ColumnLayout {
			Text {
				text: qsTr("Choisir votre mode")
				font.pointSize: DefaultStyle.title2FontPointSize
				font.bold: true
				scaleLettersFactor: 1.1
			}
			Text {
				text: qsTr("Vous pourrez changer de mode plus tard.")
				font.bold: true
				scaleLettersFactor: 1.1
			}
		}
	}

	centerContent: ColumnLayout {
		spacing: 80
		Layout.topMargin: 70
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		RowLayout {
			id: radioButtonsLayout
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			spacing: 70
			Repeater {
				model: [
					{checked: true, title: qsTr("Chiffrement de bout en bout"), text: qsTr("Ce mode vous garanti la confidentialité de tous vos échanges. Notre technologie de chiffrement de bout en bout assure un niveau de sécurité maximal pour tous vos échanges."), imgUrl: AppIcons.chiffrement},
					{checked: false, title: qsTr("Interoperable"), text: qsTr("Ce mode vous permet de profiter de toute les fonctionnalités de Linphone, toute en restant interopérable avec n’importe qu’elle autre service SIP."), imgUrl: AppIcons.interoperable}
				]
				RadioButton {
					title: modelData.title
					contentText: modelData.text
					imgUrl: modelData.imgUrl
					checked: modelData.checked
					onCheckedChanged: {
						if (checked) continueButton.chosenIndex = index
					}
				}
			}
		}
		Button {
			id: continueButton
			property int chosenIndex: 0
			Layout.alignment: Qt.AlignHCenter
			leftPadding: 100
			rightPadding: 100
			text: qsTr("Continuer")
			onClicked: mainItem.modeChosen(chosenIndex)
		}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
 
