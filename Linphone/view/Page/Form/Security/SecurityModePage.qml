import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone

LoginLayout {
	id: mainItem
	signal modeSelected(int index)

	titleContent: RowLayout {
		EffectImage {
			fillMode: Image.PreserveAspectFit
			imageSource: AppIcons.profile
			colorizationColor: DefaultStyle.main2_600
			Layout.preferredHeight: 34 * DefaultStyle.dp
			Layout.preferredWidth: 34 * DefaultStyle.dp
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
		RowLayout {
			id: radioButtonsLayout
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			spacing: 70 * DefaultStyle.dp
			Repeater {
				model: [
					{checked: true, title: qsTr("Chiffrement de bout en bout"), text: qsTr("Ce mode vous garanti la confidentialité de tous vos échanges. Notre technologie de chiffrement de bout en bout assure un niveau de sécurité maximal pour tous vos échanges."), imgUrl: AppIcons.chiffrement, color: DefaultStyle.info_500_main},
					{checked: false, title: qsTr("Interoperable"), text: qsTr("Ce mode vous permet de profiter de toute les fonctionnalités de Linphone, toute en restant interopérable avec n’importe qu’elle autre service SIP."), imgUrl: AppIcons.interoperable, color: DefaultStyle.main1_500_main}
				]
				SecurityRadioButton {
					title: modelData.title
					contentText: modelData.text
					imgUrl: modelData.imgUrl
					checked: modelData.checked
					color: modelData. color
					onCheckedChanged: {
						if (checked) continueButton.selectedIndex = index
					}
				}
			}
		}
		BigButton {
			id: continueButton
			property int selectedIndex: 0
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 360 * DefaultStyle.dp
			text: qsTr("Continuer")
			style: ButtonStyle.main
			onClicked: mainItem.modeSelected(selectedIndex)
		}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
 
