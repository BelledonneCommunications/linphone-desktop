import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import Linphone
  
ColumnLayout {
	id: mainItem
	property string label: ""
	// Usage : each item of the model list must be {text: ..., img: ...}
	// If string list, only text part of the delegate will be filled
	property var modelList: []
	readonly property string currentText: selectedItemText.text
	property bool enableBackgroundColors: true
	readonly property bool hasActiveFocus: combobox.activeFocus

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label
		color: combobox.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		font {
			pixelSize: 13 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
		}
	}

	Control.ComboBox {
		id: combobox
		model: mainItem.modelList
		Layout.preferredWidth: mainItem.width
		background: Rectangle {
			implicitWidth: mainItem.width
			implicitHeight: 49 * DefaultStyle.dp
			radius: 63 * DefaultStyle.dp
			color: combobox.enabled ? DefaultStyle.grey_100 : DefaultStyle.grey_200
			border.color: combobox.enabled ? DefaultStyle.grey_200 : DefaultStyle.grey_400
		}
		contentItem: Item {
			anchors.left: parent.left
			anchors.right: indicImage.right
			Image {
				id: selectedItemImg
				visible: source != ""
				sourceSize.width: 20 * DefaultStyle.dp
				width: visible ? 20 * DefaultStyle.dp : 0
				fillMode: Image.PreserveAspectFit
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: visible ? 10 * DefaultStyle.dp : 0
			}

			Text {
				id: selectedItemText
				color: combobox.enabled ? DefaultStyle.main2_600 : DefaultStyle.grey_400
				elide: Text.ElideRight
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
				anchors.left: selectedItemImg.right
				anchors.leftMargin: selectedItemImg.visible ? 5 * DefaultStyle.dp : 10 * DefaultStyle.dp
				anchors.right: parent.right
				anchors.rightMargin: 20 * DefaultStyle.dp
				anchors.verticalCenter: parent.verticalCenter
			}

			Component.onCompleted: {
				var index = combobox.currentIndex < 0 ? 0 : combobox.currentIndex
				if (mainItem.modelList[index].img) {
					selectedItemImg.source = mainItem.modelList[0].img
				}
				if (mainItem.modelList[index].text)
					selectedItemText.text = mainItem.modelList[0].text
				else if (mainItem.modelList[index])
					selectedItemText.text = mainItem.modelList[0]
			}
		}


		indicator: Image {
			id: indicImage
			anchors.right: parent.right
			anchors.rightMargin: 10 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			source: AppIcons.downArrow
		}

		popup: Control.Popup {
			id: listPopup
			y: combobox.height - 1
			width: combobox.width
			implicitHeight: contentItem.implicitHeight
			padding: 1 * DefaultStyle.dp

			contentItem: ListView {
				id: listView
				clip: true
				implicitHeight: contentHeight
				model: combobox.model
				currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
				highlightFollowsCurrentItem: true
				highlight: Rectangle {
					width: listView.width
					color: DefaultStyle.main2_300
					radius: 15 * DefaultStyle.dp
					y: listView.currentItem? listView.currentItem.y : 0
				}

				delegate: Item {
					width:combobox.width
					height: combobox.height
					anchors.left: parent.left
					anchors.right: parent.right

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
						onPressed: {
							combobox.state = ""
							selectedItemText.text = modelData.text  
														? modelData.text
														: modelData 
															? modelData
															: ""
							selectedItemImg.source = modelData.img ? modelData.img : ""
							combobox.currentIndex = index
							listPopup.close()
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
}
