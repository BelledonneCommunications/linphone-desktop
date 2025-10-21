import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
	property var call
	property string objectName: "statsPanel"
    spacing: Utils.getSizeWithScreenRatio(20)
	
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Utils.getSizeWithScreenRatio(16)
        rightPadding: Utils.getSizeWithScreenRatio(16)
        topPadding: Utils.getSizeWithScreenRatio(13)
        bottomPadding: Utils.getSizeWithScreenRatio(13)

        Layout.topMargin: Utils.getSizeWithScreenRatio(13)
        Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
        Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
		
		contentItem: ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(12)
			Layout.alignment: Qt.AlignHCenter
			Text {
                //: "Audio"
                text: qsTr("call_stats_audio_title")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(8)
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.jitterBufferSize : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
			}
		}
	}
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Utils.getSizeWithScreenRatio(16)
        rightPadding: Utils.getSizeWithScreenRatio(16)
        topPadding: Utils.getSizeWithScreenRatio(13)
        bottomPadding: Utils.getSizeWithScreenRatio(13)

        Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
        Layout.rightMargin: Utils.getSizeWithScreenRatio(16)

		visible: mainItem.call && (mainItem.call.core.localVideoEnabled || mainItem.call.core.remoteVideoEnabled)

		contentItem: ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(12)
			Layout.alignment: Qt.AlignHCenter
			Text {
                //: "Vidéo"
                text: qsTr("call_stats_video_title")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(8)
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.resolution : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.fps : ""
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
			}
		}
	}
	Item{Layout.fillHeight: true}
}
