import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

// Snippet
Window{
	id: mainItem
	height: 800
	width: 1000
	visible: true
	ColumnLayout{
		anchors.fill: parent
		RowLayout{
			FriendGui{
				id: contact
			}
			TextField{
				placeholderText: 'Name'
				initialText: contact.core.givenName
				onTextChanged: contact.core.givenName = text 
			}
			TextField{
				placeholderText: 'Address'
				initialText: contact.core.address
				onTextChanged: contact.core.address = text
			}
			Button {
				text: 'Create'
				onClicked: {
					contact.core.save()
				}
			}
			Text {
				text: 'IsSaved:'+contact.core.isSaved
			}
		}
		ListView{
			id: friends
			Layout.fillHeight: true
			Layout.fillWidth: true
			onCountChanged: console.log("count changed", count)
			
			model: MagicSearchProxy{
				id: search
				filterText: ''
			}
			delegate: Rectangle{
				height: 50
				width: friends.width
				RowLayout{
					anchors.fill: parent
					Text{
						text: modelData.core.presenceTimestamp + " == " +modelData.core.consolidatedPresence + " / "
					}
					Button {
						text: 'X'
						onClicked: {
							modelData.core.remove()
						}
					}
					Text{
						text: modelData.core.address
					}
					TextField{
						initialText: modelData.core.address
						onTextChanged: if(modelData.core.address != text){
								modelData.core.address = text
								resetText()
							 }
					}
					Text{
						text: 'IsSaved:'+modelData.core.isSaved
					}
					Button {
						text: 'Revert'
						onClicked: {
							modelData.core.undo()
						}
					}
					Button {
						text: 'Save'
						onClicked: {
							modelData.core.save()
						}
					}
				}
			}
		}
		Button {
			text: 'Get'
			Layout.rightMargin: 20
			onClicked: {
				search.filterText = '*'
			}
		}
	}
	
}

