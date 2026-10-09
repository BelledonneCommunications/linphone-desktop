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

	component StatText: Text {
		id: statText
		activeFocusOnTab: text.length > 0
		property string accessibleText
		onTextChanged: if (!activeFocus) accessibleText = text
		onActiveFocusChanged: if (activeFocus) accessibleText = text
		Component.onCompleted: accessibleText = text
		Accessible.role: Accessible.StaticText
		Accessible.name: accessibleText
		Layout.alignment: Qt.AlignHCenter
		font {
			pixelSize: Utils.getSizeWithScreenRatio(12)
			weight: Utils.getSizeWithScreenRatio(500)
		}
		Rectangle {
			anchors.fill: parent
			anchors.margins: -Utils.getSizeWithScreenRatio(3)
			color: "transparent"
			radius: Utils.getSizeWithScreenRatio(4)
			border.color: DefaultStyle.main2_900
			border.width: Utils.getSizeWithScreenRatio(2)
			visible: statText.activeFocus
		}
	}
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
				Accessible.role: Accessible.Heading
				Accessible.name: text
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(8)
				Layout.alignment: Qt.AlignHCenter
				StatText {
					text: mainItem.call ? mainItem.call.core.audioStats.codec : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.audioStats.bandwidth : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.audioStats.lossRate : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.audioStats.jitterBufferSize : ""
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
				Accessible.role: Accessible.Heading
				Accessible.name: text
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(8)
				Layout.alignment: Qt.AlignHCenter
				StatText {
					text: mainItem.call ? mainItem.call.core.videoStats.codec : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.videoStats.bandwidth : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.videoStats.lossRate : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.videoStats.resolution : ""
				}
				StatText {
					text: mainItem.call ? mainItem.call.core.videoStats.fps : ""
				}
			}
		}
	}
	Item{Layout.fillHeight: true}
}
