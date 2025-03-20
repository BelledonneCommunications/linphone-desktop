import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

RowLayout {
	id: mainItem
	property alias localVideoEnabled: preview.videoEnabled
	property bool microEnabled: true
	property bool settingsButtonChecked: settingsButton.checked
	property ConferenceInfoGui conferenceInfo
	signal joinConfRequested(string uri)
	signal cancelJoiningRequested()
	signal cancelAfterJoinRequested()
	RowLayout {
		Layout.fillWidth: false
		Layout.fillHeight: false
        spacing: Math.round(100 * DefaultStyle.dp)
		Layout.alignment: Qt.AlignCenter
		ColumnLayout {
            spacing: Math.round(31 * DefaultStyle.dp)
			Sticker {
				id: preview
				previewEnabled: true
                Layout.preferredHeight: Math.round(330 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(558 * DefaultStyle.dp)
				qmlName: "WP"
				displayAll: false
				displayPresence: false
				mutedStatus: microButton.checked
				AccountProxy {
					id: accounts
					sourceModel: AppCpp.accounts
				}
				account: accounts.defaultAccount
			}
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(16 * DefaultStyle.dp)
                CheckableButton {
                    id: videoButton
                    visible: SettingsCpp.videoEnabled
                    iconUrl: AppIcons.videoCamera
                    checkedIconUrl: AppIcons.videoCameraSlash
                    checked: !mainItem.localVideoEnabled
                    Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                    icon.width: Math.round(32 * DefaultStyle.dp)
                    icon.height: Math.round(32 * DefaultStyle.dp)
                    onClicked: mainItem.localVideoEnabled = !mainItem.localVideoEnabled
                }
                CheckableButton {
                    id: microButton
                    iconUrl: AppIcons.microphone
                    checkedIconUrl: AppIcons.microphoneSlash
                    Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                    icon.width: Math.round(32 * DefaultStyle.dp)
                    icon.height: Math.round(32 * DefaultStyle.dp)
                    onCheckedChanged: mainItem.microEnabled = !mainItem.microEnabled
                }
                CheckableButton {
                    id: settingsButton
                    visible: stackLayout.currentIndex === 0
                    icon.source: AppIcons.verticalDots
                    Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
                }
                CheckableButton {
                    id: speakerButton
                    visible: stackLayout.currentIndex === 1
                    iconUrl: AppIcons.speaker
                    checkedIconUrl: AppIcons.speakerSlash
                    Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                    icon.width: Math.round(32 * DefaultStyle.dp)
                    icon.height: Math.round(32 * DefaultStyle.dp)
                }
            }
        }
		StackLayout {
			id: stackLayout
			currentIndex: 0
			ColumnLayout {
                spacing: Math.round(93 * DefaultStyle.dp)
				ColumnLayout {
                    Layout.topMargin: Math.round(54 * DefaultStyle.dp)
					spacing: 0
					Text {
						Layout.fillWidth: true
                        //: Participer à :
                        text: qsTr("meeting_waiting_room_title")
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Math.round(30 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
						}
					}
					Text {
						Layout.fillWidth: true
						text: mainItem.conferenceInfo && mainItem.conferenceInfo.core.subject
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Math.round(30 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
						}
					}
				}
				ColumnLayout {
                    spacing: Math.round(5 * DefaultStyle.dp)
					BigButton {
                        Layout.preferredWidth: Math.round(292 * DefaultStyle.dp)
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
                        Layout.preferredWidth: Math.round(292 * DefaultStyle.dp)
						style: ButtonStyle.secondary
                        text: qsTr("cancel")
						onClicked: {
							mainItem.cancelJoiningRequested()
						}
					}
				}
			}
			ColumnLayout {
                spacing: Math.round(37 * DefaultStyle.dp)
				ColumnLayout {
                    spacing: Math.round(13 * DefaultStyle.dp)
					Text {
						Layout.fillWidth: true
                        //: "Connexion à la réunion"
                        text: qsTr("meeting_waiting_room_joining_title")
						color: DefaultStyle.grey_0
						font {
                            pixelSize: Math.round(30 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
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
                    Layout.preferredWidth: Math.round(48 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(48 * DefaultStyle.dp)
				}
				BigButton {
                    Layout.preferredWidth: Math.round(292 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignHCenter
					style: ButtonStyle.main
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
