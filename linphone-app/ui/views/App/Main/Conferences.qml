import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
	id: container
	
	spacing: 0
	
	// ---------------------------------------------------------------------------
	// Title
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ConferencesStyle.bar.height
		
		color: ConferencesStyle.bar.backgroundColor
		Text{
			anchors.verticalCenter: parent.center
			anchors.left: parent.left
			anchors.right: parent.right
			
			anchors.leftMargin: 40
			
			text: 'Mes conférences'
		}
	}
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ConferencesStyle.bar.height
		
		color: 'white'
		
		RowLayout {
			anchors {
				fill: parent
				leftMargin: ConferencesStyle.bar.leftMargin
				rightMargin: ConferencesStyle.bar.rightMargin
			}
			spacing: ConferencesStyle.spacing
			
			ExclusiveButtons {
				texts: [
					'TERMINEES',
					'PROGRAMMEES',
					'INVITATIONS'
				]
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Conferences list.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.fillHeight: true
		color: ConferencesStyle.backgroundColor
		
		ScrollableListView {
			anchors.fill: parent
			spacing: 10
			
			highlightFollowsCurrentItem: false
			
			section {
				criteria: ViewSection.FullString
				delegate: sectionHeading
				property: 'dateTime'
			}
			
			model: ConferenceInfoProxyModel{}
			
			
			/* ListModel{
				ListElement{date: '2020/12/01'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				ListElement{date: '2020/12/01'; time: '14:00:00';duration: 30;organizerName: 'Moi';subject:'TOTO';participantes: 'Julien'  }
				ListElement{date: '2020/12/01'; time: '10:10:00';duration: 120;organizerName: 'Henri';subject:'Eskimirbief, mais ou est donc Willy?';participantes: 'Julien'}
				ListElement{date: '2020/12/04'; time: '09:00:00';duration: 300;organizerName: 'Houlahoup';subject:'Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'}
				ListElement{date: '2020/12/05'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'1. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				ListElement{date: '2020/12/05'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'2. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				
				ListElement{date: '2020/12/06'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'1. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				ListElement{date: '2020/12/06'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'2. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				ListElement{date: '2020/12/06'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'3. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
				ListElement{date: '2020/12/06'; time: '10:00:00';duration: 60;organizerName: 'Dupont';subject:'4. Atelier loisir: boumbo en folie';participantes: 'Martin, Jordy, allelouilla, Artemis Gordon, jobarteam'  }
			}*/
			// -----------------------------------------------------------------------
			// Heading.
			// -----------------------------------------------------------------------
			
			Component {
				id: sectionHeading
				
				Item {
					implicitHeight: container.height + ConferencesStyle.sectionHeading.bottomMargin
					width: parent.width
					
					Borders {
						id: container
						
						borderColor: ConferencesStyle.sectionHeading.border.color
						bottomWidth: ConferencesStyle.sectionHeading.border.width
						implicitHeight: text.contentHeight +
										ConferencesStyle.sectionHeading.padding * 2 +
										ConferencesStyle.sectionHeading.border.width * 2
						topWidth: ConferencesStyle.sectionHeading.border.width
						width: parent.width
						
						Text {
							id: text
							
							anchors.fill: parent
							color: ConferencesStyle.sectionHeading.text.color
							font {
								bold: true
								pointSize: ConferencesStyle.sectionHeading.text.pointSize
							}
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							
							// Cast section to integer because Qt converts the
							// sectionDate in string!!!
							text: new Date(section).toLocaleDateString(
									  Qt.locale(App.locale)
									  )
						}
					}
				}
			}
			
			//----------------------------------------------------------------------------------------------
			//----------------------------------------------------------------------------------------------
			//----------------------------------------------------------------------------------------------
			
			delegate: Rectangle {
				id: entry
				
				anchors {
					left: parent ? parent.left : undefined
					leftMargin: 0
					right: parent ? parent.right : undefined
					rightMargin: 0
				}
				radius: 6
				color: ConferencesStyle.conference.backgroundColor.normal
				implicitHeight: layout.height + ConferencesStyle.conference.bottomMargin
				
				// ---------------------------------------------------------------------
				MouseArea {
					id: mouseArea
					
					cursorShape: Qt.ArrowCursor
					hoverEnabled: true
					implicitHeight: layout.height
					width: parent.width + parent.anchors.rightMargin
					//acceptedButtons: Qt.NoButton
					onClicked: CallsListModel.launchVideoCall(modelData.uri, '', 0)
					ColumnLayout{
						id: layout
						spacing: 0
						width: entry.width
						
						RowLayout {
							RowLayout {
								id: scheduleRow
								spacing: ConferencesStyle.conference.spacing
								
								Icon{
									icon: ConferencesStyle.conference.schedule.icon
									iconSize: ConferencesStyle.conference.schedule.iconSize
									overwriteColor: ConferencesStyle.conference.schedule.color
								}
								
								Text {
									Layout.fillWidth: true
									color: ConferencesStyle.conference.schedule.color
									elide: Text.ElideRight
									font.pointSize: ConferencesStyle.conference.schedule.pointSize
									text: Qt.formatDateTime(modelData.dateTime, 'yyyy/MM/dd hh:mm')
								}
							}
							Text{
								Layout.fillWidth: true
								Layout.alignment: Qt.AlignRight
								color: ConferencesStyle.conference.schedule.color
								font.pointSize: ConferencesStyle.conference.schedule.pointSize
								text: 'Organisateur : ' +UtilsCpp.getDisplayName(modelData.organizer)
							}
						}
						Text{
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignRight
							color: ConferencesStyle.conference.schedule.color
							font.pointSize: ConferencesStyle.conference.schedule.pointSize
							text: modelData.subject
						}
						RowLayout {
							id: participantsRow
							spacing: ConferencesStyle.conference.spacing
							
							Icon{
								icon: ConferencesStyle.conference.participants.icon
								iconSize: ConferencesStyle.conference.participants.iconSize
								overwriteColor: ConferencesStyle.conference.participants.color
							}
							
							Text {
								Layout.fillWidth: true
								color: ConferencesStyle.conference.participants.color
								elide: Text.ElideRight
								font.pointSize: ConferencesStyle.conference.participants.pointSize
								text: modelData.displayNamesToString
							}
						}	
					}
				}
			}
			
			
		}
	}
}
