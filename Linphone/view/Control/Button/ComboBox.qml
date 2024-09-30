import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
Control.ComboBox {
	id: mainItem
	// Usage : each item of the model list must be {text: ..., img: ...}
	// If string list, only text part of the delegate will be filled
	// readonly property string currentText: selectedItemText.text
	// Layout.preferredWidth: mainItem.width
	// Layout.preferredHeight: mainItem.height
	property alias listView: listView
	property string constantImageSource
	property int pixelSize: 14 * DefaultStyle.dp
	property int weight: 400 * DefaultStyle.dp
	property int leftMargin: 10 * DefaultStyle.dp
	property bool oneLine: false
	property bool shadowEnabled: mainItem.activeFocus || mainItem.hovered

	onConstantImageSourceChanged: if (constantImageSource)  selectedItemImg.source = constantImageSource
	onCurrentIndexChanged: {
		var item = model[currentIndex]
		if (!item) item = model.getAt(currentIndex)
		selectedItemText.text = item.text
									? item.text
									: item 
										? item
										: ""
		selectedItemImg.source = constantImageSource 
			? constantImageSource 
			: item.img
				? item.img
				: ""
	}
	
	Keys.onPressed: (event)=>{
		if(!mainItem.contentItem.activeFocus && (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return)){
			mainItem.popup.open()
			event.accepted = true
		}
	}

	background: Item{
		Rectangle {
			id: buttonBackground
			anchors.fill: parent
			radius: 63 * DefaultStyle.dp
			color: mainItem.enabled ? DefaultStyle.grey_100 : DefaultStyle.grey_200
			border.color: mainItem.enabled
				? mainItem.activeFocus
					? DefaultStyle.main1_500_main
					: DefaultStyle.grey_200
				: DefaultStyle.grey_400
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: buttonBackground
			source: buttonBackground
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.5
			shadowOpacity: mainItem.shadowEnabled ? 0.1 : 0.0
		}
	}
	contentItem: Item {
		anchors.fill: parent
		anchors.leftMargin: 10 * DefaultStyle.dp
		anchors.rightMargin: indicImage.width + 10 * DefaultStyle.dp
		Image {
			id: selectedItemImg
			source: mainItem.constantImageSource ? mainItem.constantImageSource : ""
			visible: source != ""
			sourceSize.width: 24 * DefaultStyle.dp
			width: visible ? 24 * DefaultStyle.dp : 0
			fillMode: Image.PreserveAspectFit
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			anchors.leftMargin: visible ? mainItem.leftMargin : 0
		}

		Text {
			id: selectedItemText
			color: mainItem.enabled ? DefaultStyle.main2_600 : DefaultStyle.grey_400
			elide: Text.ElideRight
			maximumLineCount: oneLine ? 1 : 2
			wrapMode: Text.WrapAnywhere
			font {
				pixelSize: mainItem.pixelSize
				weight: mainItem.weight
			}
			anchors.left: selectedItemImg.right
			anchors.leftMargin: selectedItemImg.visible ? 5 * DefaultStyle.dp : 10 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.rightMargin: 20 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
		}

		Component.onCompleted: {
			var index = mainItem.currentIndex < 0 ? 0 : mainItem.currentIndex
			if (mainItem.model && mainItem.model[index]) {
				if (mainItem.model[index] && mainItem.model[index].img) {
					selectedItemImg.source = mainItem.model[index].img
				}
				else if (mainItem.model[index] && mainItem.model[index].text)
					selectedItemText.text = mainItem.model[index].text
				else
					selectedItemText.text = mainItem.model[index]
			}
		}
	}


	indicator: Image {
		id: indicImage
		z: 1
		anchors.right: parent.right
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.verticalCenter: parent.verticalCenter
		source: AppIcons.downArrow
		width: 14 * DefaultStyle.dp
		fillMode: Image.PreserveAspectFit
	}

	popup: Control.Popup {
		id: popup
		y: mainItem.height - 1
		width: mainItem.width
		implicitHeight: contentItem.implicitHeight
		padding: 1 * DefaultStyle.dp
		//height: Math.min(implicitHeight, 300)

		onOpened: {
			listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
			listView.forceActiveFocus()
		}
		contentItem: ListView {
			id: listView
			clip: true
			implicitHeight: contentHeight
			height: contentHeight
			model: mainItem.model
			currentIndex: mainItem.highlightedIndex >= 0 ? mainItem.highlightedIndex : 0
			highlightFollowsCurrentItem: true
			highlightMoveDuration: -1
			highlightMoveVelocity: -1
			highlight: Rectangle {
				width: listView.width
				color: DefaultStyle.main2_200
				radius: 15 * DefaultStyle.dp
				y: listView.currentItem? listView.currentItem.y : 0
			}
			
			Keys.onPressed: (event)=>{
				if(event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return){
					event.accepted = true
					mainItem.currentIndex = listView.currentIndex
					popup.close()
				}
			}

			delegate: Item {
				width:mainItem.width
				height: mainItem.height
				// anchors.left: listView.left
				// anchors.right: listView.right

				Image {
					id: delegateImg
					visible: source != ""
					width: visible ? 20 * DefaultStyle.dp : 0
					sourceSize.width: 20 * DefaultStyle.dp
					source: typeof(modelData) != "undefined" && modelData.img ? modelData.img : ""
					fillMode: Image.PreserveAspectFit
					anchors.left: parent.left
					anchors.leftMargin: visible ? 10 * DefaultStyle.dp : 0
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					text: typeof(modelData) != "undefined"
							? modelData.text
								? modelData.text
								: modelData
							: $modelData
								? $modelData
								: ""
					elide: Text.ElideRight
					maximumLineCount: 1
					wrapMode: Text.WrapAnywhere
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
					}
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: delegateImg.right
					anchors.leftMargin: delegateImg.visible ? 5 * DefaultStyle.dp : 10 * DefaultStyle.dp
					anchors.right: parent.right
					anchors.rightMargin: 20 * DefaultStyle.dp
				}

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					Rectangle {
						anchors.fill: parent
						opacity: 0.1
						radius: 15 * DefaultStyle.dp
						color: DefaultStyle.main2_500main
						visible: parent.containsMouse
					}
					onClicked: {
						mainItem.currentIndex = index
						popup.close()
					}
				}
			}

			Control.ScrollIndicator.vertical: Control.ScrollIndicator { }
		}

		

		background: Item {
			implicitWidth: mainItem.width
			implicitHeight: 30 * DefaultStyle.dp
			Rectangle {
				id: cboxBg
				anchors.fill: parent
				radius: 15 * DefaultStyle.dp
			}
			MultiEffect {
				anchors.fill: cboxBg
				source: cboxBg
				shadowEnabled: true
				shadowColor: DefaultStyle.grey_1000
				shadowBlur: 0.1
				shadowOpacity: 0.1
			}
		} 
	}
}
