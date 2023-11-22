import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: mainItem
	property string label: ""
	property int backgroundWidth: 200
	// Usage : each item of the model list must be {text: ..., img: ...}
	property var modelList: []
	readonly property string currentText: selectedItemText.text
	property bool enableBackgroundColors: true
	readonly property bool hasActiveFocus: combobox.activeFocus

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label
		color: combobox.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	Control.ComboBox {
		id: combobox
		model: mainItem.modelList
		width: mainItem.backgroundWidth
		background: Rectangle {
			implicitWidth: mainItem.backgroundWidth
			implicitHeight: 30
			radius: 15
			color: combobox.enabled ? DefaultStyle.formItemBackgroundColor : DefaultStyle.formItemDisableBackgroundColor
			border.color: combobox.enabled ? DefaultStyle.formItemBorderColor : DefaultStyle.formItemDisableColor
		}
		contentItem: Item {
			anchors.left: parent.left
			anchors.right: indicImage.right
			Image {
				id: selectedItemImg
				visible: source != ""
				sourceSize.width: 20
				width: visible ? 20 : 0
				fillMode: Image.PreserveAspectFit
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: visible ? 10 : 0
			}

			Text {
				id: selectedItemText
				color: combobox.enabled ? DefaultStyle.defaultTextColor : DefaultStyle.formItemDisableColor
				elide: Text.ElideRight
				anchors.left: selectedItemImg.right
				anchors.leftMargin: selectedItemImg.visible ? 5 : 10
				anchors.right: parent.right
				anchors.rightMargin: 20
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
			anchors.rightMargin: 10
			anchors.verticalCenter: parent.verticalCenter
			source: AppIcons.downArrow
		}

		popup: Control.Popup {
			id: listPopup
			y: combobox.height - 1
			width: combobox.width
			implicitHeight: contentItem.implicitHeight
			padding: 1

			contentItem: ListView {
				id: listView
				clip: true
				implicitHeight: contentHeight
				model: combobox.model
				currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
				highlightFollowsCurrentItem: true
				highlight: Rectangle {
					width: listView.width
					color: DefaultStyle.comboBoxHighlightColor
					radius: 15
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
						width: visible ? 20 : 0
						sourceSize.width: 20
						source: modelData.img ? modelData.img : ""
						fillMode: Image.PreserveAspectFit
						anchors.left: parent.left
						anchors.leftMargin: visible ? 10 : 0
						anchors.verticalCenter: parent.verticalCenter
					}

					Text {
						text: modelData.text 
								? modelData.text 
								: modelData 
									? modelData
									: ""
						elide: Text.ElideRight
						anchors.verticalCenter: parent.verticalCenter
						anchors.left: delegateImg.right
						anchors.leftMargin: delegateImg.visible ? 5 : 10
						anchors.right: parent.right
						anchors.rightMargin: 20
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						Rectangle {
							anchors.fill: parent
							opacity: 0.1
							radius: 15
							color: DefaultStyle.comboBoxHoverColor
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

			background: Rectangle {
				implicitWidth: mainItem.backgroundWidth
				implicitHeight: 30
				radius: 15
			}
		}
	}
}
