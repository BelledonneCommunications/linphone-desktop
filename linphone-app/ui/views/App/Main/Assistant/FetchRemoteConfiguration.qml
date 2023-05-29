import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
// =============================================================================
	
	AssistantAbstractView {
		id: mainItem
		title: qsTr('fetchRemoteConfigurationTitle')
		maximized: true
		
		//: 'generate' : title button to generate a code.
		property string generateButtonText: qsTr('generateLabel')
		// ---------------------------------------------------------------------------
		AssistantModel {
			id: assistantModel
			property string qrcode
		}
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
		Connections{
			target: assistantModel
			onNewQRCodeReceived: {assistantModel.qrcode = 'image://qrcode/'+code; requestBlock.stop('')}
			onNewQRCodeNotReceived: requestBlock.stop(message)
			onOauth2StatusChanged: requestBlock.setText(status)
			onOauth2RequestFailed: requestBlock.stop(error)
			onOauth2AuthenticationGranted: requestBlock.stop('')
			onProvisioningTokenReceived: {url.text = token
											SettingsModel.remoteProvisioning = url.text
											assistantModel.qrcode = ''
											requestBlock.stop('')}
			
			onQRCodeAttached: requestBlock.stop('Attached')
			onQRCodeNotAttached: requestBlock.stop(message)
			
			onQRCodeFound: {
				if(qRCodeRead.currentIndex == 0)
					url.text = token;
				else
					assistantModel.attachAccount(token)
			}
		}
		
		// ---------------------------------------------------------------------------
		
		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 0
			spacing: 0
			
			Text{
				Layout.alignment: Qt.AlignCenter
				Layout.preferredWidth: urlLayout.width
				
				font.pointSize: FetchRemoteConfigurationStyle.fieldTitles.pointSize
				font.weight: Font.Bold
				color: FetchRemoteConfigurationStyle.fieldTitles.colorModel.color
				
				
				text: qsTr('urlLabel')
			}
			RowLayout{
				id: urlLayout
				Layout.preferredHeight: fetchButton.fitHeight
				Layout.alignment: Qt.AlignCenter
				
				spacing: 10
				
				TextField {
					Layout.preferredWidth: mainItem.width/2
					id: url
				}
				TextButtonB {
					id: fetchButton
					Layout.preferredWidth: fitWidth
					Layout.preferredHeight: fitHeight
					addHeight: 15
					
					onClicked: SettingsModel.remoteProvisioning = url.text
					
					text: qsTr('confirmAction')
					enabled: url.text.length > 0
				}
				 /*Dev Tool
				TextButtonB {
					id: testButton
					Layout.preferredWidth: fitWidth
					Layout.preferredHeight: fitHeight
					
					onClicked: assistantModel.createTestAccount()
					
					text: 'Create Test'
				}*/
			}
			
			RequestBlock {
				id: requestBlock
				action: (function () {
				})
				Layout.fillWidth: true
			}
			Text{
				Layout.topMargin: 15
				Layout.alignment: Qt.AlignCenter
				visible: oAuth2Button.visible
				font.pointSize: FetchRemoteConfigurationStyle.fieldTitles.pointSize
				font.weight: Font.Bold
				font.capitalization: Font.Capitalize
				color: FetchRemoteConfigurationStyle.fieldTitles.colorModel.color
				//: 'or' : conjunction to choose between options.
				text: qsTr('or')
			}
			TextButtonB {
				id: oAuth2Button
				Layout.margins: 15
				Layout.alignment: Qt.AlignCenter
				text: 'OAuth2'
				visible: assistantModel.isOAuth2Available()
				onClicked: {requestBlock.start(); assistantModel.requestOauth2()}
				capitalization: Font.AllUppercase
			}
			Text{
				Layout.topMargin: 15
				Layout.alignment: Qt.AlignCenter
				visible: SettingsModel.isQRCodeAvailable()
				
				font.pointSize: FetchRemoteConfigurationStyle.fieldTitles.pointSize
				font.weight: Font.Bold
				font.capitalization: Font.Capitalize
				color: FetchRemoteConfigurationStyle.fieldTitles.colorModel.color
				//: 'or' : conjunction to choose between options.
				text: qsTr('or')
			}
			ColumnLayout{
				id: simpleQRCodeOptionsView
				Layout.fillWidth: true
				Layout.margins: 15
				visible: SettingsModel.isQRCodeAvailable() && !SettingsModel.developerSettingsEnabled
				Layout.alignment: Qt.AlignCenter
				spacing: 15
				Rectangle{
					Layout.fillHeight: true
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignCenter
					border.color: FetchRemoteConfigurationStyle.qRCode.borderColor.color
					radius: 20
					border.width: 1
					Text{
						anchors.right: parent.right
						anchors.left: parent.left
						anchors.margins: 10
						anchors.verticalCenter: parent.verticalCenter
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						
						visible: assistantModel.qrcode == ''
						wrapMode: Text.WordWrap
						font.pointSize: FetchRemoteConfigurationStyle.explanationQRCode.pointSize
						color: FetchRemoteConfigurationStyle.explanationQRCode.colorModel.color
						//: 'Click on %1 to obtain your remote provisioning QR code' : Describe how to get a remote provisioning QR code by clicking on %1 button (1% is the text in button)
						text : qsTr('remoteProvisioningHow').arg(mainItem.generateButtonText)
					}
					Image{
						anchors.fill: parent
						anchors.margins: 20
						sourceSize.width: width
						sourceSize.height: height
						source: assistantModel.qrcode
						visible: source != ''
					}
				}
				Text{
					Layout.fillWidth: true
					Layout.preferredHeight: contentHeight
					Layout.alignment: Qt.AlignCenter
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					
					visible: assistantModel.qrcode != ''
					wrapMode: Text.WordWrap
					font.pointSize: FetchRemoteConfigurationStyle.explanationQRCode.pointSize
					color: FetchRemoteConfigurationStyle.explanationQRCode.colorModel.color
					//: 'Scan the QR code with your phone' : Explain how to use the QRCode by flasing it.
					text: qsTr('scanQRCode') + '\n'
					//: 'In your app go in assistant - QR code provisioning' : Describe where to flash the QRCode in the mobile application.
							+qsTr('scanQRCodeWhere')
				}
				TextButtonB {
					Layout.alignment: Qt.AlignCenter
					text: mainItem.generateButtonText
					onClicked: assistantModel.requestQRCode()
					capitalization: Font.AllUppercase
				}
			}
			
//------------------------------------------------------------------
// Developer Section
//------------------------------------------------------------------
			GridLayout{
				id: allQRCodeOptionsView
				Layout.fillWidth: true
				Layout.margins: 15
				visible: SettingsModel.isQRCodeAvailable() && SettingsModel.developerSettingsEnabled
				columns: 2
				RowLayout{
					Layout.fillWidth: true
					ComboBox {
						id: qRCodeGeneration
						
						model: ['URL', 'Attach token']
						currentIndex:0
						Component.onCompleted: {}
					}
					TextButtonB {
						text: mainItem.generateButtonText
						capitalization: Font.AllUppercase
						onClicked: if(qRCodeGeneration.currentIndex == 0 )
									   assistantModel.generateQRCode()
								   else
									   assistantModel.requestQRCode()
					}
					Item{
						Layout.fillWidth: true
					}
				}
				RowLayout{
					Layout.fillWidth: true
					Item{ 
						Layout.fillWidth: true
					}
					ComboBox {
						id: qRCodeRead
						
						model: ['URL', 'Attach token']
						currentIndex:0
						Component.onCompleted: {}
					}
					TextButtonB {
						id: qQRCodeReadButton
						text: 'Read'
						onClicked:assistantModel.readQRCode()
						
						toggled: assistantModel.isReadingQRCode
					}
				}
				Image{
					Layout.fillHeight: true
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignCenter
					sourceSize.width: width
					sourceSize.height: height
					source: assistantModel.qrcode
					visible: source != ''
				}
				CameraSticker{
					Layout.fillHeight: true
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignCenter
					cameraQmlName: 'QRCode'
					showUsername: false
					showCustomButton: false
					visible: allQRCodeOptionsView.visible && assistantModel.isReadingQRCode
					deactivateCamera: !visible
					isPreview: true
				}
			}
			Item{
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
		}
		Component.onCompleted: {
		if( !CoreManager.isLastRemoteProvisioningGood() )
			//: 'Last remote provisioning failed' : Test to warn the user that the last fetch of remote provisioning has failed.
			requestBlock.stop(qsTr('lastProvisioningFailed'))
	}
	}
