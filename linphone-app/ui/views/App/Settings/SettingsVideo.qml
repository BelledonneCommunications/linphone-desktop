import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Utils 1.0

import App.Styles 1.0

import 'SettingsVideo.js' as Logic

// =============================================================================

TabContainer {
	Column {
		spacing: SettingsWindowStyle.forms.spacing
		width: parent.width
		
		// -------------------------------------------------------------------------
		// Video parameters.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('videoCaptureTitle')
			width: parent.width
			
			//Warning if in call
			FormLine {
				visible: SettingsModel.isInCall
				FormGroup {
					RowLayout {
						spacing: SettingsWindowStyle.video.warningMessage.iconSize
						Icon {
							icon: 'warning'
							iconSize: SettingsWindowStyle.video.warningMessage.iconSize
							anchors {
								rightMargin: SettingsWindowStyle.video.warningMessage.iconSize
								leftMargin: SettingsWindowStyle.video.warningMessage.iconSize
							}
						}
						Text {
							text: qsTr('videoSettingsInCallWarning')
						}
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('videoInputDeviceLabel')
					
					ComboBox {
						currentIndex: Number(Utils.findIndex(model, function (device) {
							return device === SettingsModel.videoDevice
						})) // Number cast => Index is null if app does not support video.
						model: SettingsModel.videoDevices
						
						onActivated: SettingsModel.videoDevice = model[index]
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('videoPresetLabel')
					
					ComboBox {
						currentIndex: {
							var preset = SettingsModel.videoPreset
							
							var index = Number(Utils.findIndex(model, function (value) {
								return preset === value.value
							}))
							return index>=0 ? index : 0;
						}
						
						model: [{
								key: qsTr('presetDefault'),
								value: 'default'
							}, {
								key: qsTr('presetHighFps'),
								value: 'high-fps'
							}, {
								key: qsTr('presetCustom'),
								value: 'custom'
							}]
						
						textRole: 'key'
						
						onActivated: SettingsModel.videoPreset = model[index].value
					}
				}
			}
			
			FormLine {
				FormGroup {
					label: qsTr('videoSizeLabel')
					
					ComboBox {
						currentIndex: Number(Utils.findIndex(model, function (definition) {
							return definition.value.name === SettingsModel.videoDefinition.name
						})) // Number cast => Index is null if app does not support video.
						model: SettingsModel.supportedVideoDefinitions.map(function (definition) {
							return {
								key: definition.name + ' (' + definition.width + 'x' + definition.height + ')',
								value: definition
							}
						})
						
						textRole: 'key'
						
						onActivated: SettingsModel.videoDefinition = model[index].value
					}
				}
				
				FormGroup {
					label: qsTr('videoFramerateLabel')
					visible: SettingsModel.videoPreset === 'custom'
					
					NumericField {
						maxValue: 60
						minValue: 1
						text: SettingsModel.videoFramerate
						
						onEditingFinished: SettingsModel.videoFramerate = text
					}
				}
			}
			
			FormEmptyLine {}
		}
		
		TextButtonB {
			id: showCameraPreview
			
			anchors.right: parent.right
			enabled: CallsListModel.rowCount() === 0
			
			text: qsTr('showCameraPreview')
			
			onClicked: Logic.showVideoPreview()
			
			Connections {
				target: CallsListModel
				
				onRowsInserted: Logic.updateVideoPreview()
				onRowsRemoved: Logic.updateVideoPreview()
			}
			
			Connections {
				target: window
				
				onClosing: Logic.hideVideoPreview()
			}
		}
		
		// -------------------------------------------------------------------------
		// Video Codecs.
		// -------------------------------------------------------------------------
		
		Form {
			title: qsTr('videoCodecsTitle')
			visible: SettingsModel.showVideoCodecs || SettingsModel.developerSettingsEnabled
			width: parent.width
			
			FormLine {
				visible: SettingsModel.developerSettingsEnabled
				
				FormGroup {
					label: qsTr('showVideoCodecsLabel')
					
					Switch {
						checked: SettingsModel.showVideoCodecs
						
						onClicked: SettingsModel.showVideoCodecs = !checked
					}
				}
				
				FormGroup {
					label: 'Video enabled'
					
					Switch {
						checked: SettingsModel.videoEnabled
						
						onClicked: SettingsModel.videoEnabled = !checked
					}
				}
			}
			
			CodecsViewer {
				model: VideoCodecsModel
				width: parent.width
				
				onDownloadRequested: Logic.handleCodecDownloadRequested(codecInfo)
			}
		}
		
		// -------------------------------------------------------------------------
		// Diplay Video.
		// -------------------------------------------------------------------------
		
		
		Form {
			id: videoDisplayForm
			//: 'Video display' : Title for display parameters
			title: qsTr('videoDisplayTitle')
			width: parent.width
			
			property var cameraModel:
			//: 'Hybrid' : Hybrid mode for camera.
				[{displayText:qsTr('videoHybrid')}
			//: 'Occupy all space' : Camera mode for a centered cropping view.
				, {displayText:qsTr('videoOccupyAllSpace')}
			//: 'Black bars' : Camera mode for a fit view with black bars to keep ratio.
				, {displayText:qsTr('videoBlackBars')}
			]
			function getId(index){
				if(index == 0 )
					return SettingsModel.CameraMode_Hybrid
				else if(index == 1)
					return SettingsModel.CameraMode_OccupyAllSpace
				else
					return SettingsModel.CameraMode_BlackBars
			}
			Row{
				property int orientation:  Qt.Horizontal
				width: parent.width
				Text{
					id: videoModeLabel
					height: parent.height
					//: 'Camera modes' : Label to choose a camera modes.
					text: qsTr('videoModeLabel')
					font: videoGridMode.labelFont
					horizontalAlignment: Text.AlignRight
					verticalAlignment: Text.AlignVCenter
					
				}
				FormLine {
					spacing: 5
					width: parent.width-videoModeLabel.implicitWidth
					FormGroup {
						id: videoGridMode
						//: 'Mosaic' : Label to choose a camera mode.
						label: qsTr('videoGridModeLabel') + ':'
						fitLabel: true
						ComboBox {
							model: videoDisplayForm.cameraModel
							textRole: 'displayText'
							currentIndex: SettingsModel.gridCameraMode == SettingsModel.CameraMode_Hybrid 
									? 0 
									: SettingsModel.gridCameraMode == SettingsModel.CameraMode_OccupyAllSpace 
										? 1
										: 2
							onActivated: SettingsModel.gridCameraMode = videoDisplayForm.getId(index)
						}
					}
					FormGroup {
						//: 'Active speaker' : Label to choose a camera mode.
						label: qsTr('videoActiveSpeakerModeLabel') + ':'
						fitLabel: true
						ComboBox {
							model: videoDisplayForm.cameraModel
							textRole: 'displayText'
							currentIndex: SettingsModel.activeSpeakerCameraMode == SettingsModel.CameraMode_Hybrid 
									? 0 
									: SettingsModel.activeSpeakerCameraMode == SettingsModel.CameraMode_OccupyAllSpace 
										? 1
										: 2
							onActivated: SettingsModel.activeSpeakerCameraMode = videoDisplayForm.getId(index)
						}
					}
					FormGroup {
						//: 'Calls' : Label to choose a camera mode.
						label: qsTr('videoCallsModeLabel') + ':'
						fitLabel: true
						ComboBox {
							model: videoDisplayForm.cameraModel
							textRole: 'displayText'
							currentIndex: SettingsModel.callCameraMode == SettingsModel.CameraMode_Hybrid 
									? 0 
									: SettingsModel.callCameraMode == SettingsModel.CameraMode_OccupyAllSpace 
										? 1
										: 2
							onActivated: SettingsModel.callCameraMode = videoDisplayForm.getId(index)
						}
					}
				}
			}
			FormLine {
				FormGroup {
					//: 'Default video layout' : Label to choose the default layout in video conference.
					label: qsTr('videoLayout')
					fitLabel: true
					ComboBox {
					//: 'Mosaic' : Mosaic layout invideo conference.
						model:[{text:qsTr('videoMosaicLayout'), value:LinphoneEnums.ConferenceLayoutGrid}
						//: 'Active speaker' : Active speaker layout for video conference.
								, {text:qsTr('videoActiveSpeakerLayout'), value:LinphoneEnums.ConferenceLayoutActiveSpeaker}
						]
						textRole: 'text'
						currentIndex: SettingsModel.videoConferenceLayout == LinphoneEnums.ConferenceLayoutGrid ? 0 : 1
						onActivated: SettingsModel.videoConferenceLayout = model[index].value
					}
				}
			}
		}
	}
}
