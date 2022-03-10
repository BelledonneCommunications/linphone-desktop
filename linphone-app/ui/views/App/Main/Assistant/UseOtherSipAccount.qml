import QtQuick 2.7
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0
import ConstantsCpp 1.0

import App.Styles 1.0

// =============================================================================
Item{
	
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
		
		width: mainStack.currentItem.implicitWidth
		height: mainStack.currentItem.implicitHeight 
									+ (requestBlock.implicitHeight > 0 ? requestBlock.implicitHeight : 0)
									+ mainItem.decorationHeight
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		
		property bool showWarning : true
		// ---------------------------------------------------------------------------
		
		StackView {
			id: mainStack
			width: currentItem.implicitWidth>0 ? currentItem.implicitWidth : currentItem.width
			height: currentItem.implicitHeight>0 ? currentItem.implicitHeight : currentItem.height
			initialItem: warningComponent
		}
		Component{
			id: warningComponent
				Column{
				spacing: UseAppSipAccountStyle.warningBlock.spacing
				width: AssistantAbstractViewStyle.content.width
					Text {
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.color
					wrapMode: Text.WordWrap
					//: 'Some features require a Linphone account, such as group messaging or ephemeral messaging.' : Warning text about features.
					text: qsTr('warningFeatures')
				}
				Text{
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.color
					wrapMode: Text.WordWrap
					//: 'These features are hidden when you register with a third party SIP account.' : Warning text for using third party account.
					text: qsTr('warningThirdParty')
				}
				Text {
					elide: Text.ElideRight
					font.pointSize: UseAppSipAccountStyle.warningBlock.pointSize
					
					width: parent.width
					horizontalAlignment: Text.AlignLeft
					color: UseAppSipAccountStyle.warningBlock.color
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
					color: UseAppSipAccountStyle.warningBlock.color
					linkColor: UseAppSipAccountStyle.warningBlock.contactUrl.color
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
				width: AssistantAbstractViewStyle.content.width
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
					width: parent.width
					
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
				
				action: (function () {
					if(mainItem.showWarning) {
						mainItem.showWarning = false
						mainStack.push(formComponent);
						requestBlock.stop('')
					}else{
						if (!assistantModel.addOtherSipAccount({
																   username: mainStack.currentItem.usernameText,
																   displayName: mainStack.currentItem.displayNameText,
																   sipDomain: mainStack.currentItem.sipDomainText,
																   password: mainStack.currentItem.passwordText,
																   transport: mainStack.currentItem.getTransport()
															   })) {
							requestBlock.stop(qsTr('addOtherSipAccountError'))
						} else {
							requestBlock.stop('')
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
}
