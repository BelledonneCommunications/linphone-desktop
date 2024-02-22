import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
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
		console.log("const", constantImageSource, item.img)
	}

	background: Rectangle {
		anchors.fill: mainItem
		radius: 63 * DefaultStyle.dp
		color: mainItem.enabled ? DefaultStyle.grey_100 : DefaultStyle.grey_200
		border.color: mainItem.enabled ? DefaultStyle.grey_200 : DefaultStyle.grey_400
	}
	contentItem: Item {
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
			maximumLineCount: 2
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
	}

	popup: Control.Popup {
		id: popup
		y: mainItem.height - 1
		width: mainItem.width
		implicitHeight: contentItem.implicitHeight
		padding: 1 * DefaultStyle.dp

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
					source: modelData.img ? modelData.img : ""
					fillMode: Image.PreserveAspectFit
					anchors.left: parent.left
					anchors.leftMargin: visible ? 10 * DefaultStyle.dp : 0
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					text: modelData.text 
							? modelData.text 
							: modelData 
								? modelData
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

		onOpened: {
			listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
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
				shadowBlur: 1
				shadowOpacity: 0.1
			}
		} 
	}
}
