import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0

ColumnLayout {
	id: mainItem
	property var call
	property string objectName: "statsPanel"
	spacing: 20 * DefaultStyle.dp
	
	RoundedPane {
		Layout.fillWidth: true
		leftPadding: 16 * DefaultStyle.dp
		rightPadding: 16 * DefaultStyle.dp
		topPadding: 13 * DefaultStyle.dp
		bottomPadding: 13 * DefaultStyle.dp

		Layout.topMargin: 13 * DefaultStyle.dp
		Layout.leftMargin: 16 * DefaultStyle.dp
		Layout.rightMargin: 16 * DefaultStyle.dp
		
		contentItem: ColumnLayout {
			spacing: 12 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			Text {
				text: qsTr("Audio")
				Layout.alignment: Qt.AlignHCenter
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 700 * DefaultStyle.dp
				}
			}
			ColumnLayout {
				spacing: 8 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.audioStats.jitterBufferSize : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
			}
		}
	}
	RoundedPane {
		Layout.fillWidth: true
		leftPadding: 16 * DefaultStyle.dp
		rightPadding: 16 * DefaultStyle.dp
		topPadding: 13 * DefaultStyle.dp
		bottomPadding: 13 * DefaultStyle.dp

		Layout.leftMargin: 16 * DefaultStyle.dp
		Layout.rightMargin: 16 * DefaultStyle.dp

		visible: mainItem.call?.core.localVideoEnabled || mainItem.call?.core.remoteVideoEnabled || false

		contentItem: ColumnLayout {
			spacing: 12 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			Text {
				text: qsTr("Vidéo")
				Layout.alignment: Qt.AlignHCenter
				font {
					pixelSize: 12 * DefaultStyle.dp
					weight: 700 * DefaultStyle.dp
				}
			}
			ColumnLayout {
				spacing: 8 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.codec : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.bandwidth : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.lossRate : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.resolution : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.call ? mainItem.call.core.videoStats.fps : ""
					Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
			}
		}
	}
	Item{Layout.fillHeight: true}
}
