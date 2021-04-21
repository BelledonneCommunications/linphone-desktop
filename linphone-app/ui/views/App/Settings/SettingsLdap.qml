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
// LDAP line description : Summary (name + activation + remove)
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
					spacing:SettingsAdvancedStyle.lists.spacing
					Text {
						id: summaryTitle
						color: FormStyle.header.title.color
						text: (modelData.displayName?modelData.displayName:(modelData.server?modelData.server:qsTr('newServer')))//'New server'))
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
				ActionButton {
					id:removeldap
					anchors.verticalCenter: parent.verticalCenter
					anchors.right:parent.right
					anchors.rightMargin:SettingsAdvancedStyle.lists.margin
					icon: 'cancel'
					iconSize:CallsStyle.entry.iconActionSize
					scale:SettingsAdvancedStyle.lists.iconScale
					onClicked:{
						LdapListModel.remove(modelData)
					}
					visible:hoveringRow.containsMouse
				}
			}
			MouseArea{
				id:hoveringRow
				anchors.fill:parent
				preventStealing :true
				hoverEnabled :true
				propagateComposedEvents:true
				onClicked:{mouse.accepted = false}
				onPressed:{mouse.accepted = false}
			}
		}
	}
}
