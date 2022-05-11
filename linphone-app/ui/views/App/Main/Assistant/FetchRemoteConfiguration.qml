import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
// =============================================================================
Item{
	AssistantAbstractView {
		mainAction: requestBlock.execute
		mainActionEnabled: url.text.length > 0
		mainActionLabel: qsTr('confirmAction')
		
		title: qsTr('fetchRemoteConfigurationTitle')
		width: AssistantAbstractViewStyle.content.width
		height: AssistantAbstractViewStyle.content.height
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		// ---------------------------------------------------------------------------
		
		Connections {
			target: SettingsModel
			
			onRemoteProvisioningChanged: {
				requestBlock.stop('')
				window.detachVirtualWindow()
				window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
											   descriptionText: qsTr('remoteProvisioningUpdateDescription'),
										   }, function (status) {
											   if (status) {
												   App.restart()
											   } else {
												   window.setView('Home')
											   }
										   })
			}
			
			onRemoteProvisioningNotChanged: requestBlock.stop(qsTr('remoteProvisioningError'))
		}
		
		// ---------------------------------------------------------------------------
		
		Column {
			anchors.fill: parent.contentItem
			anchors.topMargin: AssistantAbstractViewStyle.info.spacing
			width: AssistantAbstractViewStyle.content.width
			height: AssistantAbstractViewStyle.content.height
			
			Form {
				orientation: Qt.Vertical
				width: parent.width
				
				FormLine {
					FormGroup {
						label: qsTr('urlLabel')
						
						TextField {
							id: url
						}
					}
				}
			}
			
			RequestBlock {
				id: requestBlock
				
				action: (function () {
					SettingsModel.remoteProvisioning = url.text
				})
				
				width: parent.width
			}
		}
		
	}
	Component.onCompleted: {
		if( !CoreManager.isLastRemoteProvisioningGood() )
			//: 'Last remote provisioning failed' : Test to warn the user that the last fetch of remote provisioning has failed.
			requestBlock.stop(qsTr('lastProvisioningFailed'))
	}
}
