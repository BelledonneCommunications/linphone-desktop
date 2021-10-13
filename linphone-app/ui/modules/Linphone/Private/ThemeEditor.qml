import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0

import Common 1.0
import Linphone 1.0

import App.Styles 1.0


// =============================================================================
// ThemeEditor{}

Window {
	id: window
	
	
	Component.onCompleted: window.show()
	function setHeight (height) {
		window.height = (Window.screen && height > Window.screen.desktopAvailableHeight)
				? Window.screen.desktopAvailableHeight
				: height
	}
	
	// ---------------------------------------------------------------------------
	height:500
	width:500
	minimumHeight: 300
	minimumWidth: 200
	title: 'Theme Editor'
	
	
	// ---------------------------------------------------------------------------
	onVisibleChanged: visible=true
	//onClosing: Logic.handleClosing(close)
	//onDetachedVirtualWindow: Logic.tryToCloseWindow()
	
	// ---------------------------------------------------------------------------
	ColumnLayout{
	anchors.fill:parent
		TabBar{
			id: bar
			Layout.fillWidth: true
			TabButton{
				text: 'Colors'
			}
			TabButton{
				text: 'Icons'
			}
		}
		StackLayout {
			Layout.fillWidth: true
			currentIndex: bar.currentIndex
			//				COLORS	
			ScrollableListView{
				//anchors.fill:parent
				model:ColorProxyModel{
					id:colorProxy
				}
				delegate: RowLayout{
					TextField{
						id:colorField
						Layout.fillHeight: true
						Layout.fillWidth: true
						text: colorPreview.color
						onEditingFinished: modelData.color = text
					}
					Rectangle{
						id:colorPreview
						width:30
						Layout.fillHeight: true
						color:modelData.color
					}
					Slider{
						id:redSlider
						from:0
						to:255
						value: colorPreview.color.r*255
						onValueChanged: modelData.color.r = value/255
					}
					Slider{
						id:greenSlider
						from:0
						to:255
						value: colorPreview.color.g*255
						onValueChanged: modelData.color.g = value/255
					}
					Slider{
						id:blueSlider
						from:0
						to:255
						value: colorPreview.color.b*255
						onValueChanged: modelData.color.b = value/255
					}
					Slider{
						id:alphaSlider
						from:0
						to:255
						value: colorPreview.color.a*255
						onValueChanged: modelData.color.a = value/255
					}
					
					Text{
						text : modelData.description
					}
					Text{
						text: modelData.name
						visible:modelData.description == ''
					}
				}
			}
			ScrollableListView{
				//anchors.fill:parent
				model:ImageProxyModel{
					id:imageProxy
				}
				delegate: RowLayout{
					Text{
						text: modelData.id
					}					
					Icon{
						id:iconPreview
						width:30
						Layout.fillHeight: true
						icon:modelData.id
						iconSize:30
					}
					Text{
						text: modelData.path
					}
					Button{
						text:'...'
						onClicked: fileDialog.open()
						FileDialog {
							id: fileDialog
							title: "Please choose a file"
							folder: shortcuts.home
							selectExisting: true
							selectFolder: false
							selectMultiple: false
							defaultSuffix: 'svg'
							onAccepted: {
								console.log("You chose: " + fileDialog.fileUrls)
								modelData.setUrl(fileDialog.fileUrl)
							}
							onRejected: {
								console.log("Canceled")
							}
							//Component.onCompleted: visible = true
							
						}
					}
				}
			}
		}
	}
}