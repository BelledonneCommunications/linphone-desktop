import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

LoginLayout {
	id: mainItem
	signal modeSelected(int index)

	titleContent: RowLayout {
		EffectImage {
			fillMode: Image.PreserveAspectFit
			imageSource: AppIcons.profile
			colorizationColor: DefaultStyle.main2_600
            Layout.preferredHeight: Math.round(34 * DefaultStyle.dp)
            Layout.preferredWidth: Math.round(34 * DefaultStyle.dp)
		}
		ColumnLayout {
			Text {
				text: qsTr("Choisir votre mode")
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
				}
			}
			Text {
				text: qsTr("Vous pourrez changer de mode plus tard.")
				font.bold: true
				font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
				}
			}
		}
	}

	centerContent: ColumnLayout {
        spacing: Math.round(80 * DefaultStyle.dp)
		RowLayout {
			id: radioButtonsLayout
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
            spacing: Math.round(70 * DefaultStyle.dp)
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
            Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
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
 
