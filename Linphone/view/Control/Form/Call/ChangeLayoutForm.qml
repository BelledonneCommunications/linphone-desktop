import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0

FocusScope {
	id: mainItem
	property var call
	property int conferenceLayout: call && call.core.conferenceVideoLayout || 0
	signal changeLayoutRequested(int index)

	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: 16 * DefaultStyle.dp
		anchors.bottomMargin: 16 * DefaultStyle.dp
		anchors.leftMargin: 17 * DefaultStyle.dp
		anchors.rightMargin: 17 * DefaultStyle.dp
		spacing: 12 * DefaultStyle.dp
		Text {
			Layout.fillWidth: true
			text: qsTr("La disposition choisie sera enregistrée pour vos prochaines réunions")
			font.pixelSize: 14 * DefaultStyle.dp
			color: DefaultStyle.main2_500main
		}
		RoundedPane {
			Layout.fillWidth: true
			contentItem: ColumnLayout {
				spacing: 0
				Repeater {
					model: [
						{text: qsTr("Mosaïque"), imgUrl: AppIcons.squaresFour},
						{text: qsTr("Intervenant actif"), imgUrl: AppIcons.pip},
						{text: qsTr("Audio seulement"), imgUrl: AppIcons.waveform}
					]
					RadioButton {
						id: radiobutton
						checkOnClick: false
						color: DefaultStyle.main1_500_main
						indicatorSize: 20 * DefaultStyle.dp
						leftPadding: indicator.width + spacing
						spacing: 8 * DefaultStyle.dp
						checkable: false	// Qt Documentation is wrong: It is true by default. We don't want to change the checked state if the layout change is not effective.
						checked: index == 0
									? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.Grid
									: index == 1
										? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.ActiveSpeaker
										: mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.AudioOnly
						onClicked: mainItem.changeLayoutRequested(index)

						contentItem: RowLayout {
							spacing: 5 * DefaultStyle.dp
							EffectImage {
								id: radioButtonImg
								Layout.preferredWidth: 32 * DefaultStyle.dp
								Layout.preferredHeight: 32 * DefaultStyle.dp
								imageSource: modelData.imgUrl
								colorizationColor: DefaultStyle.main2_500main
							}
							Text {
								text: modelData.text
								color: DefaultStyle.main2_500main
								verticalAlignment: Text.AlignVCenter
								font.pixelSize: 14 * DefaultStyle.dp
								Layout.fillWidth: true
							}
						}
					}
				}
			}
		}
		Item {Layout.fillHeight: true}
	}
}