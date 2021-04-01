import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

import 'SettingsAdvanced.js' as Logic
// =============================================================================


Column {
	id: mainColumn
	
	// ---------------------------------------------------------------------------
	function add(){
		LdapListModel.add()
	}
	
	spacing: FormStyle.spacing
	
	// ---------------------------------------------------------------------------
	Repeater{
		id: ldapList
		model:LdapProxyModel{id:ldapProxy}
		delegate:Item{
			id: swipeView
			anchors.left: parent.left
			anchors.right: parent.right
			clip:true
			height:summaryRowItem.height
			Item{
				id: summaryRow
				anchors.fill:parent
				Row{
					id:summaryRowItem
					anchors.horizontalCenter: parent.horizontalCenter
					spacing:20
					ActionButton {
						id:removeldap
						anchors.verticalCenter: parent.verticalCenter
						icon: 'cancel'
						iconSize:CallsStyle.entry.iconActionSize
						scale:0.8
						onClicked:LdapListModel.remove(modelData)
					}
					Text {
						id: summaryTitle
						color: FormStyle.header.title.color
						text: (modelData.displayName?modelData.displayName:(modelData.server?modelData.server:'New server'))
						font {
							bold: true
							pointSize: FormStyle.header.title.pointSize
						}
						anchors.verticalCenter: parent.verticalCenter
						MouseArea{
							anchors.fill:parent
							onClicked:Logic.editLdap(modelData)
						}
					}
					Switch {
						id: ldapActivation
						anchors.verticalCenter: parent.verticalCenter
						checked: modelData.enabled
						onClicked: {
							modelData.enabled = !checked
						}
					}
					
				}
			}
		}
	}
}
