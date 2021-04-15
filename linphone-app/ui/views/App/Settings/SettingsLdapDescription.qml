import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.15	// SwipeView : Qt 5.7
import QtQuick.Controls 1.4	// TabView
import Common 1.0
import Linphone 1.0

import App.Styles 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

// =============================================================================
//Qt *View override childs geometry. Do not use them
Item{
	id: swipeView
	anchors.left: parent.left
	anchors.right: parent.right
	property LdapModel ldapData
	property int currentIndex: ldapData.isValid?0:1
	clip:true
	Component.onCompleted:updateHeight()
	onCurrentIndexChanged:updateHeight()
	
	function updateHeight(){
		if( currentIndex==0)
			swipeView.height=summaryRowItem.height
		else if( currentIndex==1)
			swipeView.height=mainColumn.height
	}
	Item{
		id: summaryRow
		anchors.fill:parent
		visible:currentIndex == 0
		Row{
			id:summaryRowItem
			anchors.horizontalCenter: parent.horizontalCenter
			spacing:10
			ActionButton {
				id:removeldap
				anchors.verticalCenter: parent.verticalCenter
				icon: 'cancel'
				iconSize:CallsStyle.entry.iconActionSize
				scale:0.8
			}
			Text {
				id: summaryTitle
				color: FormStyle.header.title.color
				text: serverUrl.text?serverUrl.text:'New server'
				font {
					bold: true
					pointSize: FormStyle.header.title.pointSize
				}
				anchors.verticalCenter: parent.verticalCenter
				MouseArea{
					anchors.fill:parent
					onClicked:swipeView.currentIndex = 1
				}
			}
			Switch {
				id: ldapActivation
				anchors.verticalCenter: parent.verticalCenter
				checked: false
				onClicked: {
					checked = !checked
				}
			}
			
		}
	}
	Item {
		id: page2
		anchors.fill:parent
		visible:currentIndex == 1
		Column {
			id: mainColumn
			property bool dealWithErrors: false
			property int orientation: Qt.Horizontal
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.leftMargin: 0
			anchors.rightMargin: 0
			height:centerRow.height+titleRow.height+spacing*2
			// ---------------------------------------------------------------------------
			
			spacing: FormStyle.spacing
			
			// ---------------------------------------------------------------------------
			
			Column{
				id:titleRow
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 0
				anchors.rightMargin: 0
				spacing: FormStyle.header.spacing
				
				Text {
					id: title
					text:"LDAP Server settings :"+serverUrl.text
					color: FormStyle.header.title.color
					font {
						bold: true
						pointSize: FormStyle.header.title.pointSize
					}
				}
				
				Rectangle {
					anchors.left:parent.left
					anchors.right:parent.right
					
					color: FormStyle.header.separator.color
				}
			}
			Item{
				id: centerRow
				anchors.left:parent.left
				anchors.right:parent.right
				transformOrigin: Item.Center
				layer.wrapMode: ShaderEffectSource.ClampToEdge
				height:detailsRow.height
				ActionButton {
					id:back
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					anchors.leftMargin: 0
					icon: 'edit'
					iconSize:CallsStyle.entry.iconActionSize
					onClicked:swipeView.currentIndex = 0
				}
				RowLayout{// Details row have its size from children
					id:detailsRow
					anchors.left: back.right
					anchors.right: deleteLdap.left
					anchors.rightMargin: 10
					anchors.leftMargin: 10
					ColumnLayout{
						Layout.fillHeight: true
						Layout.fillWidth:true
						TextField {
							id:serverUrl
							Layout.fillWidth: true
							placeholderText :"Server"
							TooltipArea{
								text : 'LDAP Server. eg: ldap:/// for a localhost server or ldap://ldap.example.org/'
							}
						}
						TextField {
							Layout.fillWidth: true
							placeholderText :"Bind DN"
							TooltipArea{
								text : 'The bindDN DN is the credential that is used to authenticate against an LDAP.\n eg: cn=ausername,ou=people,dc=bc,dc=com'
							}
						}
						PasswordField {
							Layout.fillWidth: true
							placeholderText :"Password"
						}
						Switch {
							id: useTlsLdap
							anchors.verticalCenter: parent.verticalCenter
							anchors.right: parent.right
							anchors.rightMargin: 0
							checked: false
							onClicked: {
								checked = !checked
							}
						}
					}
					ColumnLayout{
						Layout.fillHeight: true
						Layout.fillWidth:true
						TextField {
							Layout.fillWidth: true
							placeholderText :"Base Object"
							TooltipArea{
								text : ''
							}
						}
						TextField {
							text: "Filter"
							Layout.fillWidth: true
							placeholderText :"Filter"
							TooltipArea{
								text : 'The search is base on this filter to search friends. Default value : (sn=%s)'
							}
						}
						NumericField {
							text: "MaxResults"
							Layout.fillWidth: true
							TooltipArea{
								text : 'The max results when requesting searches'
							}
						}
					}
					ColumnLayout{
						Layout.fillHeight: true
						Layout.fillWidth:true
						TextField {
							Layout.fillWidth: true
							placeholderText :"Names Attributes"
							TooltipArea{
								text : 'Check these attributes To build Name Friend, separated by a comma and the first is the highest priority. The default value is: sn'
							}
						}
						TextField {
							Layout.fillWidth: true
							placeholderText :"Sip Attributes"
							TooltipArea{
								text : 'Check these attributes To build the SIP username in address of Friend, separated by a comma and the first is the highest priority. The default value is: mobile,telephoneNumber,homePhone,sn'
							}
						}
						TextField {
							Layout.fillWidth: true
							placeholderText :"Scheme"
							TooltipArea{
								text : 'Add the scheme to the sip address(scheme:username@domain). The default value is sip'
							}
						}
						TextField {
							Layout.fillWidth: true
							placeholderText :"Domain"
							TooltipArea{
								text : 'Add the domain to the sip address(scheme:username@domain). The default value is the ldap server url'
							}
						}
					}
				}
				Switch {
					id: deleteLdap
					anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right
					anchors.rightMargin: 0
					checked: false
					onClicked: {
						checked = !checked
					}
				}
			}
		}
		
	}
	/*
	Column{
		id:summaryRow
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 0
		anchors.rightMargin: 0
		spacing: FormStyle.header.spacing
		//visible: parent.title.length > 0
		height:summaryTitle.height
		
		Text {
			id: summaryTitle
			color: FormStyle.header.title.color
			text: "Summary of "// +serverUrl.text
			font {
				bold: true
				pointSize: FormStyle.header.title.pointSize
			}
		}
			MouseArea{
				onClicked: swipeView.currentIndex = 2
				anchors.fill:parent
				Rectangle{
					anchors.fill:parent
					color:"red"
				}
			}
	}
	
	Column {
		id: mainColumn
		property alias title: title.text
		property bool dealWithErrors: false
		property int orientation: Qt.Horizontal
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 0
		anchors.rightMargin: 0
		height:centerRow.height+titleRow.height+spacing*2
		// ---------------------------------------------------------------------------
		
		spacing: FormStyle.spacing
		
		// ---------------------------------------------------------------------------
		
		Column{
			id:titleRow
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.leftMargin: 0
			anchors.rightMargin: 0
			spacing: FormStyle.header.spacing
			//visible: parent.title.length > 0
			
			Text {
				id: title
				text:"LDAP Server :"+serverUrl.text
				color: FormStyle.header.title.color
				font {
					bold: true
					pointSize: FormStyle.header.title.pointSize
				}
			}
			
			Rectangle {
				anchors.left:parent.left
				anchors.right:parent.right
				
				color: FormStyle.header.separator.color
			}
		}
		Item{
			id: centerRow
			anchors.left:parent.left
			anchors.right:parent.right
			transformOrigin: Item.Center
			layer.wrapMode: ShaderEffectSource.ClampToEdge
			height:detailsRow.height
			ActionButton {
				id:removeldap
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 0
				icon: 'cancel'
				iconSize:CallsStyle.entry.iconActionSize-2
			}
			RowLayout{// Details row have its size from children
				id:detailsRow
				anchors.left: removeldap.right
				anchors.right: deleteLdap.left
				anchors.rightMargin: 10
				anchors.leftMargin: 10
				ColumnLayout{
					Layout.fillHeight: true
					Layout.fillWidth:true
					TextField {
						id:serverUrl
						text: "Server"
						Layout.fillWidth: true
						placeholderText :"Server"
					}
					TextField {
						text: "Bind DN"
						Layout.fillWidth: true
					}
					TextField {
						text: "Password"
						Layout.fillWidth: true
					}
					
				}
				ColumnLayout{
					Layout.fillHeight: true
					Layout.fillWidth:true
					TextField {
						text: "Base Object"
						Layout.fillWidth: true
					}
					TextField {
						text: "Filter"
						Layout.fillWidth: true
					}
					TextField {
						text: "MaxResults"
						Layout.fillWidth: true
					}
				}
				ColumnLayout{
					Layout.fillHeight: true
					Layout.fillWidth:true
					TextField {
						text: "Names Attributes"
						Layout.fillWidth: true
					}
					TextField {
						text: "Sip Attributes"
						Layout.fillWidth: true
					}
					TextField {
						text: "Scheme"
						Layout.fillWidth: true
					}
					TextField {
						text: "Domain"
						Layout.fillWidth: true
					}
				}
			}
			Switch {
				id: deleteLdap
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				anchors.rightMargin: 0
				checked: false
				onClicked: {
					checked = !checked
				}
			}
		}
	}
	
	states: [
		State {
				   name: "Summary"
				   when: swipeView.index==1
			   },
     State {
			name: "Details"
			when: swipeView.index==2		
		}
 ]
 */
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:480;width:640}
}
##^##*/
