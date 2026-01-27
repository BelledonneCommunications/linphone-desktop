import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

RowLayout {
	id: mainItem
	property alias localVideoEnabled: preview.videoEnabled
	property bool microEnabled: true
	property alias settingsButtonChecked: settingsButton.checked
	property ConferenceInfoGui conferenceInfo
	signal joinConfRequested(string uri)
	signal cancelJoiningRequested()
	signal cancelAfterJoinRequested()
	RowLayout {
		Layout.fillWidth: false
		Layout.fillHeight: false
        spacing: Utils.getSizeWithScreenRatio(100)
		Layout.alignment: Qt.AlignCenter
		ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(31)
			Sticker {
				id: preview
				previewEnabled: true
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(330)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(558)
				qmlName: "WP"
				displayAll: false
				displayPresence: false
				mutedStatus: microButton.checked
				AccountProxy {
					id: accounts
				}
				account: accounts.defaultAccount
			}
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Utils.getSizeWithScreenRatio(16)
                CheckableButton {
                    id: videoButton
                    visible: SettingsCpp.videoEnabled
                    iconUrl: AppIcons.videoCamera
                    checkedIconUrl: AppIcons.videoCameraSlash
                    checked: !mainItem.localVideoEnabled
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(55)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(55)
                    icon.width: Utils.getSizeWithScreenRatio(32)
                    icon.height: Utils.getSizeWithScreenRatio(32)
                    onClicked: mainItem.localVideoEnabled = !mainItem.localVideoEnabled
                }
                CheckableButton {
                    id: microButton
                    iconUrl: AppIcons.microphone
                    checkedIconUrl: AppIcons.microphoneSlash
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(55)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(55)
                    icon.width: Utils.getSizeWithScreenRatio(32)
                    icon.height: Utils.getSizeWithScreenRatio(32)
                    onCheckedChanged: mainItem.microEnabled = !mainItem.microEnabled
                }
                CheckableButton {
                    id: settingsButton
                    visible: stackLayout.currentIndex === 0
                    icon.source: AppIcons.verticalDots
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(55)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(55)
                    icon.width: Utils.getSizeWithScreenRatio(24)
                    icon.height: Utils.getSizeWithScreenRatio(24)
                }
                CheckableButton {
                    id: speakerButton
                    visible: stackLayout.currentIndex === 1
                    iconUrl: AppIcons.speaker
                    checkedIconUrl: AppIcons.speakerSlash
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(55)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(55)
                    icon.width: Utils.getSizeWithScreenRatio(32)
                    icon.height: Utils.getSizeWithScreenRatio(32)
                }
            }
        }
		StackLayout {
			id: stackLayout
			currentIndex: 0
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(93)
				ColumnLayout {
                    Layout.topMargin: Utils.getSizeWithScreenRatio(54)
					spacing: 0
					Text {
						Layout.fillWidth: true
                        //: Participer à :
                        text: qsTr("meeting_waiting_room_title")
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(30)
                            weight: Utils.getSizeWithScreenRatio(300)
						}
					}
					Text {
						Layout.fillWidth: true
						text: mainItem.conferenceInfo && mainItem.conferenceInfo.core.subject
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(30)
                            weight: Utils.getSizeWithScreenRatio(300)
						}
					}
				}
				ColumnLayout {
                    spacing: Utils.getSizeWithScreenRatio(5)
					BigButton {
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(292)
                        //: "Rejoindre"
                        text: qsTr("meeting_waiting_room_join")
						style: ButtonStyle.main
						onClicked: {
							settingsButton.checked = false
							stackLayout.currentIndex = 1
							mainItem.joinConfRequested(mainItem.conferenceInfo.core.uri)
						}
					}
					BigButton {
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(292)
						style: ButtonStyle.secondary
                        text: qsTr("cancel")
						onClicked: {
							mainItem.cancelJoiningRequested()
						}
					}
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(37)
				ColumnLayout {
                    spacing: Utils.getSizeWithScreenRatio(13)
					Text {
						Layout.fillWidth: true
                        //: "Connexion à la réunion"
                        text: qsTr("meeting_waiting_room_joining_title")
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(30)
                            weight: Utils.getSizeWithScreenRatio(300)
						}
					}
					Text {
						Layout.fillWidth: true
                        //: "Vous allez rejoindre la réunion dans quelques instants…"
                        text: qsTr("meeting_waiting_room_joining_subtitle")
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Typography.p1.pixelSize
                            weight: Typography.p1.weight
						}
					}
				}
				BusyIndicator {
					indicatorColor: DefaultStyle.main1_500_main
					Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(48)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
				}
				BigButton {
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(292)
					Layout.alignment: Qt.AlignHCenter
					style: ButtonStyle.main
					//: Cancel
                    text: qsTr("cancel")
					onClicked: {
						settingsButton.checked = false
						stackLayout.currentIndex = 1
						mainItem.cancelAfterJoinRequested()
					}
				}
			}
		}
	}
}
