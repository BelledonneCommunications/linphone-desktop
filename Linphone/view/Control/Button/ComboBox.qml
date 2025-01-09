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
	property alias listView: listView
	property string constantImageSource
	property int pixelSize: 14 * DefaultStyle.dp
	property int weight: 400 * DefaultStyle.dp
	property int leftMargin: 10 * DefaultStyle.dp
	property bool oneLine: false
	property bool shadowEnabled: mainItem.activeFocus || mainItem.hovered
	property string flagRole// Specific case if flag is shown (special font)

	onConstantImageSourceChanged: if (constantImageSource)  selectedItemImg.imageSource = constantImageSource
	onCurrentIndexChanged: {
		var item = model[currentIndex]
		if (!item) item = model.getAt(currentIndex)
		if (!item) return
		selectedItemText.text = mainItem.textRole
								? item[mainItem.textRole]
								: item.text
									? item.text
									: item 
										? item
										: ""
		if(mainItem.flagRole) selectedItemFlag.text = item[mainItem.flagRole]
		selectedItemImg.imageSource = constantImageSource 
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
	contentItem: RowLayout {
		anchors.fill: parent
		anchors.leftMargin: 10 * DefaultStyle.dp
		anchors.rightMargin: indicImage.width + 10 * DefaultStyle.dp
		spacing: 5 * DefaultStyle.dp
		EffectImage {
			id: selectedItemImg
			Layout.preferredWidth: visible ? 24 * DefaultStyle.dp : 0
			Layout.preferredHeight: visible ? 24 * DefaultStyle.dp : 0
			Layout.leftMargin: mainItem.leftMargin
			imageSource: mainItem.constantImageSource ? mainItem.constantImageSource : ""
			colorizationColor: DefaultStyle.main2_600
			visible: imageSource != ""
			fillMode: Image.PreserveAspectFit
		}
		Text {
			id: selectedItemFlag
			Layout.preferredWidth: implicitWidth
			Layout.leftMargin: selectedItemImg.visible ? 0 : 5 * DefaultStyle.dp
			Layout.alignment: Qt.AlignCenter
			color: mainItem.enabled ? DefaultStyle.main2_600 : DefaultStyle.grey_400
			font {
				family: DefaultStyle.flagFont
				pixelSize: mainItem.pixelSize
				weight: mainItem.weight
			}
		}
		Text {
			id: selectedItemText
			Layout.fillWidth: true
			Layout.leftMargin: selectedItemImg.visible ? 0 : 5 * DefaultStyle.dp
			Layout.rightMargin: 20 * DefaultStyle.dp
			Layout.alignment: Qt.AlignCenter
			color: mainItem.enabled ? DefaultStyle.main2_600 : DefaultStyle.grey_400
			elide: Text.ElideRight
			maximumLineCount: oneLine ? 1 : 2
			wrapMode: Text.WrapAnywhere
			font {
				family: DefaultStyle.defaultFont
				pixelSize: mainItem.pixelSize
				weight: mainItem.weight
			}
		}
	}


	indicator: EffectImage {
		id: indicImage
		z: 1
		anchors.right: parent.right
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.verticalCenter: parent.verticalCenter
		imageSource: AppIcons.downArrow
		width: 14 * DefaultStyle.dp
		fillMode: Image.PreserveAspectFit
	}

	popup: Control.Popup {
		id: popup
		y: mainItem.height - 1
		width: mainItem.width
		implicitHeight: Math.min(contentItem.implicitHeight, mainWindow.height)
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
			height: popup.height
			model: visible? mainItem.model : []
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
				RowLayout{
					anchors.fill: parent
					EffectImage {
						id: delegateImg
						Layout.preferredWidth: visible ? 20 * DefaultStyle.dp : 0
						Layout.leftMargin: 10 * DefaultStyle.dp
						visible: imageSource != ""
						imageWidth: 20 * DefaultStyle.dp
						imageSource: typeof(modelData) != "undefined" && modelData.img ? modelData.img : ""
						fillMode: Image.PreserveAspectFit
					}
					
					Text {
						Layout.preferredWidth: implicitWidth
						Layout.leftMargin: delegateImg.visible ? 0 : 5 * DefaultStyle.dp
						Layout.alignment: Qt.AlignCenter
						visible: mainItem.flagRole
						font {
							family: DefaultStyle.flagFont
							pixelSize: mainItem.pixelSize
							weight: mainItem.weight
						}
						text: mainItem.flagRole
								? typeof(modelData) != "undefined"
									? modelData[mainItem.flagRole]
									: $modelData[mainItem.flagRole]
								: ""
					}
					Text {
						Layout.fillWidth: true
						Layout.leftMargin: delegateImg.visible ? 0 : 5 * DefaultStyle.dp
						Layout.rightMargin: 20 * DefaultStyle.dp
						Layout.alignment: Qt.AlignCenter
						text: typeof(modelData) != "undefined"
								? mainItem.textRole
									? modelData[mainItem.textRole]
									: modelData.text
										? modelData.text
										: modelData
								: $modelData
									? mainItem.textRole
										? $modelData[mainItem.textRole]
										: $modelData
									: ""
						elide: Text.ElideRight
						maximumLineCount: 1
						wrapMode: Text.WrapAnywhere
						font {
							family: DefaultStyle.defaultFont
							pixelSize: 14 * DefaultStyle.dp
							weight: 400 * DefaultStyle.dp
						}
					}
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
