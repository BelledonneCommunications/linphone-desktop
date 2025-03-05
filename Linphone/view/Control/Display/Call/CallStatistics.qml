import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0

ColumnLayout {
	id: mainItem
	property var call
	property string objectName: "statsPanel"
    spacing: Math.round(20 * DefaultStyle.dp)
	
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Math.round(16 * DefaultStyle.dp)
        rightPadding: Math.round(16 * DefaultStyle.dp)
        topPadding: Math.round(13 * DefaultStyle.dp)
        bottomPadding: Math.round(13 * DefaultStyle.dp)

        Layout.topMargin: Math.round(13 * DefaultStyle.dp)
        Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		
		contentItem: ColumnLayout {
            spacing: Math.round(12 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignHCenter
			Text {
                //: "Audio"
                text: qsTr("call_stats_audio_title")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Math.round(8 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.jitterBufferSize : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
			}
		}
	}
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Math.round(16 * DefaultStyle.dp)
        rightPadding: Math.round(16 * DefaultStyle.dp)
        topPadding: Math.round(13 * DefaultStyle.dp)
        bottomPadding: Math.round(13 * DefaultStyle.dp)

        Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(16 * DefaultStyle.dp)

		visible: mainItem.call?.core.localVideoEnabled || mainItem.call?.core.remoteVideoEnabled || false

		contentItem: ColumnLayout {
            spacing: Math.round(12 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignHCenter
			Text {
                //: "Vidéo"
                text: qsTr("call_stats_video_title")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Math.round(8 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.resolution : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.fps : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
			}
		}
	}
	Item{Layout.fillHeight: true}
}
