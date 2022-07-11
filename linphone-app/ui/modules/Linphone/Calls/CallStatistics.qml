import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Popup {
	id: callStatistics
	
	property var call
	backgroundPopup: CallStatisticsStyle.outsideColor
	showShadow: false	// if true, we get a brownish/yollow color due to alphas
	// ---------------------------------------------------------------------------
	delayClosing: true
	Item{
		height: callStatistics.height
		width: callStatistics.width
		MouseArea{
			anchors.fill: parent
			onClicked: callStatistics.close()
		}
		Rectangle {
			color: CallStatisticsStyle.color
			anchors.fill: parent
			anchors.topMargin: CallStatisticsStyle.popup.topMargin
			anchors.bottomMargin: CallStatisticsStyle.popup.bottomMargin
			anchors.leftMargin: CallStatisticsStyle.popup.leftMargin
			anchors.rightMargin: CallStatisticsStyle.popup.rightMargin
			radius: 10
			Row {
				anchors {
					fill: parent
					topMargin: CallStatisticsStyle.topMargin
					leftMargin: CallStatisticsStyle.leftMargin
					rightMargin: CallStatisticsStyle.rightMargin
				}
				
				Loader {
					property string $label: qsTr('audioStatsLabel')
					property var $data: callStatistics.call?callStatistics.call.audioStats:null
					
					sourceComponent: media
					width: parent.width / 2
				}
				
				Loader {
					property string $label: qsTr('videoStatsLabel')
					property var $data: callStatistics.call?callStatistics.call.videoStats:null
					
					sourceComponent: media
					width: parent.width / 2
				}
			}
			
			// -------------------------------------------------------------------------
			// Line.
			// -------------------------------------------------------------------------
			
			Component {
				id: line
				
				RowLayout {
					spacing: CallStatisticsStyle.spacing
					width: parent.width
					
					Text {
						Layout.preferredWidth: CallStatisticsStyle.key.width
						
						color: CallStatisticsStyle.key.color
						elide: Text.ElideRight
						
						font {
							pointSize: CallStatisticsStyle.key.pointSize
							bold: true
						}
						
						horizontalAlignment: Text.AlignRight
						verticalAlignment: Text.AlignVCenter
						
						text: modelData.key
					}
					
					Text {
						Layout.fillWidth: true
						
						color: CallStatisticsStyle.value.color
						elide: Text.ElideRight
						font.pointSize: CallStatisticsStyle.value.pointSize
						
						text: modelData.value
					}
				}
			}
			
			// -------------------------------------------------------------------------
			// Media.
			// -------------------------------------------------------------------------
			
			Component {
				id: media
				
				Column {
					Text {
						color: CallStatisticsStyle.title.color
						
						font {
							bold: true
							pointSize: CallStatisticsStyle.title.pointSize
						}
						
						elide: Text.ElideRight
						horizontalAlignment: Text.AlignHCenter
						text: $label
						
						height: contentHeight + CallStatisticsStyle.title.bottomMargin
						width: parent.width
					}
					
					Repeater {
						model: $data
						delegate: line
					}
				}
			}
			ActionButton{
				id: closeButton
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.topMargin: 10
				anchors.rightMargin: 10
				
				isCustom: true
				backgroundRadius: width/2
				colorSet: CallStatisticsStyle.cancel
				onClicked: callStatistics.close()
			}
		}
	}
}
