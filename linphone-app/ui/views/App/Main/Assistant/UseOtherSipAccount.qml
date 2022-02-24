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
		
		mainActionEnabled: username.text.length &&
						   sipDomain.text.length &&
						   password.text.length
		//: 'I understand' : Popup confirmation for a warning
		mainActionLabel: showWarning ? qsTr('understandAction').toUpperCase()
		//: 'Use' : Popup confirmation for a form
		: qsTr('confirmAction').toUpperCase()
		
		title: qsTr('useOtherSipAccountTitle')
		
		width: AssistantAbstractViewStyle.content.width
		height: AssistantAbstractViewStyle.content.height
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		
		property bool showWarning : true
		
		// ---------------------------------------------------------------------------
		
		StackView {
			id: mainStack
			anchors.fill: parent.contentItem
			width: AssistantAbstractViewStyle.content.width
			height: AssistantAbstractViewStyle.content.height
			initialItem: warningComponent
		}
		Component{
			id: warningComponent
			Column{
				spacing: UseAppSipAccountStyle.warningBlock.spacing
				anchors.fill: parent.contentItem
				
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
				anchors.fill: parent.contentItem
				width: AssistantAbstractViewStyle.content.width
				height: AssistantAbstractViewStyle.content.height
				
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
			
			action: (function () {
				if(mainItem.showWarning) {
					mainItem.showWarning = false
					mainStack.replace(formComponent);
					requestBlock.stop('')
				}else{
					if (!assistantModel.addOtherSipAccount({
															   username: username.text,
															   displayName: displayName.text,
															   sipDomain: sipDomain.text,
															   password: password.text,
															   transport: transport.model[transport.currentIndex]
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
