import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	spacing: 0

	id: mainItem
	width: Utils.getSizeWithScreenRatio(490)

	property ConferenceInfoGui conferenceInfoGui
	property var conferenceInfo: conferenceInfoGui?.core
	property string timeRangeText: ""
	property bool linkHovered: false
	
	signal mouseEvent(MouseEvent event)

	function updateTimeRange() {
		if (!conferenceInfo || !conferenceInfo.dateTime || !conferenceInfo.duration)
			return;

		let locale = Qt.locale();
		let startDate = conferenceInfo.dateTime;
		let endDate = new Date(startDate.getTime() + (conferenceInfo.duration * 60 * 1000));

		let startTime = startDate.toLocaleTimeString(locale, "hh:mm");
		let endTime = endDate.toLocaleTimeString(locale, "hh:mm");

		let offsetMinutes = -startDate.getTimezoneOffset();
		let offsetHours = Math.floor(offsetMinutes / 60);
		let timeZone = "UTC" + (offsetHours >= 0 ? "+" : "") + offsetHours;

		timeRangeText =
			qsTr("ics_bubble_meeting_from") + startTime +
			qsTr("ics_bubble_meeting_to") + endTime + " (" + timeZone + ")";
	}

	Control.Control {
		id: infoControl
		topPadding: Utils.getSizeWithScreenRatio(16)
		leftPadding: Utils.getSizeWithScreenRatio(16)
		rightPadding: Utils.getSizeWithScreenRatio(16)
		bottomPadding: Utils.getSizeWithScreenRatio(16)
		Layout.fillWidth: true

		background: Rectangle {
			anchors.fill: parent
			color: DefaultStyle.grey_100
			radius: Utils.getSizeWithScreenRatio(10) // rounded all, but only top visible
		}
		contentItem: ColumnLayout {
			Text {
				visible: conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Updated
				|| conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Cancelled
				text: conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Updated
					//: Meeting has been updated
					? qsTr("ics_bubble_meeting_modified") + " :"
					: conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Cancelled 
					//: Meeting has been canceled
					? qsTr("ics_bubble_meeting_cancelled") + " :"
					: ""
				font: Typography.p2
				color: conferenceInfo.state == LinphoneEnums.ConferenceInfoState.New ?
						DefaultStyle.main2_600 :
					conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Updated ?
						DefaultStyle.warning_600 :
					conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Cancelled ?
						DefaultStyle.danger_500_main :
					DefaultStyle.main2_600
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: Utils.getSizeWithScreenRatio(10)

				Control.Control {
					id: dayRect
					Layout.alignment: Qt.AlignTop
					topPadding: Utils.getSizeWithScreenRatio(4)
					bottomPadding: Utils.getSizeWithScreenRatio(6)
					leftPadding: Utils.getSizeWithScreenRatio(13)
					rightPadding: Utils.getSizeWithScreenRatio(13)

					background: Item {
						Rectangle {
							id: dayRectBg
							anchors.fill: parent
							radius: Utils.getSizeWithScreenRatio(10)
							color: DefaultStyle.grey_0
						}
						MultiEffect {
							anchors.fill: dayRectBg
							source: dayRectBg
							shadowEnabled: true
							shadowColor: DefaultStyle.grey_1000
							shadowOpacity: 0.1
						}
					}
					contentItem: ColumnLayout {
						spacing: Utils.getSizeWithScreenRatio(2)

						Text {
							Layout.fillWidth: true
							// Layout.preferredWidth: advancedWidth
							text: conferenceInfo.dateTime.toLocaleString(Qt.locale(), "ddd")
							color: DefaultStyle.main2_500_main
							font {
								pixelSize: Typography.p4.pixelSize
								weight: Typography.p4.weight
								capitalization: Font.Capitalize
							}
							horizontalAlignment: Text.AlignHCenter
							// anchors.horizontalCenter: parent.horizontalCenter
						}

						Rectangle {
							width: Utils.getSizeWithScreenRatio(23)
							height: Utils.getSizeWithScreenRatio(23)
							radius: width / 2
							color: DefaultStyle.main1_500_main
							// anchors.horizontalCenter: parent.horizontalCenter

							Text {
								text: conferenceInfo.dateTime.getDate().toString()
								color: DefaultStyle.grey_0
								font: Typography.h4
								anchors.centerIn: parent
							}
						}
					}
				}

				// Info
				ColumnLayout {
					spacing: Utils.getSizeWithScreenRatio(-2)
					RowLayout {
						spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							imageSource: AppIcons.videoconference
							colorizationColor: DefaultStyle.main2_600
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
						}

						Text {
							text: conferenceInfo.subject
							font: Typography.p2
							wrapMode: Text.WordWrap
							maximumLineCount: 2
							elide: Text.ElideRight
							color: DefaultStyle.main2_600
						}
					}

					Text {
						text: conferenceInfo.dateTime.toLocaleString(Qt.locale(), "dddd d MMMM yyyy")
						font: Typography.p4
						color: DefaultStyle.main2_500_main
					}
					Text {
						//: from %1 to %2 (UTC%3)
						property string offsetFromUtc: conferenceInfo.timeZoneModel.offsetFromUtc > 0
							? "+" + conferenceInfo.timeZoneModel.offsetFromUtc/3600
							: conferenceInfo.timeZoneModel.offsetFromUtc/3600
						text: qsTr("").arg(
								conferenceInfo.dateTime.toLocaleString(Qt.locale(), "hh:mm")).arg(
								conferenceInfo.endDateTime.toLocaleString(Qt.locale(), "hh:mm")).arg(offsetFromUtc)
						color: DefaultStyle.main2_500_main
						font: Typography.p4
					}

					Text {
						text: timeRangeText
						font: Typography.p4
						color: DefaultStyle.main2_500_main
					}
				}
			}
		}
	}
	
	
	Rectangle {
		visible: conferenceInfo.description.length > 0 || conferenceInfo.participantCount > 0
		Layout.fillWidth: true
		height: Utils.getSizeWithScreenRatio(10)
		color: DefaultStyle.grey_100
		Layout.topMargin: Utils.getSizeWithScreenRatio(-10)
		z: infoControl.z + 1
	}
	Rectangle {
		visible: conferenceInfo.description.length > 0 || conferenceInfo.participantCount > 0
		Layout.fillWidth: true
		height: Utils.getSizeWithScreenRatio(10)
		color: DefaultStyle.grey_0
		Layout.bottomMargin: Utils.getSizeWithScreenRatio(-10)
		z: infoControl.z + 1
	}

	Control.Control {
		visible: conferenceInfo.description.length > 0 || conferenceInfo.participantCount > 0
		topPadding: Utils.getSizeWithScreenRatio(16) // only 6 because the rectangle linking the 2 controls is size 10
		leftPadding: Utils.getSizeWithScreenRatio(16)
		rightPadding: Utils.getSizeWithScreenRatio(16)
		bottomPadding: Utils.getSizeWithScreenRatio(16)
		Layout.fillWidth: true

		MouseArea {
			anchors.fill: parent
			cursorShape: mainItem.linkHovered ? Qt.PointingHandCursor : Qt.ArrowCursor
			onClicked: (mouse) => mouseEvent(mouse)
			acceptedButtons: Qt.AllButtons // Send all to parent
		}

		background: Rectangle {
			anchors.fill: parent
			color: DefaultStyle.grey_0
			radius: Utils.getSizeWithScreenRatio(10)
		}
		
		contentItem: ColumnLayout {
			spacing: Utils.getSizeWithScreenRatio(10)

			ColumnLayout {
				spacing: 0
				Text {
					//: Description
					text: qsTr("ics_bubble_description_title")
					font: Typography.p4
					color: DefaultStyle.main2_800
					visible: conferenceInfo.description.length > 0
				}

				Text {
					property var encodeTextObj: UtilsCpp.encodeTextToQmlRichFormat(conferenceInfo.description)
					text: conferenceInfo.description//encodeTextObj ? encodeTextObj.value : ""
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
					textFormat: Text.RichText
					font: Typography.p4
					color: DefaultStyle.main2_500_main
					maximumLineCount: 3
					elide: Text.ElideRight
					visible: conferenceInfo.description.length > 0
					onLinkActivated: (link) => {
						if (link.startsWith('sip'))
							UtilsCpp.createCall(link)
						else
							Qt.openUrlExternally(link)
					}
					onHoveredLinkChanged: {
						mainItem.linkHovered = hoveredLink !== ""
					}
				}
			}

			RowLayout {
				visible: conferenceInfo.participantCount > 0
				Layout.fillHeight: true
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
				spacing: Utils.getSizeWithScreenRatio(10)
				EffectImage {
					imageSource: AppIcons.usersTwo
					colorizationColor: DefaultStyle.main2_600
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
				}
				Text {
					//: %n participant(s)
					text: qsTr("ics_bubble_participants", '', conferenceInfo.participantCount).arg(conferenceInfo.participantCount)
					font: Typography.p4
					color: DefaultStyle.main2_800
				}
				Item {
					Layout.fillWidth: true
				}
				MediumButton {
					style: ButtonStyle.ButtonStyle
					//: "Rejoindre"
					text: qsTr("ics_bubble_join")
					visible: !SettingsCpp.disableMeetingsFeature && conferenceInfo.state != LinphoneEnums.ConferenceInfoState.Cancelled
					onClicked: {
						var callsWindow = UtilsCpp.getOrCreateCallsWindow()
						callsWindow.setupConference(mainItem.conferenceInfoGui)
						UtilsCpp.smartShowWindow(callsWindow)
					}
				}
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
}
