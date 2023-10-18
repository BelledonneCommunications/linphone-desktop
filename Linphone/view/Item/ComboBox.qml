import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: cellLayout
	property string label: ""
	property int backgroundWidth: 200
	// Usage : each item of the model list must be {text: ..., img: ...}
	property var modelList: []
	readonly property string currentText: chosenItemText.text

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: cellLayout.label
		color: DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	ComboBox {
		id: combobox
		model: cellLayout.modelList
		width: cellLayout.backgroundWidth
		background: Loader {
			sourceComponent: backgroundRectangle
		}
		contentItem: Item {
			anchors.left: parent.left
			anchors.right: indic.right
			anchors.leftMargin: 10
			Image {
				id: chosenItemImg
				sourceSize.width: 20
				width: 20
				fillMode: Image.PreserveAspectFit
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
			}

			Text {
				id: chosenItemText
				anchors.left: chosenItemImg.right
				anchors.leftMargin: 10
				anchors.rightMargin: 20
				anchors.right: parent.right
				elide: Text.ElideRight
				anchors.verticalCenter: parent.verticalCenter
			}

			Component.onCompleted: {
				if (cellLayout.modelList[combobox.currentIndex].img)
					chosenItemImg.source = cellLayout.modelList[combobox.currentIndex].img
				if (cellLayout.modelList[combobox.currentIndex].text)
					chosenItemText.text = cellLayout.modelList[combobox.currentIndex].text
			}
		}


		indicator: Image {
			id: indic
			x: combobox.width - width - combobox.rightPadding
			y: combobox.topPadding + (combobox.availableHeight - height) / 2
			source: AppIcons.downArrow
		}

		popup: Popup {
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
				highlight: highlight

				delegate: Item {
					width:combobox.width;
					height: combobox.height;
					Image {
						id: delegateImg;
						sourceSize.width: 20
						width: 20
						anchors.left: parent.left
						anchors.leftMargin: 10
						anchors.verticalCenter: parent.verticalCenter
						fillMode: Image.PreserveAspectFit
						source: modelData.img ? modelData.img : ""
					}

					Text {
						text: modelData.text ? modelData.text : modelData ? modelData : ""
						anchors.leftMargin: 10
						anchors.rightMargin: 10
						elide: Text.ElideRight
						anchors.verticalCenter: parent.verticalCenter
						anchors.left: delegateImg.right
						anchors.right: parent.right
					}

					MouseArea {
						anchors.fill: parent;
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
							chosenItemText.text = modelData.text ? modelData.text : modelData ? modelData : ""
							chosenItemImg.source = modelData.img ? modelData.img : ""
							listView.currentIndex = index
							listPopup.close()
						}
					}
				}

				ScrollIndicator.vertical: ScrollIndicator { }
			}

			onOpened: {
				listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
			}

			Component {
				id: highlight
				Rectangle {
					width: listView.width
					height: listView.height
					color: DefaultStyle.comboBoxHighlightColor
					radius: 15
					y: listView.currentItem? listView.currentItem.y : 0
				}
			}

			background: Loader {
				sourceComponent: backgroundRectangle
			}
		}
		Component {
			id: backgroundRectangle
			Rectangle {
				implicitWidth: cellLayout.backgroundWidth
				implicitHeight: 30
				radius: 15
				color: DefaultStyle.formItemBackgroundColor
			}
		}
	}
}