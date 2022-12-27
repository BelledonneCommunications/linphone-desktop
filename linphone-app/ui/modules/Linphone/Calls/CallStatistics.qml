import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Popup {
	id: callStatistics
	
	property var call
	backgroundPopup: CallStatisticsStyle.outsideColor.color
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
			color: CallStatisticsStyle.colorModel.color
			anchors.fill: parent
			anchors.topMargin: CallStatisticsStyle.popup.topMargin
			anchors.bottomMargin: CallStatisticsStyle.popup.bottomMargin
			anchors.leftMargin: CallStatisticsStyle.popup.leftMargin
			anchors.rightMargin: CallStatisticsStyle.popup.rightMargin
			radius: 10
			RowLayout {
				id: mainLayout
				anchors {
					fill: parent
					topMargin: CallStatisticsStyle.topMargin
					leftMargin: CallStatisticsStyle.leftMargin
					rightMargin: CallStatisticsStyle.rightMargin
				}
				Layout.alignment: Qt.AlignCenter
				Item{
					Layout.preferredWidth: videoLoader.sourceComponent ? 0 : parent.width /7
					Layout.fillHeight: true
				}
				Item{
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					Column{
						anchors.fill: parent
						spacing: 30
						Loader {
							property string $label: qsTr('audioStatsLabel')
							property var $data: callStatistics.call?callStatistics.call.audioStats:null
							property bool $fillLayout: !encryptionLoader.active
							
							sourceComponent: media
							width: parent.width
						}
						Loader {
							id: encryptionLoader
							//: 'Media encryption' : title in call statistics for the encryption section
							property string $label: qsTr('mediaEncryptionLabel')
							property var $data: callStatistics.call ? callStatistics.call.encryptionStats : null
							
							sourceComponent: callStatistics.call && callStatistics.call.isSecured ? media : undefined
							width: parent.width
						}
					}
				}
				
				
				Item{
					Layout.fillWidth: videoLoader.sourceComponent
					Layout.fillHeight: true
					Loader {
						id: videoLoader
						property string $label: qsTr('videoStatsLabel')
						property var $data: callStatistics.call?callStatistics.call.videoStats:null
						
						sourceComponent: callStatistics.call && callStatistics.call.videoEnabled ? media : undefined
						width: sourceComponent ? parent.width : 0
					}
				}
				Item{
					Layout.preferredWidth: videoLoader.sourceComponent ? 0 : parent.width /7
					Layout.fillHeight: true
				}
			}
			
			// -------------------------------------------------------------------------
			// Line.
			// -------------------------------------------------------------------------
			
			Component {
				id: line
				
				RowLayout {
					spacing: CallStatisticsStyle.spacing
					width: parent ? parent.width : undefined
					
					Text {
						Layout.preferredWidth: CallStatisticsStyle.key.width
						
						color: CallStatisticsStyle.key.colorModel.color
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
						
						color: CallStatisticsStyle.value.colorModel.color
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
				
				Column{
					width: parent.width
					Text {
						color: CallStatisticsStyle.title.colorModel.color
						
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
