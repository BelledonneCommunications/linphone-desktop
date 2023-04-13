import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================
Item{
	visible: mainListView.count > 0
	Layout.preferredHeight: visible ? ChatFilePreviewStyle.height : 0
	
	function addFile(path){
		contents.addFile(path)
	}
	
	ScrollableListView{
		id: mainListView
		
		spacing: ChatFilePreviewStyle.filePreview.closeButton.iconSize
		anchors.fill: parent
		anchors.rightMargin: ChatStyle.rightButtonMargin + ChatStyle.rightButtonLMargin + ChatStyle.rightButtonSize
		orientation: Qt.Horizontal
		model: ContentProxyModel{
			id: contents
		}
		header:Component{
			Item{
				width: ChatFilePreviewStyle.filePreview.closeButton.iconSize/2
				height:mainListView.height
			}
		}
		footer: Component{
			Item{
				width: ChatFilePreviewStyle.filePreview.closeButton.iconSize
				height:mainListView.height
			}
		}
		delegate:
			FileView{
				height:mainListView.height-ChatFilePreviewStyle.filePreview.heightMargins
				width: height * ChatFilePreviewStyle.filePreview.format
				anchors.verticalCenter: parent ? parent.verticalCenter : ScrollableListView.verticalCenter
				anchors.verticalCenterOffset: 7
				contentModel: $modelData
				thumbnail: $modelData.thumbnail
				name: $modelData.name
				animationScale: 1.1
				ActionButton{
					anchors.bottom: parent.top
					anchors.bottomMargin: -height/2
					anchors.left: parent.right
					anchors.leftMargin: -width/2
					isCustom: true
					backgroundRadius: width
					colorSet: ChatFilePreviewStyle.filePreview.removeButton
					z: parent.z+1
					onClicked:{
						contents.remove($modelData)
					}
				}
		}
	}
	ActionButton{
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: ChatStyle.rightButtonMargin
		isCustom: true
		backgroundRadius: width
		colorSet: ChatFilePreviewStyle.filePreview.closeButton
		z: parent.z+1
		onClicked:{
			contents.clear()
		}
	}
}