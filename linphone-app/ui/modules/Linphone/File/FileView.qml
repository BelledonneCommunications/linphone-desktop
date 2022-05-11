import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import Units 1.0
import ColorsList 1.0

// =============================================================================


Item {
	id: mainItem
	property string thumbnail
	property string name
	property bool active: true
	property real animationScale : ChatStyle.entry.message.file.animation.to
	property alias imageScale: thumbnailProvider.scale
	
	signal clickOnFile()
	// ---------------------------------------------------------------------
	// Thumbnail or extension.
	// ---------------------------------------------------------------------
	
	Component {
		id: thumbnailImage
		
		Image {
			id: thumbnailImageSource
			mipmap: SettingsModel.mipmapEnabled
			source: mainItem.thumbnail
			fillMode: Image.PreserveAspectFit
		}
	}
	
	Component {
		id: extension
		
		Rectangle {
			color: ChatStyle.entry.message.file.extension.background.color
			
			Text {
				anchors.fill: parent
				
				color: ChatStyle.entry.message.file.extension.text.color
				font.bold: true
				elide: Text.ElideRight
				text: Utils.getExtension(mainItem.name).toUpperCase()
				
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
		}
	}
	Loader {
		id: thumbnailProvider
		
		anchors.fill: parent
		//Layout.fillHeight: true
		//Layout.preferredWidth: parent.height
		
		sourceComponent: (mainItem.active ? (mainItem.thumbnail ? thumbnailImage : extension ): undefined)
		
		ScaleAnimator {
			id: thumbnailProviderAnimator
			
			target: mainItem
			
			duration: ChatStyle.entry.message.file.animation.duration
			easing.type: Easing.InOutQuad
			from: 1.0
		}
		
		states: State {
			name: 'hovered'
		}
		
		transitions: [
			Transition {
				from: ''
				to: 'hovered'
				
				ScriptAction {
					script: {
						if (thumbnailProviderAnimator.running) {
							thumbnailProviderAnimator.running = false
						}
						
						mainItem.z = 999//Constants.zPopup
						thumbnailProviderAnimator.to = mainItem.animationScale
						thumbnailProviderAnimator.running = true
					}
				}
			},
			Transition {
				from: 'hovered'
				to: ''
				
				ScriptAction {
					script: {
						if (thumbnailProviderAnimator.running) {
							thumbnailProviderAnimator.running = false
						}
						
						thumbnailProviderAnimator.to = 1.0
						thumbnailProviderAnimator.running = true
						mainItem.z = 0
					}
				}
			}
		]
	}
	MouseArea {
		function handleMouseMove (mouse) {
			thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
					? 'hovered'
					: ''
		}
		
		anchors.fill: parent
		
		onClicked: {
			clickOnFile()
			thumbnailProvider.state = ''
		}
		onExited: thumbnailProvider.state = ''
		onMouseXChanged: handleMouseMove.call(this, mouse)
		onMouseYChanged: handleMouseMove.call(this, mouse)
	}
}