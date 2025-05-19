import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Rectangle {
	id: mainItem
	width: 490 * DefaultStyle.dp
	height: content.implicitHeight
	radius: 10 * DefaultStyle.dp
	clip: true
	antialiasing: true

	property var conferenceInfoGui: ConferenceInfoGui
	property var conferenceInfo: conferenceInfoGui?.core
	property string timeRangeText: ""
	property bool linkHovered: false
	
	signal mouseEvent(MouseEvent event)
	
	MouseArea {
		anchors.fill: parent
		cursorShape: mainItem.linkHovered ? Qt.PointingHandCursor : Qt.ArrowCursor
		onClicked: (mouse) => mouseEvent(mouse)
		acceptedButtons: Qt.AllButtons // Send all to parent
	}

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

	ColumnLayout {
		id: content
		anchors.fill: parent
		spacing: 0

		Rectangle {
			Layout.fillWidth: true
			height: row1.implicitHeight + 32 * DefaultStyle.dp
			color: DefaultStyle.grey_100
			radius: 10 * DefaultStyle.dp   // rounded all, but only top visible

			ColumnLayout {
				id: row1
				anchors.fill: parent
				anchors.margins: 16 * DefaultStyle.dp

				Text {
					text: conferenceInfo.organizerName + (
						conferenceInfo.state == LinphoneEnums.ConferenceInfoState.New ?
							qsTr("ics_bubble_organiser_invites_you_to") :
						conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Updated ?
							qsTr("ics_bubble_organiser_modified") :
						conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Cancelled ?
							qsTr("ics_bubble_organiser_cancelled") :
							""
					)
					font: Typography.p2
					color: conferenceInfo.state == LinphoneEnums.ConferenceInfoState.New ?
							DefaultStyle.main2_600 :
						conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Updated ?
							DefaultStyle.warning_600 :
						conferenceInfo.state == LinphoneEnums.ConferenceInfoState.Cancelled ?
							DefaultStyle.danger_500main :
						DefaultStyle.main2_600
				}

				RowLayout {
					Layout.fillWidth: true
					spacing: 10 * DefaultStyle.dp

					Rectangle {
						width: 48 * DefaultStyle.dp
						height: 48 * DefaultStyle.dp
						radius: 10 * DefaultStyle.dp
						color: "transparent"

						Rectangle {
							anchors.fill: parent
							color: "#33000000"
							radius: 10 * DefaultStyle.dp
							anchors.verticalCenterOffset: 4 * DefaultStyle.dp
							z: -1
						}

						Rectangle {
							id: dayRect
							anchors.fill: parent
							radius: 10 * DefaultStyle.dp
							color: DefaultStyle.grey_0

							Column {
								anchors.centerIn: parent
								spacing: 2 * DefaultStyle.dp

								Text {
									text: conferenceInfo.dateTime.toLocaleString(Qt.locale(), "ddd") + "."
									color: DefaultStyle.main2_500main
									font: Typography.p4
									horizontalAlignment: Text.AlignHCenter
									anchors.horizontalCenter: parent.horizontalCenter
								}

								Rectangle {
									width: 23 * DefaultStyle.dp
									height: 23 * DefaultStyle.dp
									radius: width / 2
									color: DefaultStyle.main1_500_main
									anchors.horizontalCenter: parent.horizontalCenter

									Text {
										text: conferenceInfo.dateTime.getDate().toString()
										color: DefaultStyle.grey_0
										font: Typography.h4
										anchors.centerIn: parent
									}
								}
							}
						}
					}

					// Info
					ColumnLayout {
						RowLayout {
							EffectImage {
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
								Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
								Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							}

							Text {
								text: conferenceInfo.subject
								font: Typography.p2
								wrapMode: Text.WordWrap
								color: DefaultStyle.main2_600
							}
						}

						Text {
							text: conferenceInfo.dateTime.toLocaleString(Qt.locale(), "dddd d MMMM yyyy")
							font: Typography.p4
							color: DefaultStyle.main2_500main
						}

						Text {
							text: timeRangeText
							font: Typography.p4
							color: DefaultStyle.main2_500main
						}
					}
				}
			}
		}
		
		
		Rectangle {
			Layout.fillWidth: true
			height: 10 * DefaultStyle.dp
			color: DefaultStyle.grey_100
			Layout.topMargin: -10 * DefaultStyle.dp
		}

		Rectangle {
			Layout.fillWidth: true
			height: row2.implicitHeight + 32 * DefaultStyle.dp
			color: DefaultStyle.grey_0
			radius: 10 * DefaultStyle.dp
			
			ColumnLayout {
				id: row2
				spacing: 10 * DefaultStyle.dp
				anchors.fill: parent
				anchors.margins: 16 * DefaultStyle.dp

				Text {
					text: qsTr("ics_bubble_description_title")
					font: Typography.p4
					color: DefaultStyle.main2_800
					visible: conferenceInfo.description.length > 0
				}

				Text {
					text: UtilsCpp.encodeTextToQmlRichFormat(conferenceInfo.description)
					wrapMode: Text.WordWrap
					textFormat: Text.RichText
					font: Typography.p4
					color: DefaultStyle.main2_500main
					visible: conferenceInfo.description.length > 0
					onLinkActivated: {
						if (link.startsWith('sip'))
							UtilsCpp.createCall(link)
						else
							Qt.openUrlExternally(link)
					}
					onHoveredLinkChanged: {
						mainItem.linkHovered = hoveredLink !== ""
					}
				}

				RowLayout {
					Layout.fillHeight: true
					Layout.preferredHeight: 30 * DefaultStyle.dp
					spacing: 10 * DefaultStyle.dp
					EffectImage {
						imageSource: AppIcons.usersTwo
						colorizationColor: DefaultStyle.main2_600
						Layout.preferredWidth: Math.round(14 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(14 * DefaultStyle.dp)
					}
					Text {
						text: conferenceInfo.participantCount + qsTr("ics_bubble_participants")
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
							var callsWindow = UtilsCpp.getCallsWindow()
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
}
