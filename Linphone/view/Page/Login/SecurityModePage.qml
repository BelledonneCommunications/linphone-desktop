import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal modeSelected(int index)

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		ColumnLayout {
			Text {
				text: qsTr("Choisir votre mode")
				font {
					pixelSize: 36 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			}
			Text {
				text: qsTr("Vous pourrez changer de mode plus tard.")
				font.bold: true
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
			}
		}
	}

	centerContent: ColumnLayout {
		spacing: 80 * DefaultStyle.dp
		Layout.topMargin: 70 * DefaultStyle.dp
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		RowLayout {
			id: radioButtonsLayout
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			spacing: 70 * DefaultStyle.dp
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
						if (checked) continueButton.selectedIndex = index
					}
				}
			}
		}
		Button {
			id: continueButton
			property int selectedIndex: 0
			Layout.alignment: Qt.AlignHCenter
			leftPadding: 100 * DefaultStyle.dp
			rightPadding: 100 * DefaultStyle.dp
			text: qsTr("Continuer")
			onClicked: mainItem.modeSelected(selectedIndex)
		}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
 
