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
        anchors.topMargin: Math.round(16 * DefaultStyle.dp)
        anchors.bottomMargin: Math.round(16 * DefaultStyle.dp)
        anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
        anchors.rightMargin: Math.round(17 * DefaultStyle.dp)
        spacing: Math.round(12 * DefaultStyle.dp)

		RoundedPane {
			Layout.fillWidth: true
			contentItem: ColumnLayout {
				spacing: 0
				Repeater {
					model: [
                        {text: qsTr("conference_layout_grid"), imgUrl: AppIcons.squaresFour},
                        {text: qsTr("conference_layout_active_speaker"), imgUrl: AppIcons.pip},
                        {text: qsTr("conference_layout_audio_only"), imgUrl: AppIcons.waveform}
					]
					RadioButton {
						id: radiobutton
						checkOnClick: false
						color: DefaultStyle.main1_500_main
                        indicatorSize: Math.round(20 * DefaultStyle.dp)
						leftPadding: indicator.width + spacing
                        spacing: Math.round(8 * DefaultStyle.dp)
						checkable: false	// Qt Documentation is wrong: It is true by default. We don't want to change the checked state if the layout change is not effective.
						checked: index == 0
									? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.Grid
									: index == 1
										? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.ActiveSpeaker
										: mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.AudioOnly
						onClicked: mainItem.changeLayoutRequested(index)

						contentItem: RowLayout {
                            spacing: Math.round(5 * DefaultStyle.dp)
							EffectImage {
								id: radioButtonImg
                                Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
								imageSource: modelData.imgUrl
								colorizationColor: DefaultStyle.main2_500main
							}
							Text {
								text: modelData.text
								color: DefaultStyle.main2_500main
								verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Math.round(14 * DefaultStyle.dp)
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
