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
                //: "Choisir votre mode"
                text: qsTr("manage_account_choose_mode_title")
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
				}
			}
			Text {
                //: "Vous pourrez changer de mode plus tard."
                text: qsTr("manage_account_choose_mode_message")
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
                    //: "Chiffrement de bout en bout"
                    {checked: true, title: qsTr("manage_account_e2e_encrypted_mode_default_title"),
                        //: "Ce mode vous garanti la confidentialité de tous vos échanges. Notre technologie de chiffrement de bout en bout assure un niveau de sécurité maximal pour tous vos échanges."
                        text: qsTr("manage_account_e2e_encrypted_mode_default_summary"), imgUrl: AppIcons.chiffrement, color: DefaultStyle.info_500_main},
                    //: "Interoperable"
                    {checked: false, title: qsTr("manage_account_e2e_encrypted_mode_interoperable_title"),
                        //: "Ce mode vous permet de profiter de toute les fonctionnalités de Linphone, toute en restant interopérable avec n’importe qu’elle autre service SIP."
                        text: qsTr("manage_account_e2e_encrypted_mode_interoperable_summary"), imgUrl: AppIcons.interoperable, color: DefaultStyle.main1_500_main}
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
            //: "Continuer"
            text: qsTr("dialog_continue")
			style: ButtonStyle.main
			onClicked: mainItem.modeSelected(selectedIndex)
		}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
 
