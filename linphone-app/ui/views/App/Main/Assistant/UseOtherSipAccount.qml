import QtQuick 2.7
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0
import ConstantsCpp 1.0

import App.Styles 1.0
import Common.Styles 1.0

// =============================================================================
	
	AssistantAbstractView {
		id: mainItem
		mainAction: requestBlock.execute
		property bool isValid: false
		mainActionEnabled: mainItem.showWarning || isValid
		//: 'I understand' : Popup confirmation for a warning
		mainActionLabel: showWarning ? qsTr('understandAction').toUpperCase()
		//: 'Use' : Popup confirmation for a form
		: qsTr('confirmAction').toUpperCase()
		
		title: qsTr('useOtherSipAccountTitle')
		
		
		property bool showWarning : true
		// ---------------------------------------------------------------------------
		
		StackView {
			id: mainStack
			width: currentItem.implicitWidth>0 ? currentItem.implicitWidth : currentItem.width
			height: currentItem.implicitHeight>0 ? currentItem.implicitHeight : currentItem.height
			initialItem: warningComponent
			anchors.horizontalCenter: parent.horizontalCenter
		}
		Component{
			id: warningComponent
				Column{
				spacing: UseAppSipAccountStyle.warningBlock.spacing
				width: FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
					Text {
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.colorModel.color
					wrapMode: Text.WordWrap
					//: 'Some features require a %1 account, such as group messaging or ephemeral messaging.' : Warning text about features. %1 is the application name
					text: qsTr('warningFeatures').arg(applicationName)
				}
				Text{
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.colorModel.color
					wrapMode: Text.WordWrap
					//: 'These features are hidden when you register with a third party SIP account.' : Warning text for using third party account.
					text: qsTr('warningThirdParty')
				}
				Text {
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.colorModel.color
					wrapMode: Text.WordWrap
					//: 'To enable it in a commercial project, please contact us.' : Warning text for contacting about enabling features.
					text: qsTr('warningContact')
				}
				Text {
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.contactUrl.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignHCenter
					wrapMode: Text.WordWrap
					color: UseAppSipAccountStyle.warningBlock.colorModel.color
					linkColor: UseAppSipAccountStyle.warningBlock.contactUrl.colorModel.color
					text: '<a href="'+ConstantsCpp.ContactUrl+'">'+ConstantsCpp.ContactUrl+'</a>'
					
					visible: ConstantsCpp.ContactUrl != ''
					
					onLinkActivated: Qt.openUrlExternally(link)
				
					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.NoButton
						cursorShape: parent.hoveredLink
									 ? Qt.PointingHandCursor
									 : Qt.IBeamCursor
					}
				}
			}
		}
			
		Component {
			id: formComponent
			Column {
				width: FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
				property bool isValid: username.text.length &&
								   sipDomain.text.length &&
								   password.text.length
				onIsValidChanged: mainItem.isValid = isValid
				
				property alias usernameText: username.text
				property alias displayNameText: displayName.text
				property alias sipDomainText: sipDomain.text
				property alias passwordText: password.text
				function getTransport(){
					return transport.model[transport.currentIndex]
				}
					
				Form {
					orientation: Qt.Vertical
					width: FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
					anchors.horizontalCenter: parent.horizontalCenter
					
					FormLine {
						FormGroup {
							label: qsTr('usernameLabel')
							
							TextField {
								id: username
							}
						}
						
						FormGroup {
							label: qsTr('displayNameLabel')
							
							TextField {
								id: displayName
							}
						}
					}
					
					FormLine {
						FormGroup {
							label: qsTr('sipDomainLabel')
							
							TextField {
								id: sipDomain
							}
						}
					}
					
					FormLine {
						FormGroup {
							label: qsTr('passwordLabel')
							
							PasswordField {
								id: password
							}
						}
					}
					
					FormLine {
						FormGroup {
							label: qsTr('transportLabel')
							
							ComboBox {
								id: transport
								model: [ 'UDP', 'TCP', 'TLS']
							}
						}
					}
				}
			}
		}
		
		RequestBlock {
				id: requestBlock
				width: parent.width
				anchors.top: mainStack.bottom
				anchors.topMargin: UseAppSipAccountStyle.warningBlock.spacing
				loading: assistantModel.isProcessing
				
				action: (function () {
					if(mainItem.showWarning) {
						mainItem.showWarning = false
						mainStack.push(formComponent);
						requestBlock.setText('')
					}else{
						if (!assistantModel.addOtherSipAccount({
																   username: mainStack.currentItem.usernameText,
																   displayName: mainStack.currentItem.displayNameText,
																   sipDomain: mainStack.currentItem.sipDomainText,
																   password: mainStack.currentItem.passwordText,
																   transport: mainStack.currentItem.getTransport()
															   })) {
							requestBlock.setText(qsTr('addOtherSipAccountError'))
						} else {
							requestBlock.setText('')
							window.setView('Home')
						}
					}
				})
			}
		
		AssistantModel {
			id: assistantModel
			configFilename: 'use-other-sip-account.rc'
		}
	}
