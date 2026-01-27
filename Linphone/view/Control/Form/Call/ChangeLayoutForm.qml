import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

FocusScope {
	id: mainItem
	property var call
	property int conferenceLayout: call && call.core.conferenceVideoLayout || 0
	signal changeLayoutRequested(int index)

	ColumnLayout {
		anchors.fill: parent
        anchors.topMargin: Utils.getSizeWithScreenRatio(16)
        anchors.bottomMargin: Utils.getSizeWithScreenRatio(16)
        anchors.leftMargin: Utils.getSizeWithScreenRatio(17)
        anchors.rightMargin: Utils.getSizeWithScreenRatio(17)
        spacing: Utils.getSizeWithScreenRatio(12)

		RoundedPane {
			Layout.fillWidth: true
			contentItem: ColumnLayout {
				spacing: 0
				Repeater {
					model: [
                        {text: qsTr("conference_layout_grid"), imgUrl: AppIcons.layout},
                        {text: qsTr("conference_layout_active_speaker"), imgUrl: AppIcons.pip},
                        {text: qsTr("conference_layout_audio_only"), imgUrl: AppIcons.waveform}
					]
					RadioButton {
						id: radiobutton
						enabled: mainItem.call && !mainItem.call.core.paused
						checkOnClick: false
						color: DefaultStyle.main1_500_main
                        indicatorSize: Utils.getSizeWithScreenRatio(20)
						leftPadding: indicator.width + spacing
                        spacing: Utils.getSizeWithScreenRatio(8)
						checkable: false	// Qt Documentation is wrong: It is true by default. We don't want to change the checked state if the layout change is not effective.
						checked: index == 0
									? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.Grid
									: index == 1
										? mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.ActiveSpeaker
										: mainItem.conferenceLayout === LinphoneEnums.ConferenceLayout.AudioOnly
						onClicked: mainItem.changeLayoutRequested(index)

						contentItem: RowLayout {
                            spacing: Utils.getSizeWithScreenRatio(5)
							EffectImage {
								id: radioButtonImg
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
								imageSource: modelData.imgUrl
								colorizationColor: DefaultStyle.main2_500_main
							}
							Text {
								text: modelData.text
								color: DefaultStyle.main2_500_main
								verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Utils.getSizeWithScreenRatio(14)
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
